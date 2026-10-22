import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/tabloide_web.dart';

void main() {
  group('Funcionalidade: injeção exclusiva da web', () {
    testWidgets(
      'Cenário: Dado um HomeRepository acima, quando leio o HomeService, então recebo o HomeServiceWeb',
      (tester) async {
        late BuildContext contexto;
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<HomeRepository>.value(value: const HomeRepositoryFake()),
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
      },
    );
  });
}
