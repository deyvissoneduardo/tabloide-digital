import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tabloide_core/src/brand/brand_config.dart';
import 'package:tabloide_core/src/features/home/home_controller.dart';
import 'package:tabloide_core/src/features/home/repositories/home_repository.dart';
import 'package:tabloide_core/src/features/home/repositories/home_repository_fake.dart';
import 'package:tabloide_core/src/features/home/services/home_service.dart';
import 'package:tabloide_core/src/http/dio_rest_client.dart';
import 'package:tabloide_core/src/http/rest_client.dart';

/// Providers que valem no app e na web, na ordem das camadas:
/// infraestrutura → repositories → [servicos] da plataforma → controllers.
///
/// Os services vêm de fora porque cada plataforma tem os seus; eles ficam
/// entre os repositories (que consomem) e os controllers (que os consomem).
/// [restClient] e [homeRepository] existem para os testes.
List<SingleChildWidget> providersCore({
  required BrandConfig marca,
  required String baseUrl,
  required List<SingleChildWidget> servicos,
  RestClient? restClient,
  HomeRepository? homeRepository,
}) => [
  Provider<BrandConfig>.value(value: marca),
  Provider<RestClient>(
    create: (_) => restClient ?? DioRestClient(baseUrl: baseUrl),
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
