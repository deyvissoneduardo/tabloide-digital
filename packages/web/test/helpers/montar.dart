import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

HomeController controllerDeTeste({
  HomeRepository repository = const HomeRepositoryFake(atraso: Duration.zero),
}) => HomeController(HomeServiceWeb(repository));

LoginController loginControllerDeTeste({
  AuthRepository? repository,
  Sessao? sessao,
}) => LoginController(
  AuthServiceWeb(repository ?? AuthRepositoryFake(), sessao ?? sessaoDeTeste()),
);

CadastroController cadastroControllerDeTeste({
  CadastroRepository? repository,
  Sessao? sessao,
}) => CadastroController(
  CadastroServiceWeb(
    repository ?? CadastroRepositoryFake(),
    sessao ?? sessaoDeTeste(),
  ),
);

FiliaisController filiaisControllerDeTeste({FilialRepository? repository}) =>
    FiliaisController(
      FilialServiceWeb(
        repository ?? FilialRepositoryFake(filiais: [filialFake]),
        CepRepositoryFake(),
      ),
    );

FilialFormController filialFormControllerDeTeste({
  FilialRepository? repository,
  CepRepository? cep,
}) => FilialFormController(
  FilialServiceWeb(
    repository ?? FilialRepositoryFake(),
    cep ?? CepRepositoryFake(),
  ),
);

PerfilController perfilControllerDeTeste({
  LojistaRepository? lojista,
  IdentidadeRepository? identidade,
}) => PerfilController(
  PerfilServiceWeb(
    lojista ?? LojistaRepositoryFake(),
    identidade ?? IdentidadeRepositoryFake(),
  ),
);

PanfletosController panfletosControllerDeTeste({
  PanfletoRepository? repository,
}) => PanfletosController(
  PanfletoServiceWeb(
    repository ?? PanfletoRepositoryFake(panfletos: [panfletoFake]),
  ),
);

PanfletoFormController panfletoFormControllerDeTeste({
  PanfletoRepository? repository,
}) => PanfletoFormController(
  PanfletoServiceWeb(repository ?? PanfletoRepositoryFake()),
);

SingleChildWidget _notificador<T extends ChangeNotifier>(
  T? valor,
  T Function() criar,
) => valor == null
    ? ChangeNotifierProvider<T>(create: (_) => criar())
    : ChangeNotifierProvider<T>.value(value: valor);

Widget montarTela(
  Widget tela, {
  BrandConfig marca = const MarcaFake(),
  Sessao? sessao,
  HomeController? home,
  LoginController? login,
  CadastroController? cadastro,
  FiliaisController? filiais,
  FilialFormController? filialForm,
  FilialRepository? filialRepository,
  CepRepository? cepRepository,
  PerfilController? perfil,
  PanfletosController? panfletos,
  PanfletoFormController? panfletoForm,
  PanfletoRepository? panfletoRepository,
  ImagePicker? seletorImagem,
}) {
  final sessaoDaTela = sessao ?? sessaoDeTeste();
  final repository =
      filialRepository ?? FilialRepositoryFake(filiais: [filialFake]);
  final panfletosDaTela =
      panfletoRepository ?? PanfletoRepositoryFake(panfletos: [panfletoFake]);
  return MultiProvider(
    providers: [
      Provider<BrandConfig>.value(value: marca),
      Provider<Sessao>.value(value: sessaoDaTela),
      _notificador(home, controllerDeTeste),
      _notificador(login, () => loginControllerDeTeste(sessao: sessaoDaTela)),
      _notificador(
        cadastro,
        () => cadastroControllerDeTeste(sessao: sessaoDaTela),
      ),
      _notificador(
        filiais,
        () => filiaisControllerDeTeste(repository: repository)..carregar(),
      ),
      _notificador(
        filialForm,
        () => filialFormControllerDeTeste(
          repository: repository,
          cep: cepRepository,
        ),
      ),
      _notificador(perfil, perfilControllerDeTeste),
      _notificador(
        panfletos,
        () => panfletosControllerDeTeste(repository: panfletosDaTela),
      ),
      _notificador(
        panfletoForm,
        () => panfletoFormControllerDeTeste(repository: panfletosDaTela),
      ),
      Provider<ImagePicker>.value(value: seletorImagem ?? ImagePicker()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(marca),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: tela,
    ),
  );
}

Widget montar({
  BrandConfig marca = const MarcaFake(),
  HomeController? controller,
  FiliaisController? filiais,
}) => montarTela(
  const HomeScreen(),
  marca: marca,
  home: controller,
  filiais: filiais,
);

Widget montarCadastro({
  BrandConfig marca = const MarcaFake(),
  CadastroController? controller,
  Sessao? sessao,
  FilialRepository? filialRepository,
}) => montarTela(
  const CadastroScreen(),
  marca: marca,
  cadastro: controller,
  sessao: sessao,
  filialRepository: filialRepository,
);

Widget montarLogin({
  BrandConfig marca = const MarcaFake(),
  LoginController? controller,
  CadastroController? cadastro,
  Sessao? sessao,
  FilialRepository? filialRepository,
}) => montarTela(
  const LoginScreen(),
  marca: marca,
  login: controller,
  cadastro: cadastro,
  sessao: sessao,
  filialRepository: filialRepository,
);

const marcasDeTeste = {
  'azul': MarcaFake(nome: 'Marca Azul'),
  'vermelha': MarcaFake(
    nome: 'Marca Vermelha',
    corPrimaria: Color(0xFFC62828),
    corSecundaria: Color(0xFF2E7D32),
  ),
};
