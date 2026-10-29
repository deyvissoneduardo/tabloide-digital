import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../../responses/configuracao_pagina_response_test.dart'
    show corpoConfiguracaoPagina;

class _RestClientMock extends Mock implements RestClient {}

const _caminho = '/painel/lojista/pagina';

Map<String, Object?> _erro(
  String codigo,
  String mensagem, [
  Map<String, Object?>? detalhes,
]) => {
  'erro': {'codigo': codigo, 'mensagem': mensagem, 'detalhes': ?detalhes},
};

void main() {
  group('Funcionalidade: aparência da página na API (plano.md §4.2 e §4.3)', () {
    late _RestClientMock client;
    late ConfiguracaoPaginaRepositoryApi repository;

    setUp(() {
      client = _RestClientMock();
      repository = ConfiguracaoPaginaRepositoryApi(client);
    });

    RestResposta resposta(int status, [Object? dados]) =>
        RestResposta(status: status, dados: dados);

    Falha falhaDe<T>(Either<Falha, T> resultado) =>
        (resultado as Failure<Falha, T>).falha;

    const sucesso = Success<Falha, ConfiguracaoPaginaResponse>(
      configuracaoPaginaFake,
    );

    test('Cenário: Dado a API com a configuração, quando obtenho, então faço GET /painel/lojista/pagina e recebo a aparência', () async {
      when(() => client.get(_caminho))
          .thenAnswer((_) async => resposta(200, corpoConfiguracaoPagina()));

      expect(await repository.obter(), sucesso);
    });

    test(
      'Cenário: Dado a API sem conexão, quando obtenho, então FalhaSemConexao',
      () async {
        when(() => client.get(_caminho)).thenThrow(const ErroSemConexao());

        expect(falhaDe(await repository.obter()), const FalhaSemConexao());
      },
    );

    test('Cenário: Dado um corpo fora do formato, quando obtenho, então FalhaInesperada', () async {
      when(() => client.get(_caminho))
          .thenAnswer((_) async => resposta(200, {'banner': null}));

      expect(falhaDe(await repository.obter()), isA<FalhaInesperada>());
    });

    test('Cenário: Dado um pedido, quando edito, então faço PATCH com só as chaves alteradas', () async {
      final pedido = ConfiguracaoPaginaRequest.entre(
        ConfiguracaoPaginaResponse.padrao,
        const ConfiguracaoPaginaResponse(exibirNomeCategoria: false),
      );
      when(() => client.patch(_caminho, corpo: any(named: 'corpo')))
          .thenAnswer((_) async => resposta(200, corpoConfiguracaoPagina()));

      expect(await repository.editar(pedido), sucesso);
      verify(
        () => client.patch(_caminho, corpo: {'exibirNomeCategoria': false}),
      ).called(1);
    });

    test('Cenário: Dado uma cor inválida (400), quando edito, então FalhaApi com o campo e os detalhes', () async {
      when(() => client.patch(_caminho, corpo: any(named: 'corpo'))).thenAnswer(
        (_) async => resposta(
          400,
          _erro('VALIDACAO_INVALIDA', 'Dados inválidos.', {
            'campos': {
              'cores.texto': ['Informe a cor no formato #RRGGBB.'],
            },
          }),
        ),
      );

      final falha = falhaDe(
        await repository.editar(
          ConfiguracaoPaginaRequest.entre(
            ConfiguracaoPaginaResponse.padrao,
            const ConfiguracaoPaginaResponse(
              cores: CoresPaginaResponse(texto: '#12'),
            ),
          ),
        ),
      );

      expect(
        falha,
        const FalhaApi(
          codigo: 'VALIDACAO_INVALIDA',
          mensagem: 'Dados inválidos.',
          campos: {
            'cores.texto': ['Informe a cor no formato #RRGGBB.'],
          },
        ),
      );
      expect((falha as FalhaApi).detalhes, contains('campos'));
    });

    for (final (nome, caminho, enviar) in [
      (
        'logo',
        '$_caminho/banner/logo',
        (ConfiguracaoPaginaRepositoryApi r) =>
            r.enviarLogoBanner(bytes: [1, 2], nomeArquivo: 'logo.png'),
      ),
      (
        'foto',
        '$_caminho/banner/foto',
        (ConfiguracaoPaginaRepositoryApi r) =>
            r.enviarFotoBanner(bytes: [1, 2], nomeArquivo: 'logo.png'),
      ),
    ]) {
      test(
        'Cenário: Dado uma imagem, quando envio o $nome do banner, então PUT multipart no campo imagem em $caminho',
        () async {
          when(
            () => client.enviarArquivo(
              caminho,
              campo: 'imagem',
              bytes: any(named: 'bytes'),
              nomeArquivo: any(named: 'nomeArquivo'),
            ),
          ).thenAnswer((_) async => resposta(200, corpoConfiguracaoPagina()));

          expect(await enviar(repository), sucesso);
          verify(
            () => client.enviarArquivo(
              caminho,
              campo: 'imagem',
              bytes: [1, 2],
              nomeArquivo: 'logo.png',
            ),
          ).called(1);
        },
      );

      test(
        'Cenário: Dado a imagem recusada (413), quando envio o $nome do banner, então FalhaApi IMAGEM_MUITO_GRANDE',
        () async {
          when(
            () => client.enviarArquivo(
              caminho,
              campo: 'imagem',
              bytes: any(named: 'bytes'),
              nomeArquivo: any(named: 'nomeArquivo'),
            ),
          ).thenAnswer(
            (_) async => resposta(
              413,
              _erro('IMAGEM_MUITO_GRANDE', 'A imagem é grande demais.', {
                'maxBytes': 10485760,
              }),
            ),
          );

          final falha = falhaDe(await enviar(repository)) as FalhaApi;
          expect(falha.codigo, 'IMAGEM_MUITO_GRANDE');
          expect(falha.detalhes, {'maxBytes': 10485760});
        },
      );
    }

    for (final (nome, caminho, remover) in [
      (
        'logo',
        '$_caminho/banner/logo',
        (ConfiguracaoPaginaRepositoryApi r) => r.removerLogoBanner(),
      ),
      (
        'foto',
        '$_caminho/banner/foto',
        (ConfiguracaoPaginaRepositoryApi r) => r.removerFotoBanner(),
      ),
    ]) {
      test(
        'Cenário: Dado o $nome do banner, quando removo, então DELETE $caminho',
        () async {
          when(
            () => client.delete(caminho),
          ).thenAnswer((_) async => resposta(200, corpoConfiguracaoPagina()));

          expect(await remover(repository), sucesso);
          verify(() => client.delete(caminho)).called(1);
        },
      );
    }

    test('Cenário: Dado conta desativada (403) sem corpo de erro, quando removo a foto, então FalhaInesperada', () async {
      when(() => client.delete('$_caminho/banner/foto'))
          .thenAnswer((_) async => resposta(403));

      expect(
        falhaDe(await repository.removerFotoBanner()),
        isA<FalhaInesperada>(),
      );
    });
  });
}
