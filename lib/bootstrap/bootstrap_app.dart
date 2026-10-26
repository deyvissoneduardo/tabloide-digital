import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/tabloide_app.dart';

Widget bootstrap({required String baseUrl}) =>
    MultiProvider(
      providers: providersCore(
        baseUrl: baseUrl,
        servicos: providersApp(),
      ),
      child: const PainelApp(),
    );
