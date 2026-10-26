import 'package:flutter/foundation.dart';
import 'package:tabloide_app/src/features/identidade/identidade_estado.dart';
import 'package:tabloide_app/src/features/identidade/services/identidade_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

const maxBytesLogo = 10 * 1024 * 1024;

const _logoMuitoGrande = FalhaApi(
  codigo: 'IMAGEM_MUITO_GRANDE',
  mensagem: 'A imagem passa de 10 MB. Escolha uma menor.',
);

class IdentidadeController extends ChangeNotifier {
  IdentidadeController(this._service);

  final IdentidadeServiceApp _service;

  IdentidadeEstado _estado = const IdentidadeCarregando();
  Map<String, List<String>> _errosDosCampos = const {};
  bool _salvando = false;
  bool _enviandoLogo = false;

  IdentidadeEstado get estado => _estado;

  bool get salvando => _salvando;

  bool get enviandoLogo => _enviandoLogo;

  String? erroDoCampo(String campo) =>
      _errosDosCampos[campo]?.toSet().join('\n');

  void limparErroDoCampo(String campo) {
    if (!_errosDosCampos.containsKey(campo)) return;
    _errosDosCampos = {..._errosDosCampos}..remove(campo);
    notifyListeners();
  }

  Future<void> carregar() async {
    _estado = const IdentidadeCarregando();
    _errosDosCampos = const {};
    notifyListeners();
    final resultado = await _service.obter();
    _estado = switch (resultado) {
      Success(:final valor) => IdentidadeCarregada(valor),
      Failure(:final falha) => IdentidadeComFalha(falha),
    };
    notifyListeners();
  }

  Future<Either<Falha, IdentidadeResponse>> salvar({
    required String nomeFantasia,
    required String corPrimaria,
    required String corSecundaria,
  }) async {
    _salvando = true;
    _errosDosCampos = const {};
    notifyListeners();
    final resultado = await _service.editar(
      IdentidadeRequest(
        nomeFantasia: nomeFantasia.trim(),
        corPrimaria: _corOuNula(corPrimaria),
        corSecundaria: _corOuNula(corSecundaria),
      ),
    );
    _salvando = false;
    switch (resultado) {
      case Success(:final valor):
        _estado = IdentidadeCarregada(valor);
      case Failure(falha: FalhaApi(:final campos)):
        _errosDosCampos = campos;
      case Failure():
        break;
    }
    notifyListeners();
    return resultado;
  }

  Future<Either<Falha, IdentidadeResponse>> enviarLogo({
    required List<int> bytes,
    required String nomeArquivo,
  }) async {
    if (bytes.length > maxBytesLogo) return const Failure(_logoMuitoGrande);
    _enviandoLogo = true;
    notifyListeners();
    final resultado = await _service.enviarLogo(
      bytes: bytes,
      nomeArquivo: nomeArquivo,
    );
    _enviandoLogo = false;
    if (resultado case Success(:final valor)) {
      _estado = IdentidadeCarregada(valor);
    }
    notifyListeners();
    return resultado;
  }

  String? _corOuNula(String cor) {
    final limpa = cor.trim().toUpperCase();
    return limpa.isEmpty ? null : limpa;
  }
}
