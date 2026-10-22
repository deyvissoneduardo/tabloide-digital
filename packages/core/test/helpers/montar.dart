import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

/// Monta [filho] com a marca no Provider e o tema da marca.
Widget montarComMarca(
  Widget filho, {
  BrandConfig marca = const MarcaFake(),
  Brightness brilho = Brightness.light,
}) => Provider<BrandConfig>.value(
  value: marca,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: brilho == Brightness.light
        ? AppTheme.claro(marca)
        : AppTheme.escuro(marca),
    home: Scaffold(body: Center(child: filho)),
  ),
);
