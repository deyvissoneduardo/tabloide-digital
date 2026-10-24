import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

HomeController controllerDeTeste({
  HomeRepository repository = const HomeRepositoryFake(atraso: Duration.zero),
}) => HomeController(HomeServiceWeb(repository));

Widget montar({
  BrandConfig marca = const MarcaFake(),
  HomeController? controller,
}) => MultiProvider(
  providers: [
    Provider<BrandConfig>.value(value: marca),
    ChangeNotifierProvider.value(value: controller ?? controllerDeTeste()),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.claro(marca),
    home: const HomeScreen(),
  ),
);

LoginController loginControllerDeTeste({AuthRepository? repository}) =>
    LoginController(AuthServiceWeb(repository ?? AuthRepositoryFake()));

Widget montarLogin({
  BrandConfig marca = const MarcaFake(),
  LoginController? controller,
}) => MultiProvider(
  providers: [
    Provider<BrandConfig>.value(value: marca),
    ChangeNotifierProvider.value(value: controller ?? loginControllerDeTeste()),
    ChangeNotifierProvider(create: (_) => controllerDeTeste()),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.claro(marca),
    home: const LoginScreen(),
  ),
);

const marcasDeTeste = {
  'azul': MarcaFake(nome: 'Marca Azul'),
  'vermelha': MarcaFake(
    nome: 'Marca Vermelha',
    corPrimaria: Color(0xFFC62828),
    corSecundaria: Color(0xFF2E7D32),
  ),
};
