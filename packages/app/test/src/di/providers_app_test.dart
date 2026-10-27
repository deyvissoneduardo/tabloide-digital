import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
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
              Provider<FilialRepository>.value(value: FilialRepositoryFake()),
              Provider<CepRepository>.value(value: CepRepositoryFake()),
              Provider<IdentidadeRepository>.value(
                value: IdentidadeRepositoryFake(),
              ),
              Provider<LojistaRepository>.value(value: LojistaRepositoryFake()),
              Provider<PanfletoRepository>.value(
                value: PanfletoRepositoryFake(),
              ),
              Provider<EstruturaRepository>.value(
                value: EstruturaRepositoryFake(),
              ),
              Provider<Sessao>.value(value: sessaoDeTeste()),
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
        expect(contexto.read<FilialServiceApp>(), isA<FilialServiceApp>());
        expect(
          contexto.read<FiliaisController>().estado,
          isA<FiliaisCarregando>(),
        );
        expect(
          contexto.read<FilialFormController>().estado,
          isA<FilialFormOcioso>(),
        );
        expect(contexto.read<PerfilServiceApp>(), isA<PerfilServiceApp>());
        expect(
          contexto.read<PerfilController>().estado,
          isA<PerfilCarregando>(),
        );
        expect(contexto.read<ImagePicker>(), isA<ImagePicker>());
        expect(contexto.read<PaginaServiceApp>(), isA<PaginaServiceApp>());
        expect(
          contexto.read<PaginaController>().estado,
          isA<PaginaCarregando>(),
        );
        expect(
          contexto.read<PaginasPublicadasController>().estado,
          isA<PaginasCarregando>(),
        );
        expect(contexto.read<LinkServiceApp>(), isA<LinkServiceApp>());
        expect(contexto.read<SeletorPdf>(), isA<SeletorPdf>());
      },
    );
  });
}
