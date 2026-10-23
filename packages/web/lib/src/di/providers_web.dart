import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/home/services/home_service_web.dart';
import 'package:tabloide_web/src/features/login/login_controller.dart';
import 'package:tabloide_web/src/features/login/services/auth_service_web.dart';

/// Services e controllers da web; entram no `providersCore(servicos: ...)`,
/// depois dos repositories que eles consomem.
List<SingleChildWidget> providersWeb() => [
  Provider<AuthServiceWeb>(
    create: (context) => AuthServiceWeb(context.read<AuthRepository>()),
  ),
  ChangeNotifierProvider<LoginController>(
    create: (context) => LoginController(context.read<AuthServiceWeb>()),
  ),
  Provider<HomeService>(
    create: (context) => HomeServiceWeb(context.read<HomeRepository>()),
  ),
];
