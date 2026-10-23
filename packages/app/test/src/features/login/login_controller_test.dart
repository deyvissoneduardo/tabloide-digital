import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: estado do login no app', () {
    test(
      'Cenário: Dado o controller recém-criado, então está ocioso e sem sessão',
      () {
        final controller = LoginController(
          AuthServiceApp(AuthRepositoryFake()),
        );

        expect(controller.estado, isA<LoginOcioso>());
        expect(controller.sessao, isNull);
      },
    );

    test('Cenário: Dado credenciais aceitas, quando entro, então passo por enviando e guardo a sessão em memória', () async {
      final repository = AuthRepositoryFake();
      final controller = LoginController(AuthServiceApp(repository));
      final estados = <LoginEstado>[];
      controller.addListener(() => estados.add(controller.estado));

      await controller.entrar(
        email: '  ana@bompreco.com.br ',
        senha: 'Teste1234',
      );

      expect(estados, [isA<LoginEnviando>(), isA<LoginConcluido>()]);
      expect(controller.sessao, sessaoFake);
      expect(
        repository.pedidos,
        [const LoginRequest(email: 'ana@bompreco.com.br', senha: 'Teste1234')],
        reason:
            'o e-mail vai sem espaços nas pontas; a senha vai como digitada',
      );
    });

    test('Cenário: Dado credenciais recusadas, quando entro, então fico com a falha e sem sessão', () async {
      const falha = FalhaApi(
        codigo: 'CREDENCIAIS_INVALIDAS',
        mensagem: 'E-mail ou senha incorretos.',
      );
      final controller = LoginController(
        AuthServiceApp(AuthRepositoryFake(falhaSimulada: falha)),
      );

      await controller.entrar(email: 'a@b.com', senha: 'errada');

      expect(
        controller.estado,
        isA<LoginComFalha>().having((e) => e.falha, 'falha', falha),
      );
      expect(controller.sessao, isNull);
    });

    test('Cenário: Dado um login em andamento, quando peço de novo, então não envio duas vezes', () async {
      final repository = AuthRepositoryFake();
      final controller = LoginController(AuthServiceApp(repository));

      await Future.wait([
        controller.entrar(email: 'a@b.com', senha: 'x'),
        controller.entrar(email: 'a@b.com', senha: 'x'),
      ]);

      expect(repository.pedidos, hasLength(1));
    });
  });
}
