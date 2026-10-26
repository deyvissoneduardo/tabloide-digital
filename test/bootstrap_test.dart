import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_front/bootstrap/bootstrap.dart';

void main() {
  group('Funcionalidade: montagem do painel por plataforma', () {
    testWidgets(
      'Cenário: Dado a VM de teste (plataforma app), quando faço o bootstrap, então abre o PainelApp no login com a injeção do core e do app',
      (tester) async {
        await tester.pumpWidget(bootstrap(baseUrl: 'http://api'));
        await tester.pumpAndSettle();

        expect(find.byType(PainelApp), findsOneWidget);
        final contexto = tester.element(find.byType(LoginScreen));
        expect(contexto.read<RestClient>(), isA<RestClient>());
        expect(contexto.read<AuthRepository>(), isA<AuthRepositoryApi>());
        expect(contexto.read<AuthServiceApp>(), isA<AuthServiceApp>());
        expect(contexto.read<LoginController>().estado, isA<LoginOcioso>());
        expect(
          contexto.read<CadastroRepository>(),
          isA<CadastroRepositoryApi>(),
        );
        expect(contexto.read<CadastroServiceApp>(), isA<CadastroServiceApp>());
        expect(contexto.read<HomeService>(), isA<HomeServiceApp>());
        expect(find.text('Tabloide Digital'), findsOneWidget);
      },
    );
  });
}
