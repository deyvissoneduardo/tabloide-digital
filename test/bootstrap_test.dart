import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';
import 'package:tabloide_front/bootstrap/bootstrap.dart';

void main() {
  group('Funcionalidade: montagem do painel por plataforma', () {
    testWidgets(
      'Cenário: Dado a VM de teste (plataforma app), quando faço o bootstrap, então abre o PainelApp no login com a injeção do core e do app',
      (tester) async {
        const marca = MarcaFake(nome: 'Marca Bootstrap');

        await tester.pumpWidget(bootstrap(marca: marca, baseUrl: 'http://api'));
        await tester.pumpAndSettle();

        expect(find.byType(PainelApp), findsOneWidget);
        final contexto = tester.element(find.byType(LoginScreen));
        expect(contexto.read<BrandConfig>(), same(marca));
        expect(contexto.read<RestClient>(), isA<RestClient>());
        expect(contexto.read<AuthRepository>(), isA<AuthRepositoryApi>());
        expect(contexto.read<AuthServiceApp>(), isA<AuthServiceApp>());
        expect(contexto.read<LoginController>().estado, isA<LoginOcioso>());
        expect(contexto.read<HomeService>(), isA<HomeServiceApp>());
        expect(find.text('Marca Bootstrap'), findsOneWidget);
      },
    );
  });
}
