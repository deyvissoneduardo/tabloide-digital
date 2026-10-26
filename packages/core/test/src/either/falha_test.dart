import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

void main() {
  group('Funcionalidade: igualdade da FalhaApi', () {
    test('Cenário: Dado duas falhas com os mesmos erros de campo, então são iguais e têm o mesmo hash', () {
      const a = FalhaApi(
        codigo: 'X',
        mensagem: 'm',
        campos: {
          'senha': ['curta'],
          'cnpj': ['inválido'],
        },
      );
      const b = FalhaApi(
        codigo: 'X',
        mensagem: 'm',
        campos: {
          'cnpj': ['inválido'],
          'senha': ['curta'],
        },
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('Cenário: Dado falhas com erros de campo diferentes, então não são iguais', () {
      expect(
        const FalhaApi(
          codigo: 'X',
          mensagem: 'm',
          campos: {
            'senha': ['curta'],
          },
        ),
        isNot(
          const FalhaApi(
            codigo: 'X',
            mensagem: 'm',
            campos: {
              'senha': ['longa'],
            },
          ),
        ),
      );
      expect(
        const FalhaApi(codigo: 'X', mensagem: 'm'),
        isNot(
          const FalhaApi(
            codigo: 'X',
            mensagem: 'm',
            campos: {
              'email': ['repetido'],
            },
          ),
        ),
      );
    });

    test('Cenário: Dado falhas que só diferem nos detalhes, então são iguais (detalhes são só contexto)', () {
      const comDetalhes = FalhaApi(
        codigo: 'PANFLETO_PERIODO_SOBREPOSTO',
        mensagem: 'm',
        detalhes: {
          'conflitoCom': {'id': 'p1'},
        },
      );

      expect(
        comDetalhes,
        const FalhaApi(codigo: 'PANFLETO_PERIODO_SOBREPOSTO', mensagem: 'm'),
      );
      expect(comDetalhes.detalhes, {
        'conflitoCom': {'id': 'p1'},
      });
      expect(const FalhaApi(codigo: 'X', mensagem: 'm').detalhes, isEmpty);
    });
  });
}
