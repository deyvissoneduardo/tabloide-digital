import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: injeção exclusiva da web', () {
    testWidgets(
      'Cenário: Dado os repositories acima, quando leio services e controllers, então recebo os da web',
      (tester) async {
        late BuildContext contexto;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<HomeRepository>.value(value: const HomeRepositoryFake()),
              Provider<AuthRepository>.value(value: AuthRepositoryFake()),
              ...providersWeb(),
            ],
            child: Builder(
              builder: (context) {
                contexto = context;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(contexto.read<HomeService>(), isA<HomeServiceWeb>());
        expect(contexto.read<AuthServiceWeb>(), isA<AuthServiceWeb>());
        expect(contexto.read<LoginController>().estado, isA<LoginOcioso>());
      },
    );
  });
}
