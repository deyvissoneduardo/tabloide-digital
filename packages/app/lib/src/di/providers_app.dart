import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tabloide_app/src/features/home/services/home_service_app.dart';
import 'package:tabloide_app/src/features/login/login_controller.dart';
import 'package:tabloide_app/src/features/login/services/auth_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

List<SingleChildWidget> providersApp() => [
  Provider<AuthServiceApp>(
    create: (context) => AuthServiceApp(context.read<AuthRepository>()),
  ),
  ChangeNotifierProvider<LoginController>(
    create: (context) => LoginController(context.read<AuthServiceApp>()),
  ),
  Provider<HomeService>(
    create: (context) => HomeServiceApp(context.read<HomeRepository>()),
  ),
];
