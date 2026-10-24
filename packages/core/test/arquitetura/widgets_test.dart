@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _raiz = Directory.current.parent.parent;

const _pacotes = ['packages/core', 'packages/app', 'packages/web'];

final _widget = RegExp(
  r'^(?:final\s+)?class\s+\w+\s+extends\s+(?:StatelessWidget|StatefulWidget)\b',
  multiLine: true,
);

final _funcaoQueRetornaWidget = RegExp(
  r'^\s*(?:static\s+)?(?:Widget|PreferredSizeWidget)\??\s+(?:get\s+)?(?!build\b)[A-Za-z_]\w*\s*(?:\(|=>|\{)',
);

List<File> _arquivosDart(String pacote) => [
  for (final f in Directory(
    '${_raiz.path}/$pacote/lib',
  ).listSync(recursive: true))
    if (f is File && f.path.endsWith('.dart')) f,
];

String _relativo(File f) => f.path.substring(_raiz.path.length + 1);

void main() {
  group('Funcionalidade: uma tela, um widget', () {
    for (final pacote in _pacotes) {
      test(
        'Cenário: Dado as _screen do $pacote, então cada arquivo tem um único StatelessWidget ou StatefulWidget',
        () {
          final telas = _arquivosDart(pacote)
              .where((f) => f.path.endsWith('_screen.dart'));
          final violacoes = [
            for (final f in telas)
              if (_widget.allMatches(f.readAsStringSync()).length != 1)
                '${_relativo(f)}: ${_widget.allMatches(f.readAsStringSync()).length} widgets',
          ];
          expect(
            violacoes,
            isEmpty,
            reason:
                'widget auxiliar vai para um arquivo próprio ou para o core',
          );
        },
      );
    }
  });

  group('Funcionalidade: widget é classe, nunca função', () {
    for (final pacote in _pacotes) {
      test(
        'Cenário: Dado o $pacote/lib, então nenhuma função ou método retorna Widget (fora o build)',
        () {
          final violacoes = [
            for (final f in _arquivosDart(pacote))
              for (final (i, linha) in f.readAsLinesSync().indexed)
                if (_funcaoQueRetornaWidget.hasMatch(linha))
                  '${_relativo(f)}:${i + 1}: ${linha.trim()}',
          ];
          expect(
            violacoes,
            isEmpty,
            reason: 'crie um widget em arquivo próprio (ou no core, se repete)',
          );
        },
      );
    }
  });

  group('Funcionalidade: o próprio teste reconhece violações', () {
    for (final exemplo in [
      '    Widget campo({',
      '  Widget _cabecalho(BuildContext context) => Text(x);',
      '  static Widget montar() {',
      '  Widget get titulo => const Text(x);',
      '  PreferredSizeWidget barra() => AppBar();',
      'Widget? opcional(int i) => null;',
    ]) {
      test('Cenário: Dado "$exemplo", então a regra de função acusa', () {
        expect(_funcaoQueRetornaWidget.hasMatch(exemplo), isTrue);
      });
    }

    for (final exemplo in [
      '  Widget build(BuildContext context) {',
      '  Widget build(BuildContext context) => const SizedBox();',
      '  final Widget child;',
      '  required Widget child,',
      '  final List<Widget> children;',
      '  State<CadastroScreen> createState() => _CadastroScreenState();',
    ]) {
      test('Cenário: Dado "$exemplo", então a regra de função não acusa', () {
        expect(_funcaoQueRetornaWidget.hasMatch(exemplo), isFalse);
      });
    }

    test('Cenário: Dado um arquivo com tela e widget privado, então conta 2 widgets; com Stateful + State, conta 1', () {
      const doisWidgets = '''
class HomeScreen extends StatelessWidget {}
class _Marca extends StatelessWidget {}
''';
      const statefulComState = '''
class LoginScreen extends StatefulWidget {}
class _LoginScreenState extends State<LoginScreen> {}
''';
      expect(_widget.allMatches(doisWidgets).length, 2);
      expect(_widget.allMatches(statefulComState).length, 1);
    });
  });
}
