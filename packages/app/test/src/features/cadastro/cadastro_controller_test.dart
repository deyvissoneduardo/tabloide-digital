import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

const _falhaValidacao = FalhaApi(
  codigo: 'VALIDACAO_INVALIDA',
  mensagem: 'Dados inválidos.',
  campos: {
    'senha': ['Senha fraca.', 'Use um número.'],
    'whatsapp': ['Informe um WhatsApp válido com DDD.'],
  },
);

Future<void> _cadastrar(CadastroController controller) => controller.cadastrar(
  nomeFantasia: ' Mercado Bom Preço ',
  nomeResponsavel: ' Teste 02',
  email: ' teste01@gmail.com ',
  senha: ' Teste1234 ',
  whatsapp: '11987654321 ',
  cnpj: ' 11222333000181',
);

void main() {
  group('Funcionalidade: estado do cadastro no app', () {
    test('Cenário: Dado o controller recém-criado, então está ocioso, sem conta e sem erros', () {
      final controller = CadastroController(
        CadastroServiceApp(CadastroRepositoryFake(), sessaoDeTeste()),
      );

      expect(controller.estado, isA<CadastroOcioso>());
      expect(controller.conta, isNull);
      expect(controller.erroDoCampo('email'), isNull);
    });

    test('Cenário: Dado dados aceitos, quando cadastro, então passo por enviando, guardo a conta e envio tudo sem espaços nas pontas', () async {
      final repository = CadastroRepositoryFake();
      final controller = CadastroController(
        CadastroServiceApp(repository, sessaoDeTeste()),
      );
      final estados = <CadastroEstado>[];
      controller.addListener(() => estados.add(controller.estado));

      await _cadastrar(controller);

      expect(estados, [isA<CadastroEnviando>(), isA<CadastroConcluido>()]);
      expect(controller.conta, cadastroFake);
      expect(repository.pedidos, [
        const CadastroRequest(
          nomeFantasia: 'Mercado Bom Preço',
          nomeResponsavel: 'Teste 02',
          email: 'teste01@gmail.com',
          senha: 'Teste1234',
          whatsapp: '11987654321',
          cnpj: '11222333000181',
        ),
      ]);
    });

    test('Cenário: Dado a API recusando com erros por campo, quando cadastro, então fico com a falha e cada campo com seu erro', () async {
      final controller = CadastroController(
        CadastroServiceApp(
          CadastroRepositoryFake(falhaSimulada: _falhaValidacao),
          sessaoDeTeste(),
        ),
      );

      await _cadastrar(controller);

      expect(
        controller.estado,
        isA<CadastroComFalha>().having(
          (e) => e.falha,
          'falha',
          _falhaValidacao,
        ),
      );
      expect(controller.erroDoCampo('senha'), 'Senha fraca.\nUse um número.');
      expect(
        controller.erroDoCampo('whatsapp'),
        'Informe um WhatsApp válido com DDD.',
      );
      expect(controller.erroDoCampo('email'), isNull);
    });

    test('Cenário: Dado a API repetindo a mesma mensagem num campo, quando cadastro, então ela aparece uma vez só', () async {
      const mensagem =
          'A senha precisa ter de 8 a 128 caracteres, com ao menos uma letra e um número.';
      final controller = CadastroController(
        CadastroServiceApp(
          CadastroRepositoryFake(
            falhaSimulada: const FalhaApi(
              codigo: 'VALIDACAO_INVALIDA',
              mensagem: 'Dados inválidos.',
              campos: {
                'senha': [mensagem, mensagem],
              },
            ),
          ),
          sessaoDeTeste(),
        ),
      );

      await _cadastrar(controller);

      expect(controller.erroDoCampo('senha'), mensagem);
    });

    test('Cenário: Dado um erro de campo, quando o lojista edita o campo, então só o erro dele some', () async {
      final controller = CadastroController(
        CadastroServiceApp(
          CadastroRepositoryFake(falhaSimulada: _falhaValidacao),
          sessaoDeTeste(),
        ),
      );
      await _cadastrar(controller);
      var avisos = 0;
      controller.addListener(() => avisos++);

      controller.limparErroDoCampo('whatsapp');
      controller.limparErroDoCampo('whatsapp');

      expect(controller.erroDoCampo('whatsapp'), isNull);
      expect(controller.erroDoCampo('senha'), isNotNull);
      expect(avisos, 1, reason: 'limpar um campo sem erro não avisa ninguém');
    });

    test('Cenário: Dado uma falha sem erros de campo, quando cadastro, então nenhum campo tem erro', () async {
      final controller = CadastroController(
        CadastroServiceApp(
          CadastroRepositoryFake(falhaSimulada: const FalhaSemConexao()),
          sessaoDeTeste(),
        ),
      );

      await _cadastrar(controller);

      expect(controller.estado, isA<CadastroComFalha>());
      expect(controller.erroDoCampo('senha'), isNull);
    });

    test('Cenário: Dado erros de uma tentativa anterior, quando cadastro de novo, então os erros antigos somem', () async {
      final repository = CadastroRepositoryFake(falhaSimulada: _falhaValidacao);
      final controller = CadastroController(
        CadastroServiceApp(repository, sessaoDeTeste()),
      );
      await _cadastrar(controller);

      final segunda = CadastroController(
        CadastroServiceApp(CadastroRepositoryFake(), sessaoDeTeste()),
      );
      await _cadastrar(segunda);
      expect(segunda.erroDoCampo('senha'), isNull);

      controller.reiniciar();
      expect(controller.estado, isA<CadastroOcioso>());
      expect(controller.erroDoCampo('senha'), isNull);
    });

    test('Cenário: Dado um cadastro em andamento, quando peço de novo, então não envio duas vezes', () async {
      final repository = CadastroRepositoryFake();
      final controller = CadastroController(
        CadastroServiceApp(repository, sessaoDeTeste()),
      );

      await Future.wait([_cadastrar(controller), _cadastrar(controller)]);

      expect(repository.pedidos, hasLength(1));
    });

    test('Cenário: Dado WhatsApp e CNPJ com máscara, quando cadastro, então envio só letras e números', () async {
      final repository = CadastroRepositoryFake();
      final controller = CadastroController(
        CadastroServiceApp(repository, sessaoDeTeste()),
      );

      await controller.cadastrar(
        nomeFantasia: 'Mercado Bom Preço',
        nomeResponsavel: 'Teste 02',
        email: 'teste01@gmail.com',
        senha: 'Teste1234',
        whatsapp: '(11) 98765-4321',
        cnpj: '12.ABC.345/01DE-35',
      );

      expect(repository.pedidos.single.whatsapp, '11987654321');
      expect(repository.pedidos.single.cnpj, '12ABC34501DE35');
    });
  });
}
