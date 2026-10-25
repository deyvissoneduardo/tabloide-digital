import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_web/src/features/cadastro/cadastro_controller.dart';
import 'package:tabloide_web/src/features/cadastro/services/cadastro_service_web.dart';
import 'package:tabloide_web/src/features/filiais/filiais_controller.dart';
import 'package:tabloide_web/src/features/filiais/filial_form_controller.dart';
import 'package:tabloide_web/src/features/filiais/services/filial_service_web.dart';
import 'package:tabloide_web/src/features/home/services/home_service_web.dart';
import 'package:tabloide_web/src/features/login/login_controller.dart';
import 'package:tabloide_web/src/features/login/services/auth_service_web.dart';

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
  Provider<HomeService>(
    create: (context) => HomeServiceWeb(context.read<HomeRepository>()),
  ),
];
