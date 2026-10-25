import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tabloide_app/src/features/cadastro/cadastro_controller.dart';
import 'package:tabloide_app/src/features/cadastro/services/cadastro_service_app.dart';
import 'package:tabloide_app/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_app/src/features/filiais/filial_form_controller.dart';
import 'package:tabloide_app/src/features/filiais/services/filial_service_app.dart';
import 'package:tabloide_app/src/features/home/services/home_service_app.dart';
import 'package:tabloide_app/src/features/login/login_controller.dart';
import 'package:tabloide_app/src/features/login/services/auth_service_app.dart';
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
  Provider<HomeService>(
    create: (context) => HomeServiceApp(context.read<HomeRepository>()),
  ),
];
