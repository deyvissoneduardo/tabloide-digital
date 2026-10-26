import 'package:flutter/foundation.dart';
import 'package:tabloide_web/src/features/perfil/perfil_estado.dart';
import 'package:tabloide_web/src/features/perfil/services/perfil_service_web.dart';
import 'package:tabloide_core/tabloide_core.dart';

const maxBytesLogo = 10 * 1024 * 1024;

final _mascara = RegExp('[^0-9a-zA-Z]');

const _logoMuitoGrande = FalhaApi(
  codigo: 'IMAGEM_MUITO_GRANDE',
  mensagem: 'A imagem passa de 10 MB. Escolha uma menor.',
);

class PerfilController extends ChangeNotifier {
  PerfilController(this._service);

  final PerfilServiceWeb _service;

  PerfilEstado _estado = const PerfilCarregando();
  Map<String, List<String>> _errosDosCampos = const {};
  bool _salvando = false;
  bool _enviandoLogo = false;

  PerfilEstado get estado => _estado;

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
    _estado = const PerfilCarregando();
    _errosDosCampos = const {};
    notifyListeners();
    final (lojista, identidade) = await (
      _service.obterLojista(),
      _service.obterIdentidade(),
    ).wait;
    _estado = switch ((lojista, identidade)) {
      (Success(valor: final l), Success(valor: final i)) => PerfilCarregado(
        lojista: l,
        identidade: i,
      ),
      (Failure(:final falha), _) ||
      (_, Failure(:final falha)) => PerfilComFalha(falha),
    };
    notifyListeners();
  }

  Future<Either<Falha, Nada>> salvar({
    required String nomeFantasia,
    required String nomeResponsavel,
    required String whatsapp,
    required String cnpj,
    required String corPrimaria,
    required String corSecundaria,
  }) async {
    _salvando = true;
    _errosDosCampos = const {};
    notifyListeners();
    final nome = nomeFantasia.trim();
    final lojista = await _service.editarLojista(
      LojistaRequest(
        nomeFantasia: nome,
        nomeResponsavel: nomeResponsavel.trim(),
        whatsapp: whatsapp.replaceAll(_mascara, ''),
        cnpj: cnpj.replaceAll(_mascara, '').toUpperCase(),
      ),
    );
    final resultado = switch (lojista) {
      Failure(:final falha) => Failure<Falha, PerfilCarregado>(falha),
      Success(valor: final l) => (await _service.editarIdentidade(
        IdentidadeRequest(
          nomeFantasia: nome,
          corPrimaria: _corOuNula(corPrimaria),
          corSecundaria: _corOuNula(corSecundaria),
        ),
      )).map((i) => PerfilCarregado(lojista: l, identidade: i)),
    };
    _salvando = false;
    switch (resultado) {
      case Success(:final valor):
        _estado = valor;
      case Failure(falha: FalhaApi(:final campos)):
        _errosDosCampos = campos;
      case Failure():
        break;
    }
    notifyListeners();
    return resultado.map((_) => const Nada());
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
    if ((resultado, _estado) case (
      Success(valor: final identidade),
      PerfilCarregado(:final lojista),
    )) {
      _estado = PerfilCarregado(lojista: lojista, identidade: identidade);
    }
    notifyListeners();
    return resultado;
  }

  String? _corOuNula(String cor) {
    final limpa = cor.trim().toUpperCase();
    return limpa.isEmpty ? null : limpa;
  }
}
