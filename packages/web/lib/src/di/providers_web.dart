import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/cadastro/cadastro_controller.dart';
import 'package:tabloide_web/src/features/cadastro/services/cadastro_service_web.dart';
import 'package:tabloide_web/src/features/categorias/categoria_form_controller.dart';
import 'package:tabloide_web/src/features/categorias/categorias_controller.dart';
import 'package:tabloide_web/src/features/categorias/services/categoria_service_web.dart';
import 'package:tabloide_web/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_web/src/features/filiais/filial_form_controller.dart';
import 'package:tabloide_web/src/features/filiais/services/filial_service_web.dart';
import 'package:tabloide_web/src/features/home/paginas_publicadas_controller.dart';
import 'package:tabloide_web/src/features/home/services/home_service_web.dart';
import 'package:tabloide_web/src/features/home/plataforma/link_service_web.dart';
import 'package:tabloide_web/src/features/home/services/paginas_publicadas_service_web.dart';
import 'package:tabloide_web/src/features/login/login_controller.dart';
import 'package:tabloide_web/src/features/login/services/auth_service_web.dart';
import 'package:tabloide_web/src/features/pagina/pagina_controller.dart';
import 'package:tabloide_web/src/features/pagina/services/pagina_service_web.dart';
import 'package:tabloide_web/src/features/panfletos/panfleto_form_controller.dart';
import 'package:tabloide_web/src/features/panfletos/panfletos_controller.dart';
import 'package:tabloide_web/src/features/panfletos/services/panfleto_service_web.dart';
import 'package:tabloide_web/src/features/panfletos/plataforma/seletor_pdf.dart';
import 'package:tabloide_web/src/features/perfil/perfil_controller.dart';
import 'package:tabloide_web/src/features/perfil/services/perfil_service_web.dart';
import 'package:tabloide_web/src/features/produtos/produto_form_controller.dart';
import 'package:tabloide_web/src/features/produtos/produtos_controller.dart';
import 'package:tabloide_web/src/features/produtos/services/produto_service_web.dart';

List<SingleChildWidget> providersWeb() => [
  Provider<CadastroServiceWeb>(
    create: (context) => CadastroServiceWeb(
      context.read<CadastroRepository>(),
      context.read<Sessao>(),
    ),
  ),
  ChangeNotifierProvider<CadastroController>(
    create: (context) => CadastroController(context.read<CadastroServiceWeb>()),
  ),
  Provider<AuthServiceWeb>(
    create: (context) =>
        AuthServiceWeb(context.read<AuthRepository>(), context.read<Sessao>()),
  ),
  ChangeNotifierProvider<LoginController>(
    create: (context) => LoginController(context.read<AuthServiceWeb>()),
  ),
  Provider<FilialServiceWeb>(
    create: (context) => FilialServiceWeb(
      context.read<FilialRepository>(),
      context.read<CepRepository>(),
    ),
  ),
  ChangeNotifierProvider<FiliaisController>(
    create: (context) => FiliaisController(context.read<FilialServiceWeb>()),
  ),
  ChangeNotifierProvider<FilialFormController>(
    create: (context) => FilialFormController(context.read<FilialServiceWeb>()),
  ),
  Provider<PerfilServiceWeb>(
    create: (context) => PerfilServiceWeb(
      context.read<LojistaRepository>(),
      context.read<IdentidadeRepository>(),
    ),
  ),
  ChangeNotifierProvider<PerfilController>(
    create: (context) => PerfilController(context.read<PerfilServiceWeb>()),
  ),
  Provider<PanfletoServiceWeb>(
    create: (context) => PanfletoServiceWeb(context.read<PanfletoRepository>()),
  ),
  ChangeNotifierProvider<PanfletosController>(
    create: (context) =>
        PanfletosController(context.read<PanfletoServiceWeb>()),
  ),
  ChangeNotifierProvider<PanfletoFormController>(
    create: (context) =>
        PanfletoFormController(context.read<PanfletoServiceWeb>()),
  ),
  Provider<CategoriaServiceWeb>(
    create: (context) =>
        CategoriaServiceWeb(context.read<CategoriaRepository>()),
  ),
  ChangeNotifierProvider<CategoriasController>(
    create: (context) =>
        CategoriasController(context.read<CategoriaServiceWeb>()),
  ),
  ChangeNotifierProvider<CategoriaFormController>(
    create: (context) =>
        CategoriaFormController(context.read<CategoriaServiceWeb>()),
  ),
  Provider<ProdutoServiceWeb>(
    create: (context) => ProdutoServiceWeb(context.read<ProdutoRepository>()),
  ),
  ChangeNotifierProvider<ProdutosController>(
    create: (context) => ProdutosController(context.read<ProdutoServiceWeb>()),
  ),
  ChangeNotifierProvider<ProdutoFormController>(
    create: (context) =>
        ProdutoFormController(context.read<ProdutoServiceWeb>()),
  ),
  Provider<PaginaServiceWeb>(
    create: (context) => PaginaServiceWeb(
      context.read<EstruturaRepository>(),
      context.read<IdentidadeRepository>(),
      context.read<PanfletoRepository>(),
      context.read<ConfiguracaoPaginaRepository>(),
    ),
  ),
  ChangeNotifierProvider<PaginaController>(
    create: (context) => PaginaController(context.read<PaginaServiceWeb>()),
  ),
  Provider<PaginasPublicadasServiceWeb>(
    create: (context) => PaginasPublicadasServiceWeb(
      context.read<IdentidadeRepository>(),
      context.read<LojistaRepository>(),
      context.read<FilialRepository>(),
    ),
  ),
  ChangeNotifierProvider<PaginasPublicadasController>(
    create: (context) => PaginasPublicadasController(
      context.read<PaginasPublicadasServiceWeb>(),
    ),
  ),
  Provider<LinkServiceWeb>(create: (_) => LinkServiceWeb()),
  Provider<SeletorPdf>(create: (_) => const SeletorPdf()),
  Provider<ImagePicker>(create: (_) => ImagePicker()),
  Provider<HomeService>(
    create: (context) => HomeServiceWeb(context.read<HomeRepository>()),
  ),
];
