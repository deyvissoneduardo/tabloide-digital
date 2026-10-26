import 'package:flutter/widgets.dart';
import 'package:tabloide_front/bootstrap/bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/v1',
  );

  runApp(bootstrap(baseUrl: baseUrl));
}
