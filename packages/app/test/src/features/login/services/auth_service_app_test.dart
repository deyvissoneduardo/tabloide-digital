import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

class _AuthRepositoryMock extends Mock implements AuthRepository {}

const _pedido = LoginRequest(email: 'a@b.com', senha: 'Teste1234');

void main() {
  group('Funcionalidade: service de autenticação no app', () {
    late _AuthRepositoryMock repository;
    late AuthServiceApp service;
    setUp(() {
      repository = _AuthRepositoryMock();
      service = AuthServiceApp(repository, sessaoDeTeste());
    });

    test('Cenário: Dado que o repository abre a sessão, quando entro, então devolvo o mesmo Success', () async {
      when(() => repository.entrar(_pedido))
          .thenAnswer((_) async => Success(sessaoFake));

      expect(
        await service.entrar(_pedido),
        Success<Falha, LoginResponse>(sessaoFake),
      );
      verify(() => repository.entrar(_pedido)).called(1);
    });

    test('Cenário: Dado que o repository recusa, quando entro, então devolvo a mesma Failure', () async {
      const falha = FalhaApi(
        codigo: 'CREDENCIAIS_INVALIDAS',
        mensagem: 'E-mail ou senha incorretos.',
      );
      when(() => repository.entrar(_pedido))
          .thenAnswer((_) async => const Failure(falha));

      expect(
        await service.entrar(_pedido),
        const Failure<Falha, LoginResponse>(falha),
      );
    });
  });
}
