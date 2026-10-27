import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tabloide_core/src/features/auth/repositories/auth_repository.dart';
import 'package:tabloide_core/src/features/auth/repositories/auth_repository_api.dart';
import 'package:tabloide_core/src/features/cadastro/repositories/cadastro_repository.dart';
import 'package:tabloide_core/src/features/cadastro/repositories/cadastro_repository_api.dart';
import 'package:tabloide_core/src/features/categorias/repositories/categoria_repository.dart';
import 'package:tabloide_core/src/features/categorias/repositories/categoria_repository_api.dart';
import 'package:tabloide_core/src/features/cep/repositories/cep_repository.dart';
import 'package:tabloide_core/src/features/cep/repositories/cep_repository_via_cep.dart';
import 'package:tabloide_core/src/features/estrutura/repositories/estrutura_repository.dart';
import 'package:tabloide_core/src/features/estrutura/repositories/estrutura_repository_api.dart';
import 'package:tabloide_core/src/features/filiais/repositories/filial_repository.dart';
import 'package:tabloide_core/src/features/filiais/repositories/filial_repository_api.dart';
import 'package:tabloide_core/src/features/home/home_controller.dart';
import 'package:tabloide_core/src/features/home/repositories/home_repository.dart';
import 'package:tabloide_core/src/features/home/repositories/home_repository_api.dart';
import 'package:tabloide_core/src/features/home/services/home_service.dart';
import 'package:tabloide_core/src/features/identidade/repositories/identidade_repository.dart';
import 'package:tabloide_core/src/features/identidade/repositories/identidade_repository_api.dart';
import 'package:tabloide_core/src/features/lojista/repositories/lojista_repository.dart';
import 'package:tabloide_core/src/features/lojista/repositories/lojista_repository_api.dart';
import 'package:tabloide_core/src/features/panfletos/repositories/panfleto_repository.dart';
import 'package:tabloide_core/src/features/panfletos/repositories/panfleto_repository_api.dart';
import 'package:tabloide_core/src/features/produtos/repositories/produto_repository.dart';
import 'package:tabloide_core/src/features/produtos/repositories/produto_repository_api.dart';
import 'package:tabloide_core/src/http/dio_rest_client.dart';
import 'package:tabloide_core/src/http/rest_client.dart';
import 'package:tabloide_core/src/sessao/armazenamento_local.dart';
import 'package:tabloide_core/src/sessao/armazenamento_preferencias.dart';
import 'package:tabloide_core/src/sessao/sessao.dart';

List<SingleChildWidget> providersCore({
  required String baseUrl,
  required List<SingleChildWidget> servicos,
  ArmazenamentoLocal? armazenamento,
  RestClient? restClient,
  AuthRepository? authRepository,
  CadastroRepository? cadastroRepository,
  FilialRepository? filialRepository,
  CepRepository? cepRepository,
  IdentidadeRepository? identidadeRepository,
  LojistaRepository? lojistaRepository,
  PanfletoRepository? panfletoRepository,
  CategoriaRepository? categoriaRepository,
  ProdutoRepository? produtoRepository,
  HomeRepository? homeRepository,
  EstruturaRepository? estruturaRepository,
}) => [
  Provider<Sessao>(
    create: (_) => Sessao(armazenamento ?? ArmazenamentoPreferencias()),
  ),
  Provider<RestClient>(
    create: (context) =>
        restClient ??
        DioRestClient(
          baseUrl: baseUrl,
          token: () => context.read<Sessao>().token,
        ),
  ),
  Provider<AuthRepository>(
    create: (context) =>
        authRepository ?? AuthRepositoryApi(context.read<RestClient>()),
  ),
  Provider<CadastroRepository>(
    create: (context) =>
        cadastroRepository ?? CadastroRepositoryApi(context.read<RestClient>()),
  ),
  Provider<FilialRepository>(
    create: (context) =>
        filialRepository ?? FilialRepositoryApi(context.read<RestClient>()),
  ),
  Provider<CepRepository>(
    create: (_) =>
        cepRepository ?? CepRepositoryViaCep(DioRestClient(baseUrl: urlViaCep)),
  ),
  Provider<IdentidadeRepository>(
    create: (context) =>
        identidadeRepository ??
        IdentidadeRepositoryApi(context.read<RestClient>()),
  ),
  Provider<LojistaRepository>(
    create: (context) =>
        lojistaRepository ?? LojistaRepositoryApi(context.read<RestClient>()),
  ),
  Provider<PanfletoRepository>(
    create: (context) =>
        panfletoRepository ?? PanfletoRepositoryApi(context.read<RestClient>()),
  ),
  Provider<CategoriaRepository>(
    create: (context) =>
        categoriaRepository ??
        CategoriaRepositoryApi(context.read<RestClient>()),
  ),
  Provider<ProdutoRepository>(
    create: (context) =>
        produtoRepository ?? ProdutoRepositoryApi(context.read<RestClient>()),
  ),
  Provider<HomeRepository>(
    create: (context) =>
        homeRepository ?? HomeRepositoryApi(context.read<RestClient>()),
  ),
  Provider<EstruturaRepository>(
    create: (context) =>
        estruturaRepository ??
        EstruturaRepositoryApi(context.read<RestClient>()),
  ),
  ...servicos,
  ChangeNotifierProvider<HomeController>(
    create: (context) => HomeController(context.read<HomeService>()),
  ),
];
