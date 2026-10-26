import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _corInvalida = FalhaApi(
  codigo: 'VALIDACAO_INVALIDA',
  mensagem: 'Dados inválidos.',
  campos: {
    'corPrimaria': ['Informe a cor no formato #RRGGBB.'],
  },
);

void main() {
  group('Funcionalidade: controller de identidade visual na web', () {
    late IdentidadeRepositoryFake repository;
    late IdentidadeController controller;

    setUp(() {
      repository = IdentidadeRepositoryFake();
      controller = identidadeControllerDeTeste(repository: repository);
    });

    test('Cenário: Dado a API com a identidade, quando carrego, então passo de carregando para carregada', () async {
      final estados = <IdentidadeEstado>[];
      controller.addListener(() => estados.add(controller.estado));

      await controller.carregar();

      expect(estados.first, isA<IdentidadeCarregando>());
      expect(
        (controller.estado as IdentidadeCarregada).identidade,
        identidadeFake,
      );
    });

    test(
      'Cenário: Dado a API fora do ar, quando carrego, então fico com a falha',
      () async {
        repository.falhaSimulada = const FalhaSemConexao();

        await controller.carregar();

        expect(
          (controller.estado as IdentidadeComFalha).falha,
          const FalhaSemConexao(),
        );
      },
    );

    test('Cenário: Dado cores em minúsculas e uma vazia, quando salvo, então envio maiúsculas, null na vazia e atualizo a identidade', () async {
      await controller.carregar();

      final resultado = await controller.salvar(
        nomeFantasia: '  Mercado Novo ',
        corPrimaria: '#00ff00',
        corSecundaria: '',
      );

      expect(
        repository.pedidos.single,
        const IdentidadeRequest(
          nomeFantasia: 'Mercado Novo',
          corPrimaria: '#00FF00',
        ),
      );
      expect(resultado.isSuccess, isTrue);
      expect(controller.salvando, isFalse);
      expect(
        (controller.estado as IdentidadeCarregada).identidade.nomeFantasia,
        'Mercado Novo',
      );
    });

    test('Cenário: Dado uma cor recusada pela API, quando salvo, então o erro vai para o campo e some quando edito o campo', () async {
      await controller.carregar();
      repository.falhaSimulada = _corInvalida;

      await controller.salvar(
        nomeFantasia: 'Mercado',
        corPrimaria: '#C8102E',
        corSecundaria: '',
      );

      expect(
        controller.erroDoCampo('corPrimaria'),
        'Informe a cor no formato #RRGGBB.',
      );
      expect(controller.estado, isA<IdentidadeCarregada>());
      controller.limparErroDoCampo('corPrimaria');
      expect(controller.erroDoCampo('corPrimaria'), isNull);
    });

    test('Cenário: Dado uma imagem válida, quando envio o logo, então a identidade passa a ter o novo logo', () async {
      await controller.carregar();

      final resultado = await controller.enviarLogo(
        bytes: [1, 2, 3],
        nomeArquivo: 'novo.png',
      );

      expect(resultado.isSuccess, isTrue);
      expect(controller.enviandoLogo, isFalse);
      expect(
        (controller.estado as IdentidadeCarregada).identidade.urlLogo,
        'https://midia.fake/logo/novo.png',
      );
    });

    test('Cenário: Dado uma imagem maior que 10 MB, quando envio o logo, então recuso sem chamar a API', () async {
      await controller.carregar();

      final resultado = await controller.enviarLogo(
        bytes: List.filled(maxBytesLogo + 1, 0),
        nomeArquivo: 'grande.png',
      );

      expect(
        (resultado as Failure<Falha, IdentidadeResponse>).falha,
        isA<FalhaApi>().having(
          (f) => f.codigo,
          'codigo',
          'IMAGEM_MUITO_GRANDE',
        ),
      );
      expect(repository.logosEnviados, isEmpty);
    });

    test('Cenário: Dado a API recusando a imagem, quando envio o logo, então devolvo a falha e mantenho o logo atual', () async {
      await controller.carregar();
      repository.falhaSimulada = const FalhaApi(
        codigo: 'IMAGEM_INVALIDA',
        mensagem: 'Envie uma imagem JPEG, PNG ou WebP válida.',
      );

      final resultado = await controller.enviarLogo(
        bytes: [1],
        nomeArquivo: 'a.gif',
      );

      expect(resultado.isFailure, isTrue);
      expect(
        (controller.estado as IdentidadeCarregada).identidade.urlLogo,
        identidadeFake.urlLogo,
      );
    });
  });
}
