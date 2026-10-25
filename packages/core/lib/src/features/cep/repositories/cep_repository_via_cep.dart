import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/tentar.dart';
import 'package:tabloide_core/src/features/cep/repositories/cep_repository.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/responses/cep_response.dart';

const urlViaCep = 'https://viacep.com.br/ws';

const cepNaoEncontrado = FalhaApi(
  codigo: 'CEP_NAO_ENCONTRADO',
  mensagem: 'CEP não encontrado. Confira o número ou preencha o endereço.',
);

final class CepRepositoryViaCep implements CepRepository {
  const CepRepositoryViaCep(this._client);

  final RestClient _client;

  @override
  Future<Either<Falha, CepResponse>> buscar(String cep) async {
    final resposta = await tentar(() => _client.get('/$cep/json/'));
    return switch (resposta) {
      Failure(:final falha) => Failure(falha),
      Success(valor: RestResposta(status: 200, dados: {'erro': _})) ||
      Success(
        valor: RestResposta(status: 400),
      ) => const Failure(cepNaoEncontrado),
      Success(valor: RestResposta(status: 200, :final dados)) => await tentar(
        () async => CepResponse.fromJson(dados),
      ),
      Success(:final valor) => Failure(
        FalhaInesperada('ViaCEP respondeu HTTP ${valor.status}'),
      ),
    };
  }
}
