@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _raiz = Directory.current.parent.parent;

const _pacotesDeTela = ['packages/app', 'packages/web', 'lib'];

final _proibidos = <String, (RegExp, String)>{
  'cor literal': (
    RegExp(r'Color\(0x|Color\.fromA?RGBO?\(|\bColors\.(?!transparent\b)'),
    'use Theme.of(context).colorScheme ou AppCores',
  ),
  'número solto em EdgeInsets': (
    RegExp(r'EdgeInsets(Directional)?\.\w+\([^)]*?\b\d'),
    'use AppEspacamentos',
  ),
  'número solto em SizedBox': (
    RegExp(r'SizedBox\((width|height): *\d'),
    'use AppEspacamentos ou AppLayout',
  ),
  'raio literal': (
    RegExp(r'(BorderRadius\.circular|Radius\.circular)\( *\d'),
    'use AppRaios',
  ),
  'elevação literal': (
    RegExp(r'elevation: *\d'),
    'o tema define elevação (cards planos)',
  ),
  'tamanho de ícone literal': (RegExp(r'\bsize: *\d'), 'use AppIcones'),
  'estilo de texto avulso': (
    RegExp(r'\bTextStyle\(|fontSize:|fontFamily:'),
    'use Theme.of(context).textTheme',
  ),
  'tema escuro': (
    RegExp(r'darkTheme:|ThemeMode\.(dark|system)|AppTheme\.escuro'),
    'o painel só tem tema claro',
  ),
  'breakpoint literal': (
    RegExp(r'(width|largura)\s*[<>]=?\s*\d'),
    'use ClasseTamanho.de(context) / AppLayout',
  ),
  'MediaQuery.of para tamanho': (
    RegExp(r'MediaQuery\.of\([^)]*\)\.size'),
    'use ClasseTamanho.de(context) ou MediaQuery.sizeOf',
  ),
};

List<String> _ocorrencias(String pasta, RegExp padrao) => [
  for (final f in Directory('${_raiz.path}/$pasta').listSync(recursive: true))
    if (f is File && f.path.endsWith('.dart'))
      for (final (i, linha) in f.readAsLinesSync().indexed)
        if (!linha.trimLeft().startsWith('//') && padrao.hasMatch(linha))
          '${f.path.substring(_raiz.path.length + 1)}:${i + 1}: ${linha.trim()}',
];

void main() {
  group('Funcionalidade: telas seguem o design system', () {
    for (final pasta in _pacotesDeTela) {
      final lib = pasta == 'lib' ? pasta : '$pasta/lib';
      for (final MapEntry(key: regra, value: (padrao, solucao))
          in _proibidos.entries) {
        test('Cenário: Dado o $lib, então não há $regra ($solucao)', () {
          expect(_ocorrencias(lib, padrao), isEmpty, reason: solucao);
        });
      }
    }
  });

  group('Funcionalidade: o próprio teste reconhece violações', () {
    for (final (regra, exemplo) in [
      ('cor literal', 'color: Color(0xFF00FF00),'),
      ('cor literal', 'color: Colors.red,'),
      ('número solto em EdgeInsets', 'padding: EdgeInsets.all(16),'),
      (
        'número solto em EdgeInsets',
        'EdgeInsets.only(left: AppEspacamentos.md, top: 8)',
      ),
      ('número solto em SizedBox', 'SizedBox(height: 12)'),
      ('raio literal', 'BorderRadius.circular(10)'),
      ('elevação literal', 'elevation: 2,'),
      ('tamanho de ícone literal', 'Icon(Icons.add, size: 64)'),
      ('estilo de texto avulso', 'style: TextStyle(fontSize: 18)'),
      ('tema escuro', 'darkTheme: AppTheme.escuro(marca),'),
      ('breakpoint literal', 'if (largura < 600) {'),
      ('MediaQuery.of para tamanho', 'MediaQuery.of(context).size.width'),
    ]) {
      test('Cenário: Dado "$exemplo", então a regra "$regra" acusa', () {
        expect(_proibidos[regra]!.$1.hasMatch(exemplo), isTrue);
      });
    }

    for (final exemplo in [
      'color: Colors.transparent,',
      'padding: EdgeInsets.all(AppEspacamentos.md),',
      'SizedBox(height: AppEspacamentos.sm)',
      'Icon(Icons.add, size: AppIcones.padrao)',
      'borderRadius: AppRaios.bordaMd,',
    ]) {
      test('Cenário: Dado "$exemplo", então nenhuma regra acusa', () {
        for (final MapEntry(key: regra, value: (padrao, _))
            in _proibidos.entries) {
          expect(padrao.hasMatch(exemplo), isFalse, reason: regra);
        }
      });
    }
  });
}
