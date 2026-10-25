import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

class _CadastroRepositoryMock extends Mock implements CadastroRepository {}

const _pedido = CadastroRequest(
  nomeFantasia: 'Mercado Bom Preço',
  nomeResponsavel: 'Teste 02',
  email: 'teste01@gmail.com',
  senha: 'Teste1234',
  whatsapp: '11987654321',
  cnpj: '11222333000181',
);

void main() {
  group('Funcionalidade: service de cadastro no app', () {
    late _CadastroRepositoryMock repository;
    late CadastroServiceApp service;
    setUp(() {
      repository = _CadastroRepositoryMock();
      service = CadastroServiceApp(repository, sessaoDeTeste());
    });

    test('Cenário: Dado que o repository cria a conta, quando cadastro, então devolvo o mesmo Success', () async {
      when(() => repository.cadastrar(_pedido))
          .thenAnswer((_) async => Success(cadastroFake));

      expect(
        await service.cadastrar(_pedido),
        Success<Falha, CadastroResponse>(cadastroFake),
      );
      verify(() => repository.cadastrar(_pedido)).called(1);
    });

    test('Cenário: Dado que o repository recusa, quando cadastro, então devolvo a mesma Failure', () async {
      const falha = FalhaApi(
        codigo: 'EMAIL_JA_CADASTRADO',
        mensagem: 'Este e-mail já está cadastrado.',
      );
      when(() => repository.cadastrar(_pedido))
          .thenAnswer((_) async => const Failure(falha));

      expect(
        await service.cadastrar(_pedido),
        const Failure<Falha, CadastroResponse>(falha),
      );
    });
  });
}
