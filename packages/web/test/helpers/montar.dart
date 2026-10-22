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
  Brightness brilho = Brightness.light,
}) => MultiProvider(
  providers: [
    Provider<BrandConfig>.value(value: marca),
    ChangeNotifierProvider.value(value: controller ?? controllerDeTeste()),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: brilho == Brightness.light
        ? AppTheme.claro(marca)
        : AppTheme.escuro(marca),
    home: const HomeScreen(),
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
