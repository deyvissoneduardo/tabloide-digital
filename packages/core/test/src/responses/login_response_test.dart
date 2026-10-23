import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Corpo 201 de `POST /auth/login`, como na documentação da API.
Map<String, Object?> corpoLogin() => {
  'lojista': {
    'id': '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01',
    'nomeFantasia': 'Mercado Bom Preço',
    'nomeResponsavel': 'Ana Souza',
    'email': 'ana@bompreco.com.br',
    'whatsapp': '+5511987654321',
    'cnpj': '11222333000181',
    'status': 'AGUARDANDO_ATIVACAO',
    'criadoEm': '2026-10-18T13:00:00.000Z',
  },
  'token': 'eyJ.assinatura',
  'expiraEm': '2026-10-18T21:00:00.000Z',
};

void main() {
  group('Funcionalidade: ler a resposta do login', () {
    test('Cenário: Dado o corpo 201 da API, quando leio, então todos os campos viram tipos do Dart', () {
      final sessao = LoginResponse.fromJson(corpoLogin());

      expect(sessao.token, 'eyJ.assinatura');
      expect(sessao.expiraEm, DateTime.utc(2026, 10, 18, 21));
      expect(
        sessao.lojista,
        LojistaResponse(
          id: '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01',
          nomeFantasia: 'Mercado Bom Preço',
          nomeResponsavel: 'Ana Souza',
          email: 'ana@bompreco.com.br',
          whatsapp: '+5511987654321',
          cnpj: '11222333000181',
          status: 'AGUARDANDO_ATIVACAO',
          criadoEm: DateTime.utc(2026, 10, 18, 13),
        ),
      );
    });

    test('Cenário: Dado um corpo sem token, quando leio, então lanço FormatException', () {
      expect(
        () => LoginResponse.fromJson({...corpoLogin()}..remove('token')),
        throwsFormatException,
      );
    });

    test('Cenário: Dado um lojista sem e-mail, quando leio, então lanço FormatException', () {
      final corpo = corpoLogin();
      (corpo['lojista']! as Map<String, Object?>).remove('email');

      expect(() => LoginResponse.fromJson(corpo), throwsFormatException);
    });

    test('Cenário: Dado uma sessão, quando viro texto, então o token não aparece (não vaza em log)', () {
      expect(
        LoginResponse.fromJson(corpoLogin()).toString(),
        isNot(contains('eyJ.assinatura')),
      );
    });
  });

  group('Funcionalidade: montar o pedido de login', () {
    test('Cenário: Dado e-mail e senha, quando gero o JSON, então uso os nomes da API', () {
      expect(
        const LoginRequest(email: 'a@b.com', senha: 'Teste1234').toJson(),
        {'email': 'a@b.com', 'senha': 'Teste1234'},
      );
    });

    test(
      'Cenário: Dado um pedido, quando viro texto, então a senha não aparece',
      () {
        expect(
          const LoginRequest(email: 'a@b.com', senha: 'Teste1234').toString(),
          isNot(contains('Teste1234')),
        );
      },
    );
  });
}
