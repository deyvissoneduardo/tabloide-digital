import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: registro de marcas white-label', () {
    group('Cenário: Dado um registro com a marca "mercado" registrada', () {
      late BrandRegistry registry;
      setUp(
        () =>
            registry = BrandRegistry()..registrar('mercado', const MarcaFake()),
      );

      test('Quando resolvo "mercado", então recebo a marca registrada', () {
        expect(registry.resolver('mercado').nome, 'Marca Teste');
      });

      test('Quando resolvo uma marca inexistente, então recebo MarcaNaoRegistrada com as disponíveis', () {
        expect(
          () => registry.resolver('padaria'),
          throwsA(
            isA<MarcaNaoRegistrada>()
                .having((e) => e.disponiveis, 'disponiveis', ['mercado'])
                .having((e) => e.toString(), 'mensagem', contains('mercado')),
          ),
        );
      });

      test(
        'Quando registro "mercado" de novo, então recebo MarcaDuplicada',
        () {
          expect(
            () => registry.registrar('mercado', const MarcaFake()),
            throwsA(isA<MarcaDuplicada>()),
          );
        },
      );

      test(
        'Quando registro uma segunda marca, então ids lista as duas na ordem',
        () {
          registry.registrar('padaria', const MarcaFake(nome: 'Padaria'));
          expect(registry.ids, ['mercado', 'padaria']);
        },
      );

      test('Quando tento alterar a lista de ids, então recebo erro', () {
        expect(() => registry.ids.add('x'), throwsUnsupportedError);
      });
    });

    group('Cenário: Dado uma marca com dados inválidos', () {
      final casos = <String, (String, BrandConfig)>{
        'id fora de snake_case': ('Mercado-X', const MarcaFake()),
        'id vazio': ('', const MarcaFake()),
        'nome em branco': ('x', const MarcaFake(nome: '   ')),
        'CNPJ com DV errado': ('x', const MarcaFake(cnpj: '11222333000182')),
        'cor primária transparente': (
          'x',
          const MarcaFake(corPrimaria: Color(0x801565C0)),
        ),
        'cor secundária transparente': (
          'x',
          const MarcaFake(corSecundaria: Color(0x00FFB300)),
        ),
      };

      for (final MapEntry(key: descricao, value: (id, marca))
          in casos.entries) {
        test(
          'Quando registro com $descricao, então recebo MarcaInvalida e nada é registrado',
          () {
            final registry = BrandRegistry();
            expect(
              () => registry.registrar(id, marca),
              throwsA(isA<MarcaInvalida>()),
            );
            expect(registry.ids, isEmpty);
          },
        );
      }
    });
  });
}
