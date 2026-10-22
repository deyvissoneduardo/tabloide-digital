import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tabloide_app/src/features/home/services/home_service_app.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Services do app; entram no `providersCore(servicos: ...)`, depois dos
/// repositories que eles consomem.
List<SingleChildWidget> providersApp() => [
  Provider<HomeService>(
    create: (context) => HomeServiceApp(context.read<HomeRepository>()),
  ),
];
