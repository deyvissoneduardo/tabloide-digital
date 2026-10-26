import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
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
              Provider<CadastroRepository>.value(
                value: CadastroRepositoryFake(),
              ),
              Provider<FilialRepository>.value(value: FilialRepositoryFake()),
              Provider<CepRepository>.value(value: CepRepositoryFake()),
              Provider<IdentidadeRepository>.value(
                value: IdentidadeRepositoryFake(),
              ),
              Provider<Sessao>.value(value: sessaoDeTeste()),
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
        expect(contexto.read<CadastroServiceWeb>(), isA<CadastroServiceWeb>());
        expect(
          contexto.read<CadastroController>().estado,
          isA<CadastroOcioso>(),
        );
        expect(contexto.read<FilialServiceWeb>(), isA<FilialServiceWeb>());
        expect(
          contexto.read<FiliaisController>().estado,
          isA<FiliaisCarregando>(),
        );
        expect(
          contexto.read<FilialFormController>().estado,
          isA<FilialFormOcioso>(),
        );
        expect(
          contexto.read<IdentidadeServiceWeb>(),
          isA<IdentidadeServiceWeb>(),
        );
        expect(
          contexto.read<IdentidadeController>().estado,
          isA<IdentidadeCarregando>(),
        );
        expect(contexto.read<ImagePicker>(), isA<ImagePicker>());
      },
    );
  });
}
