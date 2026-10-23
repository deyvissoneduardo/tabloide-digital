import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';
import 'package:tabloide_front/bootstrap/bootstrap.dart';

void main() {
  group('Funcionalidade: montagem do painel por plataforma', () {
    testWidgets(
      'Cenário: Dado a VM de teste (plataforma app), quando faço o bootstrap, então abre o PainelApp com marca e HomeController acessíveis',
      (tester) async {
        const marca = MarcaFake(nome: 'Marca Bootstrap');

        await tester.pumpWidget(bootstrap(marca: marca, baseUrl: 'http://api'));
        // O skeleton é estático: sem animação, o pumpAndSettle não espera o
        // atraso do repository fake sozinho.
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.byType(PainelApp), findsOneWidget);
        final contexto = tester.element(find.byType(HomeScreen));
        expect(contexto.read<BrandConfig>(), same(marca));
        expect(contexto.read<HomeController>().secao, SecaoPainel.inicio);
        expect(contexto.read<RestClient>(), isA<RestClient>());
        expect(contexto.read<HomeService>(), isA<HomeServiceApp>());
        expect(find.text('Marca Bootstrap'), findsOneWidget);
      },
    );
  });
}
