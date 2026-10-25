import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/testing.dart';
import 'package:tabloide_web/tabloide_web.dart';

FiliaisController _controller(FilialRepositoryFake repository) =>
    FiliaisController(FilialServiceWeb(repository, CepRepositoryFake()));

void main() {
  group('Funcionalidade: lista e filial em uso na web', () {
    test('Cenário: Dado o controller recém-criado, então está carregando, sem filiais e sem filial em uso', () {
      final controller = _controller(FilialRepositoryFake());

      expect(controller.estado, isA<FiliaisCarregando>());
      expect(controller.filiais, isEmpty);
      expect(controller.emUso, isNull);
    });

    test('Cenário: Dado uma única filial, quando carrego, então passo por carregando e ela já fica em uso', () async {
      final controller = _controller(
        FilialRepositoryFake(filiais: [filialFake]),
      );
      final estados = <FiliaisEstado>[];
      controller.addListener(() => estados.add(controller.estado));

      await controller.carregar();

      expect(estados, [isA<FiliaisCarregando>(), isA<FiliaisCarregadas>()]);
      expect(controller.filiais, [filialFake]);
      expect(controller.emUso, filialFake);
      expect(controller.podeExcluir, isFalse);
    });

    test('Cenário: Dado duas filiais, quando carrego, então nenhuma fica em uso até o lojista escolher', () async {
      final controller = _controller(
        FilialRepositoryFake(filiais: [filialFake, filialFakeBairro]),
      );

      await controller.carregar();
      expect(controller.emUso, isNull);
      expect(controller.podeExcluir, isTrue);

      controller.usar(filialFakeBairro);
      expect(controller.emUso, filialFakeBairro);
    });

    test('Cenário: Dado uma filial em uso, quando recarrego, então ela continua em uso', () async {
      final controller = _controller(
        FilialRepositoryFake(filiais: [filialFake, filialFakeBairro]),
      );
      await controller.carregar();
      controller.usar(filialFakeBairro);

      await controller.carregar();

      expect(controller.emUso, filialFakeBairro);
    });

    test(
      'Cenário: Dado a API falhando, quando carrego, então fico com a falha',
      () async {
        final controller = _controller(
          FilialRepositoryFake(falhaSimulada: const FalhaSemConexao()),
        );

        await controller.carregar();

        expect(
          controller.estado,
          isA<FiliaisComFalha>().having(
            (e) => e.falha,
            'falha',
            const FalhaSemConexao(),
          ),
        );
      },
    );

    test('Cenário: Dado nenhuma filial, quando a primeira é salva, então ela entra na lista e fica em uso', () async {
      final controller = _controller(FilialRepositoryFake());
      await controller.carregar();

      controller.salva(filialFake);

      expect(controller.filiais, [filialFake]);
      expect(controller.emUso, filialFake);
    });

    test('Cenário: Dado a filial em uso, quando ela é editada, então a lista e a filial em uso trazem o dado novo', () async {
      final controller = _controller(
        FilialRepositoryFake(filiais: [filialFake, filialFakeBairro]),
      );
      await controller.carregar();
      controller.usar(filialFake);
      final editada = FilialResponse(
        id: filialFake.id,
        nome: 'Centro Novo',
        endereco: filialFake.endereco,
        fusoHorario: filialFake.fusoHorario,
        codigoPublico: filialFake.codigoPublico,
        urlPublica: filialFake.urlPublica,
        criadaEm: filialFake.criadaEm,
        atualizadaEm: filialFake.atualizadaEm,
      );

      controller.salva(editada);

      expect(controller.filiais.map((f) => f.nome), [
        'Centro Novo',
        'Bairro Alto',
      ]);
      expect(controller.emUso, editada);
    });

    test('Cenário: Dado três filiais e uma em uso, quando excluo a filial em uso, então ela sai e nenhuma fica em uso', () async {
      final terceira = FilialResponse(
        id: 'terceira',
        nome: 'Norte',
        endereco: filialFake.endereco,
        fusoHorario: filialFake.fusoHorario,
        codigoPublico: 'n',
        urlPublica: 'u',
        criadaEm: filialFake.criadaEm,
        atualizadaEm: filialFake.atualizadaEm,
      );
      final repository = FilialRepositoryFake(
        filiais: [filialFake, filialFakeBairro, terceira],
      );
      final controller = _controller(repository);
      await controller.carregar();
      controller.usar(filialFake);

      final resultado = await controller.excluir(filialFake);

      expect(resultado.isSuccess, isTrue);
      expect(repository.excluidas, [filialFake.id]);
      expect(controller.filiais, [filialFakeBairro, terceira]);
      expect(controller.emUso, isNull);
    });

    test('Cenário: Dado duas filiais, quando excluo uma, então a que sobra fica em uso', () async {
      final controller = _controller(
        FilialRepositoryFake(filiais: [filialFake, filialFakeBairro]),
      );
      await controller.carregar();
      controller.usar(filialFake);

      await controller.excluir(filialFake);

      expect(controller.emUso, filialFakeBairro);
    });

    test('Cenário: Dado a API recusando a exclusão, quando excluo, então devolvo a falha e a lista não muda', () async {
      final repository = FilialRepositoryFake(
        filiais: [filialFake, filialFakeBairro],
      );
      final controller = _controller(repository);
      await controller.carregar();
      repository.falhaSimulada = const FalhaSemConexao();

      final resultado = await controller.excluir(filialFake);

      expect(resultado, const Failure<Falha, Nada>(FalhaSemConexao()));
      expect(controller.filiais, hasLength(2));
    });
  });
}
