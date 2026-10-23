import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

/// Controller com a cadeia real: [HomeServiceWeb] → [HomeRepositoryFake].
HomeController controllerDeTeste({
  HomeRepository repository = const HomeRepositoryFake(atraso: Duration.zero),
}) => HomeController(HomeServiceWeb(repository));

/// Monta a [HomeScreen] com marca e controller no Provider, igual ao bootstrap.
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

/// Controller de login com a cadeia real: [AuthServiceWeb] → [repository].
LoginController loginControllerDeTeste({AuthRepository? repository}) =>
    LoginController(AuthServiceWeb(repository ?? AuthRepositoryFake()));

/// Monta a [LoginScreen] como no bootstrap: marca, login e a home de destino.
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

/// Duas marcas bem diferentes, para os goldens mostrarem o white-label.
const marcasDeTeste = {
  'azul': MarcaFake(nome: 'Marca Azul'),
  'vermelha': MarcaFake(
    nome: 'Marca Vermelha',
    corPrimaria: Color(0xFFC62828),
    corSecundaria: Color(0xFF2E7D32),
  ),
};
