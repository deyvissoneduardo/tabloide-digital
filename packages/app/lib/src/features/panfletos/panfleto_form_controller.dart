import 'package:flutter/foundation.dart';
import 'package:tabloide_app/src/features/panfletos/panfleto_form_estado.dart';
import 'package:tabloide_app/src/features/panfletos/services/panfleto_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

const maxBytesImagemPanfleto = 10 * 1024 * 1024;

/// Limite do PDF do panfleto (plano D4).
const maxBytesPdfPanfleto = 2 * 1024 * 1024;

typedef ArquivoEscolhido = ({Uint8List bytes, String nome});

bool _ehPdf(String nome) => nome.toLowerCase().endsWith('.pdf');

class PanfletoFormController extends ChangeNotifier {
  PanfletoFormController(this._service);

  final PanfletoServiceApp _service;

  PanfletoFormEstado _estado = const PanfletoFormOcioso();
  Map<String, List<String>> _errosDosCampos = const {};
  ArquivoEscolhido? _imagem;
  PanfletoResponse? _datasSalvas;

  PanfletoFormEstado get estado => _estado;

  ArquivoEscolhido? get imagem => _imagem;

  /// O arquivo escolhido (ou, sem escolha, o do panfleto em edição) é PDF.
  bool arquivoEhPdf([PanfletoResponse? emEdicao]) => switch (_imagem) {
    (:final nome, bytes: _) => _ehPdf(nome),
    null => emEdicao?.tipo == TipoArquivoPanfleto.pdf,
  };

  void reiniciar() {
    _estado = const PanfletoFormOcioso();
    _errosDosCampos = const {};
    _imagem = null;
  }

  String? erroDoCampo(String campo) =>
      _errosDosCampos[campo]?.toSet().join('\n');

  void limparErroDoCampo(String campo) {
    if (!_errosDosCampos.containsKey(campo)) return;
    _errosDosCampos = {..._errosDosCampos}..remove(campo);
    notifyListeners();
  }

  /// Imagem ou PDF (pelo nome). O tamanho é conferido antes do envio (RNF05).
  void escolherArquivo(Uint8List bytes, String nome) {
    final pdf = _ehPdf(nome);
    if (bytes.length > (pdf ? maxBytesPdfPanfleto : maxBytesImagemPanfleto)) {
      _errosDosCampos = {
        ..._errosDosCampos,
        'imagem': [
          pdf
              ? 'O PDF pode ter até 2 MB. Exporte o PDF otimizado para web e tente de novo.'
              : 'A imagem passa de 10 MB. Escolha uma menor.',
        ],
      };
    } else {
      _imagem = (bytes: bytes, nome: nome);
      _errosDosCampos = {..._errosDosCampos}..remove('imagem');
    }
    notifyListeners();
  }

  Future<void> salvar({
    required String filialId,
    PanfletoResponse? panfleto,
    DateTime? dataInicio,
    DateTime? dataLimite,
  }) async {
    if (_estado is PanfletoFormEnviando) return;
    final imagem = _imagem;
    if (panfleto == null && imagem == null) {
      _errosDosCampos = {
        ..._errosDosCampos,
        'imagem': ['Escolha a imagem do panfleto.'],
      };
      notifyListeners();
      return;
    }
    _estado = const PanfletoFormEnviando();
    _errosDosCampos = const {};
    _datasSalvas = null;
    notifyListeners();
    final resultado = switch ((panfleto, imagem)) {
      (final panfleto?, _) => await _editar(
        panfleto,
        imagem,
        dataInicio: dataInicio,
        dataLimite: dataLimite,
      ),
      (null, final imagem?) => await _service.criar(
        filialId,
        PanfletoRequest(dataInicio: dataInicio, dataLimite: dataLimite),
        bytes: imagem.bytes,
        nomeArquivo: imagem.nome,
      ),
      (null, null) => throw StateError('imagem conferida acima'),
    };
    switch (resultado) {
      case Success(:final valor):
        _estado = PanfletoFormConcluido(valor);
      case Failure(:final falha):
        _estado = PanfletoFormComFalha(falha, atualizado: _datasSalvas);
        if (falha case FalhaApi(
          :final codigo,
          :final mensagem,
          :final campos,
        )) {
          _errosDosCampos = {
            ...campos,
            if (codigo.startsWith('IMAGEM_') || codigo.startsWith('PDF_'))
              'imagem': [mensagem],
          };
        }
    }
    notifyListeners();
  }

  Future<Either<Falha, PanfletoResponse>> _editar(
    PanfletoResponse panfleto,
    ArquivoEscolhido? imagem, {
    DateTime? dataInicio,
    DateTime? dataLimite,
  }) async {
    final vigencia = panfleto.vigencia;
    final pedido = PanfletoRequest(
      dataInicio:
          vigencia.podeAlterarInicio && dataInicio != vigencia.dataInicio
          ? dataInicio
          : null,
      dataLimite: dataLimite != vigencia.dataLimite ? dataLimite : null,
    );
    var resultado = pedido.toJson().isEmpty
        ? Success<Falha, PanfletoResponse>(panfleto)
        : await _service.editar(panfleto.filialId, panfleto.id, pedido);
    if ((resultado, imagem) case (Success(:final valor), final imagem?)) {
      if (pedido.toJson().isNotEmpty) _datasSalvas = valor;
      resultado = await _service.trocarImagem(
        panfleto.filialId,
        panfleto.id,
        bytes: imagem.bytes,
        nomeArquivo: imagem.nome,
      );
    }
    return resultado;
  }
}
