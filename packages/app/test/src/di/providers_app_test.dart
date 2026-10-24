import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: injeção exclusiva do app', () {
    testWidgets(
      'Cenário: Dado os repositories acima, quando leio services e controllers, então recebo os do app',
      (tester) async {
        late BuildContext contexto;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<HomeRepository>.value(value: const HomeRepositoryFake()),
              Provider<AuthRepository>.value(value: AuthRepositoryFake()),
              Provider<CadastroRepository>.value(
                value: CadastroRepositoryFake(),
              ),
              ...providersApp(),
            ],
            child: Builder(
              builder: (context) {
                contexto = context;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(contexto.read<HomeService>(), isA<HomeServiceApp>());
        expect(contexto.read<AuthServiceApp>(), isA<AuthServiceApp>());
        expect(contexto.read<LoginController>().estado, isA<LoginOcioso>());
        expect(contexto.read<CadastroServiceApp>(), isA<CadastroServiceApp>());
        expect(
          contexto.read<CadastroController>().estado,
          isA<CadastroOcioso>(),
        );
      },
    );
  });
}
