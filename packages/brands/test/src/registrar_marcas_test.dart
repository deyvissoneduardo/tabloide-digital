import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_brands/tabloide_brands.dart';
import 'package:tabloide_core/tabloide_core.dart';

void main() {
  group('Funcionalidade: clientes white-label registrados', () {
    group('Cenário: Dado um registro com todas as marcas do pacote', () {
      late BrandRegistry registry;
      setUp(() {
        registry = BrandRegistry();
        registrarMarcas(registry);
      });

      test('Quando registro, então nenhuma marca é recusada (nome, CNPJ e cores válidos)', () {
        expect(() => registrarMarcas(BrandRegistry()), returnsNormally);
      });

      test('Quando listo os ids, então tenho a marca padrão e o cliente de exemplo', () {
        expect(registry.ids, ['tabloide', 'mercado_exemplo']);
        expect(registry.ids, contains(marcaPadrao));
      });

      test(
        'Quando listo os nomes, então não há nome repetido entre clientes',
        () {
          final nomes = registry.ids.map((id) => registry.resolver(id).nome);
          expect(nomes.toSet(), hasLength(registry.ids.length));
        },
      );

      testWidgets(
        'Quando carrego a logo de cada marca, então todas existem nos assets',
        (tester) async {
          for (final id in registry.ids) {
            final logo = registry.resolver(id).logo;
            Object? erro;
            await tester.pumpWidget(const SizedBox());
            await tester.runAsync(
              () => precacheImage(
                logo,
                tester.element(find.byType(SizedBox)),
                onError: (e, _) => erro = e,
              ),
            );
            expect(erro, isNull, reason: 'logo da marca "$id" não carregou');
          }
        },
      );
    });
  });
}
