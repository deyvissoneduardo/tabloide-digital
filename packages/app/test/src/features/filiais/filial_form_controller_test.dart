import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

Future<void> _salvar(
  FilialFormController controller, {
  String? id,
  String cep = '13010-111',
  String complemento = ' Loja 2 ',
  String uf = 'SP',
}) => controller.salvar(
  id: id,
  nome: ' Centro ',
  cep: cep,
  logradouro: ' Rua das Flores ',
  numero: ' 120 ',
  complemento: complemento,
  bairro: ' Centro ',
  cidade: ' Campinas ',
  uf: uf,
);

const _endereco = Endereco(
  cep: '13010-111',
  logradouro: 'Rua das Flores',
  numero: '120',
  complemento: 'Loja 2',
  bairro: 'Centro',
  cidade: 'Campinas',
  uf: 'SP',
);

void main() {
  group('Funcionalidade: salvar filial no app', () {
    test(
      'Cenário: Dado o controller recém-criado, então está ocioso e sem erros',
      () {
        final controller = FilialFormController(
          FilialServiceApp(FilialRepositoryFake(), CepRepositoryFake()),
        );

        expect(controller.estado, isA<FilialFormOcioso>());
        expect(controller.erroDoCampo('nome'), isNull);
      },
    );

    test('Cenário: Dado uma filial nova, quando salvo, então passo por enviando, crio com tudo aparado e guardo a filial', () async {
      final repository = FilialRepositoryFake();
      final controller = FilialFormController(
        FilialServiceApp(repository, CepRepositoryFake()),
      );
      final estados = <FilialFormEstado>[];
      controller.addListener(() => estados.add(controller.estado));

      await _salvar(controller);

      expect(estados, [isA<FilialFormEnviando>(), isA<FilialFormConcluido>()]);
      expect(repository.pedidos, [
        const FilialRequest(
          nome: 'Centro',
          endereco: _endereco,
          fusoHorario: 'America/Sao_Paulo',
        ),
      ]);
      expect(repository.filiais, hasLength(1));
    });

    test(
      'Cenário: Dado uma filial existente, quando salvo, então edito pelo id',
      () async {
        final repository = FilialRepositoryFake(filiais: [filialFake]);
        final controller = FilialFormController(
          FilialServiceApp(repository, CepRepositoryFake()),
        );

        await _salvar(controller, id: filialFake.id);

        final estado = controller.estado as FilialFormConcluido;
        expect(estado.filial.id, filialFake.id);
        expect(repository.filiais.single.nome, 'Centro');
      },
    );

    for (final (caso, cep) in [
      ('só números', '13010111'),
      ('com máscara', '13010-111'),
    ]) {
      test(
        'Cenário: Dado o CEP $caso, quando salvo, então envio no formato 00000-000',
        () async {
          final repository = FilialRepositoryFake();
          final controller = FilialFormController(
            FilialServiceApp(repository, CepRepositoryFake()),
          );

          await _salvar(controller, cep: cep);

          expect(repository.pedidos.single.endereco.cep, '13010-111');
        },
      );
    }

    test('Cenário: Dado o complemento em branco, quando salvo, então não envio complemento', () async {
      final repository = FilialRepositoryFake();
      final controller = FilialFormController(
        FilialServiceApp(repository, CepRepositoryFake()),
      );

      await _salvar(controller, complemento: '  ');

      expect(repository.pedidos.single.endereco.complemento, isNull);
    });

    test('Cenário: Dado a API recusando com erros por campo (inclusive do endereço e do fuso), quando salvo, então cada campo recebe o seu erro e o do fuso vai para a UF', () async {
      const falha = FalhaApi(
        codigo: 'VALIDACAO_INVALIDA',
        mensagem: 'Dados inválidos.',
        campos: {
          'endereco.cep': ['CEP inválido.'],
          'fusoHorario': ['Fuso horário inválido.'],
          'endereco.uf': ['UF inválida.'],
        },
      );
      final controller = FilialFormController(
        FilialServiceApp(
          FilialRepositoryFake(falhaSimulada: falha),
          CepRepositoryFake(),
        ),
      );

      await _salvar(controller);

      expect(
        controller.estado,
        isA<FilialFormComFalha>().having((e) => e.falha, 'falha', falha),
      );
      expect(controller.erroDoCampo('cep'), 'CEP inválido.');
      expect(
        controller.erroDoCampo('uf'),
        'Fuso horário inválido.\nUF inválida.',
      );

      controller.limparErroDoCampo('cep');
      expect(controller.erroDoCampo('cep'), isNull);
      expect(controller.erroDoCampo('uf'), isNotNull);

      controller.reiniciar();
      expect(controller.estado, isA<FilialFormOcioso>());
      expect(controller.erroDoCampo('uf'), isNull);
    });

    test('Cenário: Dado um envio em andamento, quando peço de novo, então não envio duas vezes', () async {
      final repository = FilialRepositoryFake();
      final controller = FilialFormController(
        FilialServiceApp(repository, CepRepositoryFake()),
      );

      await Future.wait([_salvar(controller), _salvar(controller)]);

      expect(repository.pedidos, hasLength(1));
    });

    for (final (uf, fuso) in [
      ('SP', 'America/Sao_Paulo'),
      ('AM', 'America/Manaus'),
      ('MT', 'America/Cuiaba'),
    ]) {
      test(
        'Cenário: Dado a UF $uf, quando salvo, então envio o fuso $fuso',
        () async {
          final repository = FilialRepositoryFake();
          final controller = FilialFormController(
            FilialServiceApp(repository, CepRepositoryFake()),
          );

          await _salvar(controller, uf: uf);

          expect(repository.pedidos.single.fusoHorario, fuso);
        },
      );
    }

    test('Cenário: Dado um CEP com máscara, quando busco, então passo por buscando e recebo o endereço', () async {
      final cep = CepRepositoryFake();
      final controller = FilialFormController(
        FilialServiceApp(FilialRepositoryFake(), cep),
      );
      final buscando = <bool>[];
      controller.addListener(() => buscando.add(controller.buscandoCep));

      final resultado = await controller.buscarCep('01001-000');

      expect(resultado, const Success<Falha, CepResponse>(cepFake));
      expect(buscando, [true, false]);
      expect(cep.buscados, ['01001000']);
    });

    test('Cenário: Dado um CEP inexistente, quando busco, então o erro vai para o campo CEP', () async {
      final controller = FilialFormController(
        FilialServiceApp(FilialRepositoryFake(), CepRepositoryFake()),
      );

      await controller.buscarCep('99999999');

      expect(controller.erroDoCampo('cep'), cepNaoEncontrado.mensagem);
    });

    test('Cenário: Dado o ViaCEP sem conexão, quando busco, então devolvo a falha sem erro no campo', () async {
      final controller = FilialFormController(
        FilialServiceApp(
          FilialRepositoryFake(),
          CepRepositoryFake(falhaSimulada: const FalhaSemConexao()),
        ),
      );

      final resultado = await controller.buscarCep('01001000');

      expect(resultado, const Failure<Falha, CepResponse>(FalhaSemConexao()));
      expect(controller.erroDoCampo('cep'), isNull);
      expect(controller.buscandoCep, isFalse);
    });
  });
}
