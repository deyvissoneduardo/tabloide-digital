import 'package:flutter/foundation.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/filiais/filial_form_estado.dart';
import 'package:tabloide_web/src/features/filiais/services/filial_service_web.dart';

final _naoDigito = RegExp(r'\D');

class FilialFormController extends ChangeNotifier {
  FilialFormController(this._service);

  final FilialServiceWeb _service;

  FilialFormEstado _estado = const FilialFormOcioso();
  Map<String, List<String>> _errosDosCampos = const {};
  bool _buscandoCep = false;

  FilialFormEstado get estado => _estado;

  bool get buscandoCep => _buscandoCep;

  void reiniciar() {
    _estado = const FilialFormOcioso();
    _errosDosCampos = const {};
    _buscandoCep = false;
  }

  String? erroDoCampo(String campo) =>
      _errosDosCampos[campo]?.toSet().join('\n');

  void limparErroDoCampo(String campo) {
    if (!_errosDosCampos.containsKey(campo)) return;
    _errosDosCampos = {..._errosDosCampos}..remove(campo);
    notifyListeners();
  }

  Future<Either<Falha, CepResponse>> buscarCep(String cep) async {
    _buscandoCep = true;
    notifyListeners();
    final resultado = await _service.buscarCep(cep.replaceAll(_naoDigito, ''));
    _buscandoCep = false;
    if (resultado case Failure(
      falha: FalhaApi(codigo: 'CEP_NAO_ENCONTRADO', :final mensagem),
    )) {
      _errosDosCampos = {
        ..._errosDosCampos,
        'cep': [mensagem],
      };
    }
    notifyListeners();
    return resultado;
  }

  Future<void> salvar({
    String? id,
    required String nome,
    required String cep,
    required String logradouro,
    required String numero,
    required String complemento,
    required String bairro,
    required String cidade,
    required String uf,
  }) async {
    if (_estado is FilialFormEnviando) return;
    _estado = const FilialFormEnviando();
    _errosDosCampos = const {};
    notifyListeners();
    final digitos = cep.replaceAll(_naoDigito, '');
    final request = FilialRequest(
      nome: nome.trim(),
      endereco: Endereco(
        cep: digitos.length == 8
            ? '${digitos.substring(0, 5)}-${digitos.substring(5)}'
            : digitos,
        logradouro: logradouro.trim(),
        numero: numero.trim(),
        complemento: complemento.trim().isEmpty ? null : complemento.trim(),
        bairro: bairro.trim(),
        cidade: cidade.trim(),
        uf: uf,
      ),
      fusoHorario: (Uf.daSigla(uf)?.fuso ?? FusoHorario.saoPaulo).id,
    );
    final resultado = id == null
        ? await _service.criar(request)
        : await _service.editar(id, request);
    switch (resultado) {
      case Success(:final valor):
        _estado = FilialFormConcluido(valor);
      case Failure(:final falha):
        _estado = FilialFormComFalha(falha);
        if (falha case FalhaApi(:final campos)) {
          final erros = <String, List<String>>{};
          for (final MapEntry(:key, :value) in campos.entries) {
            final campo = key == 'fusoHorario'
                ? 'uf'
                : key.replaceFirst('endereco.', '');
            (erros[campo] ??= []).addAll(value);
          }
          _errosDosCampos = erros;
        }
    }
    notifyListeners();
  }
}
