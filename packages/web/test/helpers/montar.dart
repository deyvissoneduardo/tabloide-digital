import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:share_plus/share_plus.dart';
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

CategoriasController categoriasControllerDeTeste({
  CategoriaRepository? repository,
}) => CategoriasController(
  CategoriaServiceWeb(
    repository ?? CategoriaRepositoryFake(categorias: [categoriaFake]),
  ),
);

CategoriaFormController categoriaFormControllerDeTeste({
  CategoriaRepository? repository,
}) => CategoriaFormController(
  CategoriaServiceWeb(repository ?? CategoriaRepositoryFake()),
);

ProdutosController produtosControllerDeTeste({ProdutoRepository? repository}) =>
    ProdutosController(
      ProdutoServiceWeb(
        repository ?? ProdutoRepositoryFake(produtos: [produtoFake]),
      ),
    );

ProdutoFormController produtoFormControllerDeTeste({
  ProdutoRepository? repository,
}) => ProdutoFormController(
  ProdutoServiceWeb(repository ?? ProdutoRepositoryFake()),
);

PaginaController paginaControllerDeTeste({
  EstruturaRepository? estrutura,
  IdentidadeRepository? identidade,
  PanfletoRepository? panfletos,
}) => PaginaController(
  PaginaServiceWeb(
    estrutura ?? EstruturaRepositoryFake(),
    identidade ?? IdentidadeRepositoryFake(),
    panfletos ?? PanfletoRepositoryFake(panfletos: [panfletoFake]),
  ),
);

PaginasPublicadasController paginasPublicadasControllerDeTeste({
  IdentidadeRepository? identidade,
  LojistaRepository? lojista,
  FilialRepository? filiais,
}) => PaginasPublicadasController(
  PaginasPublicadasServiceWeb(
    identidade ?? IdentidadeRepositoryFake(),
    lojista ?? LojistaRepositoryFake(),
    filiais ?? FilialRepositoryFake(filiais: [filialFake]),
  ),
);

/// LinkService sem plugins: registra o que foi aberto, copiado e compartilhado.
class LinkServiceDeTeste extends LinkServiceWeb {
  LinkServiceDeTeste({this.abre = true, bool navegadorCompartilha = true})
    : super(
        abrirUrl: (_) async => abre,
        compartilharNoSistema: (_) async => navegadorCompartilha
            ? ShareResult.unavailable
            : throw Exception('Navigator.canShare() is unavailable'),
      );

  final bool abre;

  final abertos = <String>[];

  final copiados = <String>[];

  final compartilhados = <String>[];

  @override
  Future<bool> abrir(String url) {
    abertos.add(url);
    return super.abrir(url);
  }

  @override
  Future<void> copiar(String url) async => copiados.add(url);

  @override
  Future<ResultadoCompartilhar> compartilhar(String texto, String url) {
    compartilhados.add(texto);
    return super.compartilhar(texto, url);
  }
}

/// Seletor de PDF que devolve o arquivo configurado (null = cancelado).
class SeletorPdfDeTeste extends SeletorPdf {
  const SeletorPdfDeTeste([this.arquivo]);

  final ArquivoEscolhido? arquivo;

  @override
  Future<ArquivoEscolhido?> escolher() async => arquivo;
}

SingleChildWidget _notificador<T extends ChangeNotifier>(
  T? valor,
  T Function() criar,
) => valor == null
    ? ChangeNotifierProvider<T>(create: (_) => criar())
    : ChangeNotifierProvider<T>.value(value: valor);

Widget montarTela(
  Widget tela, {
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
  CategoriasController? categorias,
  CategoriaFormController? categoriaForm,
  CategoriaRepository? categoriaRepository,
  ProdutosController? produtos,
  ProdutoFormController? produtoForm,
  ProdutoRepository? produtoRepository,
  ImagePicker? seletorImagem,
  SeletorPdf? seletorPdf,
  PaginaController? pagina,
  PaginasPublicadasController? paginasPublicadas,
  LinkServiceWeb? linkService,
}) {
  final sessaoDaTela = sessao ?? sessaoDeTeste();
  final repository =
      filialRepository ?? FilialRepositoryFake(filiais: [filialFake]);
  final panfletosDaTela =
      panfletoRepository ?? PanfletoRepositoryFake(panfletos: [panfletoFake]);
  final categoriasDaTela =
      categoriaRepository ??
      CategoriaRepositoryFake(categorias: [categoriaFake, categoriaFakeVazia]);
  final produtosDaTela =
      produtoRepository ??
      ProdutoRepositoryFake(produtos: [produtoFake, produtoFakeAgendado]);
  return MultiProvider(
    providers: [
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
      _notificador(
        categorias,
        () => categoriasControllerDeTeste(repository: categoriasDaTela),
      ),
      _notificador(
        categoriaForm,
        () => categoriaFormControllerDeTeste(repository: categoriasDaTela),
      ),
      _notificador(
        produtos,
        () => produtosControllerDeTeste(repository: produtosDaTela),
      ),
      _notificador(
        produtoForm,
        () => produtoFormControllerDeTeste(repository: produtosDaTela),
      ),
      _notificador(pagina, paginaControllerDeTeste),
      _notificador(
        paginasPublicadas,
        () => paginasPublicadasControllerDeTeste(filiais: repository),
      ),
      Provider<LinkServiceWeb>.value(
        value: linkService ?? LinkServiceDeTeste(),
      ),
      Provider<SeletorPdf>.value(
        value: seletorPdf ?? const SeletorPdfDeTeste(),
      ),
      Provider<ImagePicker>.value(value: seletorImagem ?? ImagePicker()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: tela,
    ),
  );
}

Widget montar({HomeController? controller, FiliaisController? filiais}) =>
    montarTela(const HomeScreen(), home: controller, filiais: filiais);

Widget montarCadastro({
  CadastroController? controller,
  Sessao? sessao,
  FilialRepository? filialRepository,
}) => montarTela(
  const CadastroScreen(),
  cadastro: controller,
  sessao: sessao,
  filialRepository: filialRepository,
);

Widget montarLogin({
  LoginController? controller,
  CadastroController? cadastro,
  Sessao? sessao,
  FilialRepository? filialRepository,
}) => montarTela(
  const LoginScreen(),
  login: controller,
  cadastro: cadastro,
  sessao: sessao,
  filialRepository: filialRepository,
);

Future<void> precarregarLogo(WidgetTester tester) => tester.runAsync(
  () => Future.wait([
    for (final elemento in find.byType(MarcaLogo).evaluate())
      precacheImage(AppMarca.logo, elemento),
  ]),
);
