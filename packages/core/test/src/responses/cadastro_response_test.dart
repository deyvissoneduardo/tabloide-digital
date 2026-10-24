import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

import 'login_response_test.dart' show corpoLogin;

void main() {
  group('Funcionalidade: ler a resposta do cadastro', () {
    test('Cenário: Dado o corpo 201 da API, quando leio, então lojista, token e validade viram tipos do Dart', () {
      final conta = CadastroResponse.fromJson(corpoLogin());

      expect(conta.token, 'eyJ.assinatura');
      expect(conta.expiraEm, DateTime.utc(2026, 10, 18, 21));
      expect(conta.lojista.status, 'AGUARDANDO_ATIVACAO');
      expect(conta.lojista.criadoEm, DateTime.utc(2026, 10, 18, 13));
    });

    test('Cenário: Dado um corpo sem lojista, quando leio, então lanço FormatException', () {
      expect(
        () => CadastroResponse.fromJson({...corpoLogin()}..remove('lojista')),
        throwsFormatException,
      );
    });

    test(
      'Cenário: Dado uma conta, quando viro texto, então o token não aparece',
      () {
        expect(
          CadastroResponse.fromJson(corpoLogin()).toString(),
          isNot(contains('eyJ.assinatura')),
        );
      },
    );
  });

  group('Funcionalidade: montar o pedido de cadastro', () {
    const pedido = CadastroRequest(
      nomeFantasia: 'Mercado Bom Preço',
      nomeResponsavel: 'Teste 02',
      email: 'teste01@gmail.com',
      senha: 'Teste1234',
      whatsapp: '11987654321',
      cnpj: '11222333000181',
    );

    test('Cenário: Dado os dados do lojista, quando gero o JSON, então uso os nomes da API', () {
      expect(pedido.toJson(), {
        'nomeFantasia': 'Mercado Bom Preço',
        'nomeResponsavel': 'Teste 02',
        'email': 'teste01@gmail.com',
        'senha': 'Teste1234',
        'whatsapp': '11987654321',
        'cnpj': '11222333000181',
      });
    });

    test(
      'Cenário: Dado um pedido, quando viro texto, então a senha não aparece',
      () {
        expect(pedido.toString(), isNot(contains('Teste1234')));
      },
    );
  });
}
