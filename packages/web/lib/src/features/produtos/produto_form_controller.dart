import 'package:flutter/foundation.dart';
import 'package:tabloide_web/src/features/produtos/produto_form_estado.dart';
import 'package:tabloide_web/src/features/produtos/services/produto_service_web.dart';
import 'package:tabloide_core/tabloide_core.dart';

const maxBytesFoto = 10 * 1024 * 1024;

typedef FotoEscolhida = ({Uint8List bytes, String nome});

String? _campoDoCodigo(String codigo) => switch (codigo) {
  'PRECO_ORIGINAL_INVALIDO' => 'precoOriginalCentavos',
  'DATA_INICIO_INVALIDA' || 'DATA_INICIO_IMUTAVEL' => 'dataInicio',
  'DATA_LIMITE_INVALIDA' => 'dataLimite',
  _ when codigo.startsWith('IMAGEM_') => 'foto',
  _ => null,
};

class ProdutoFormController extends ChangeNotifier {
  ProdutoFormController(this._service);

  final ProdutoServiceWeb _service;

  ProdutoFormEstado _estado = const ProdutoFormOcioso();
  Map<String, List<String>> _errosDosCampos = const {};
  FotoEscolhida? _foto;
  bool _fotoRemovida = false;
  ProdutoResponse? _atualizado;

  ProdutoFormEstado get estado => _estado;

  FotoEscolhida? get foto => _foto;

  bool get fotoRemovida => _fotoRemovida;

  bool get temErroNosCampos => _errosDosCampos.isNotEmpty;

  void reiniciar() {
    _estado = const ProdutoFormOcioso();
    _errosDosCampos = const {};
    _foto = null;
    _fotoRemovida = false;
  }

  String? erroDoCampo(String campo) =>
      _errosDosCampos[campo]?.toSet().join('\n');

  void limparErroDoCampo(String campo) {
    if (!_errosDosCampos.containsKey(campo)) return;
    _errosDosCampos = {..._errosDosCampos}..remove(campo);
    notifyListeners();
  }

  void escolherFoto(Uint8List bytes, String nome) {
    if (bytes.length > maxBytesFoto) {
      _errosDosCampos = {
        ..._errosDosCampos,
        'foto': ['A foto passa de 10 MB. Escolha uma menor.'],
      };
    } else {
      _foto = (bytes: bytes, nome: nome);
      _fotoRemovida = false;
      _errosDosCampos = {..._errosDosCampos}..remove('foto');
    }
    notifyListeners();
  }

  void removerFoto() {
    _foto = null;
    _fotoRemovida = true;
    _errosDosCampos = {..._errosDosCampos}..remove('foto');
    notifyListeners();
  }

  Future<void> salvar({
    required String filialId,
    required ProdutoRequest request,
    ProdutoResponse? produto,
  }) async {
    if (_estado is ProdutoFormEnviando) return;
    _estado = const ProdutoFormEnviando();
    _errosDosCampos = const {};
    _atualizado = null;
    notifyListeners();
    final resultado = switch (produto) {
      final produto? => await _editar(produto, request),
      null => await _service.criar(filialId, request, foto: _foto),
    };
    switch (resultado) {
      case Success(:final valor):
        _estado = ProdutoFormConcluido(valor);
      case Failure(:final falha):
        _estado = ProdutoFormComFalha(falha, atualizado: _atualizado);
        if (falha case FalhaApi(
          :final codigo,
          :final mensagem,
          :final campos,
        )) {
          _errosDosCampos = {
            ...campos,
            ?_campoDoCodigo(codigo): [mensagem],
          };
        }
    }
    notifyListeners();
  }

  Future<Either<Falha, ProdutoResponse>> _editar(
    ProdutoResponse produto,
    ProdutoRequest request,
  ) async {
    final pedido = EditarProdutoRequest.entre(produto, request);
    var resultado = pedido.vazio
        ? Success<Falha, ProdutoResponse>(produto)
        : await _service.editar(produto.filialId, produto.id, pedido);
    final foto = _foto;
    final remover = _fotoRemovida && produto.urlFoto != null;
    if (resultado case Success(:final valor) when foto != null || remover) {
      if (!pedido.vazio) _atualizado = valor;
      resultado = switch (foto) {
        final foto? => await _service.trocarFoto(
          produto.filialId,
          produto.id,
          foto,
        ),
        null => await _service.removerFoto(produto.filialId, produto.id),
      };
    }
    return resultado;
  }
}
