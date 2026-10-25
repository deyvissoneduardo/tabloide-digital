import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

Map<String, Object?> corpoFilial({Object? complemento = 'Loja 2'}) => {
  'id': '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02',
  'nome': 'Centro',
  'endereco': {
    'cep': '13010111',
    'logradouro': 'Rua das Flores',
    'numero': '120',
    'complemento': ?complemento,
    'bairro': 'Centro',
    'cidade': 'Campinas',
    'uf': 'SP',
  },
  'fusoHorario': 'America/Sao_Paulo',
  'codigoPublico': 'k7Qm2xPa',
  'urlPublica': 'https://tabloide.app/f/k7Qm2xPa',
  'criadaEm': '2026-10-18T13:05:00.000Z',
  'atualizadaEm': '2026-10-18T13:05:00.000Z',
};

void main() {
  group('Funcionalidade: ler e enviar filial', () {
    test('Cenário: Dado o corpo 200 da API, quando leio, então todos os campos viram tipos do Dart', () {
      expect(FilialResponse.fromJson(corpoFilial()), filialFake);
    });

    for (final (caso, valor) in [('ausente', null), ('vazio', '')]) {
      test(
        'Cenário: Dado o complemento $caso, quando leio, então ele fica nulo',
        () {
          final filial = FilialResponse.fromJson(
            corpoFilial(complemento: valor),
          );

          expect(filial.endereco.complemento, isNull);
        },
      );
    }

    test('Cenário: Dado um corpo sem campo obrigatório, quando leio, então lança FormatException', () {
      expect(
        () => FilialResponse.fromJson({...corpoFilial()}..remove('nome')),
        throwsFormatException,
      );
      expect(
        () => FilialResponse.fromJson({
          ...corpoFilial(),
          'endereco': {'cep': '1'},
        }),
        throwsFormatException,
      );
    });

    test('Cenário: Dado um pedido de filial, quando converto, então gero o corpo da API e omito o complemento vazio', () {
      const pedido = FilialRequest(
        nome: 'Centro',
        endereco: Endereco(
          cep: '13010-111',
          logradouro: 'Rua das Flores',
          numero: '120',
          bairro: 'Centro',
          cidade: 'Campinas',
          uf: 'SP',
        ),
        fusoHorario: 'America/Sao_Paulo',
      );

      expect(pedido.toJson(), {
        'nome': 'Centro',
        'endereco': {
          'cep': '13010-111',
          'logradouro': 'Rua das Flores',
          'numero': '120',
          'bairro': 'Centro',
          'cidade': 'Campinas',
          'uf': 'SP',
        },
        'fusoHorario': 'America/Sao_Paulo',
      });
    });

    test('Cenário: Dado os fusos do Brasil, quando busco pelo id, então acho o fuso ou nulo', () {
      expect(FusoHorario.doId('America/Manaus'), FusoHorario.manaus);
      expect(FusoHorario.doId('Europe/Lisbon'), isNull);
    });
  });
}
