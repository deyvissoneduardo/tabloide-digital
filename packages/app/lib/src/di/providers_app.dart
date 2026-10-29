import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tabloide_app/src/features/cadastro/cadastro_controller.dart';
import 'package:tabloide_app/src/features/cadastro/services/cadastro_service_app.dart';
import 'package:tabloide_app/src/features/categorias/categoria_form_controller.dart';
import 'package:tabloide_app/src/features/categorias/categorias_controller.dart';
import 'package:tabloide_app/src/features/categorias/services/categoria_service_app.dart';
import 'package:tabloide_app/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_app/src/features/filiais/filial_form_controller.dart';
import 'package:tabloide_app/src/features/filiais/services/filial_service_app.dart';
import 'package:tabloide_app/src/features/home/paginas_publicadas_controller.dart';
import 'package:tabloide_app/src/features/home/services/home_service_app.dart';
import 'package:tabloide_app/src/features/home/plataforma/link_service_app.dart';
import 'package:tabloide_app/src/features/home/services/paginas_publicadas_service_app.dart';
import 'package:tabloide_app/src/features/login/login_controller.dart';
import 'package:tabloide_app/src/features/login/services/auth_service_app.dart';
import 'package:tabloide_app/src/features/pagina/pagina_controller.dart';
import 'package:tabloide_app/src/features/pagina/services/pagina_service_app.dart';
import 'package:tabloide_app/src/features/panfletos/panfleto_form_controller.dart';
import 'package:tabloide_app/src/features/panfletos/panfletos_controller.dart';
import 'package:tabloide_app/src/features/panfletos/services/panfleto_service_app.dart';
import 'package:tabloide_app/src/features/panfletos/plataforma/seletor_pdf.dart';
import 'package:tabloide_app/src/features/perfil/perfil_controller.dart';
import 'package:tabloide_app/src/features/perfil/services/perfil_service_app.dart';
import 'package:tabloide_app/src/features/produtos/produto_form_controller.dart';
import 'package:tabloide_app/src/features/produtos/produtos_controller.dart';
import 'package:tabloide_app/src/features/produtos/services/produto_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

List<SingleChildWidget> providersApp() => [
  Provider<CadastroServiceApp>(
    create: (context) => CadastroServiceApp(
      context.read<CadastroRepository>(),
      context.read<Sessao>(),
    ),
  ),
  ChangeNotifierProvider<CadastroController>(
    create: (context) => CadastroController(context.read<CadastroServiceApp>()),
  ),
  Provider<AuthServiceApp>(
    create: (context) =>
        AuthServiceApp(context.read<AuthRepository>(), context.read<Sessao>()),
  ),
  ChangeNotifierProvider<LoginController>(
    create: (context) => LoginController(context.read<AuthServiceApp>()),
  ),
  Provider<FilialServiceApp>(
    create: (context) => FilialServiceApp(
      context.read<FilialRepository>(),
      context.read<CepRepository>(),
    ),
  ),
  ChangeNotifierProvider<FiliaisController>(
    create: (context) => FiliaisController(context.read<FilialServiceApp>()),
  ),
  ChangeNotifierProvider<FilialFormController>(
    create: (context) => FilialFormController(context.read<FilialServiceApp>()),
  ),
  Provider<PerfilServiceApp>(
    create: (context) => PerfilServiceApp(
      context.read<LojistaRepository>(),
      context.read<IdentidadeRepository>(),
    ),
  ),
  ChangeNotifierProvider<PerfilController>(
    create: (context) => PerfilController(context.read<PerfilServiceApp>()),
  ),
  Provider<PanfletoServiceApp>(
    create: (context) => PanfletoServiceApp(context.read<PanfletoRepository>()),
  ),
  ChangeNotifierProvider<PanfletosController>(
    create: (context) =>
        PanfletosController(context.read<PanfletoServiceApp>()),
  ),
  ChangeNotifierProvider<PanfletoFormController>(
    create: (context) =>
        PanfletoFormController(context.read<PanfletoServiceApp>()),
  ),
  Provider<CategoriaServiceApp>(
    create: (context) =>
        CategoriaServiceApp(context.read<CategoriaRepository>()),
  ),
  ChangeNotifierProvider<CategoriasController>(
    create: (context) =>
        CategoriasController(context.read<CategoriaServiceApp>()),
  ),
  ChangeNotifierProvider<CategoriaFormController>(
    create: (context) =>
        CategoriaFormController(context.read<CategoriaServiceApp>()),
  ),
  Provider<ProdutoServiceApp>(
    create: (context) => ProdutoServiceApp(context.read<ProdutoRepository>()),
  ),
  ChangeNotifierProvider<ProdutosController>(
    create: (context) => ProdutosController(context.read<ProdutoServiceApp>()),
  ),
  ChangeNotifierProvider<ProdutoFormController>(
    create: (context) =>
        ProdutoFormController(context.read<ProdutoServiceApp>()),
  ),
  Provider<PaginaServiceApp>(
    create: (context) => PaginaServiceApp(
      context.read<EstruturaRepository>(),
      context.read<IdentidadeRepository>(),
      context.read<PanfletoRepository>(),
      context.read<ConfiguracaoPaginaRepository>(),
    ),
  ),
  ChangeNotifierProvider<PaginaController>(
    create: (context) => PaginaController(context.read<PaginaServiceApp>()),
  ),
  Provider<PaginasPublicadasServiceApp>(
    create: (context) => PaginasPublicadasServiceApp(
      context.read<IdentidadeRepository>(),
      context.read<LojistaRepository>(),
      context.read<FilialRepository>(),
    ),
  ),
  ChangeNotifierProvider<PaginasPublicadasController>(
    create: (context) => PaginasPublicadasController(
      context.read<PaginasPublicadasServiceApp>(),
    ),
  ),
  Provider<LinkServiceApp>(create: (_) => LinkServiceApp()),
  Provider<SeletorPdf>(create: (_) => const SeletorPdf()),
  Provider<ImagePicker>(create: (_) => ImagePicker()),
  Provider<HomeService>(
    create: (context) => HomeServiceApp(context.read<HomeRepository>()),
  ),
];
