import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tabloide_core/src/brand/brand_config.dart';
import 'package:tabloide_core/src/features/auth/repositories/auth_repository.dart';
import 'package:tabloide_core/src/features/auth/repositories/auth_repository_api.dart';
import 'package:tabloide_core/src/features/cadastro/repositories/cadastro_repository.dart';
import 'package:tabloide_core/src/features/cadastro/repositories/cadastro_repository_api.dart';
import 'package:tabloide_core/src/features/home/home_controller.dart';
import 'package:tabloide_core/src/features/home/repositories/home_repository.dart';
import 'package:tabloide_core/src/features/home/repositories/home_repository_fake.dart';
import 'package:tabloide_core/src/features/home/services/home_service.dart';
import 'package:tabloide_core/src/http/dio_rest_client.dart';
import 'package:tabloide_core/src/http/rest_client.dart';

List<SingleChildWidget> providersCore({
  required BrandConfig marca,
  required String baseUrl,
  required List<SingleChildWidget> servicos,
  RestClient? restClient,
  AuthRepository? authRepository,
  CadastroRepository? cadastroRepository,
  HomeRepository? homeRepository,
}) => [
  Provider<BrandConfig>.value(value: marca),
  Provider<RestClient>(
    create: (_) => restClient ?? DioRestClient(baseUrl: baseUrl),
  ),
  Provider<AuthRepository>(
    create: (context) =>
        authRepository ?? AuthRepositoryApi(context.read<RestClient>()),
  ),
  Provider<CadastroRepository>(
    create: (context) =>
        cadastroRepository ?? CadastroRepositoryApi(context.read<RestClient>()),
  ),
  Provider<HomeRepository>(
    create: (_) => homeRepository ?? const HomeRepositoryFake(),
  ),
  ...servicos,
  ChangeNotifierProvider<HomeController>(
    create: (context) =>
        HomeController(context.read<HomeService>())..carregarResumo(),
  ),
];
