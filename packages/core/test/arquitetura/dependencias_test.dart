@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Raiz do workspace, a partir de `packages/core` (cwd do `flutter test`).
final _raiz = Directory.current.parent.parent;

const _pacotes = {
  'tabloide_core': 'packages/core',
  'tabloide_brands': 'packages/brands',
  'tabloide_app': 'packages/app',
  'tabloide_web': 'packages/web',
};

/// Pacotes do workspace citados em `dependencies` do pubspec de [pasta].
Set<String> _dependenciasDoWorkspace(String pasta) {
  final linhas = File('${_raiz.path}/$pasta/pubspec.yaml').readAsLinesSync();
  final inicio = linhas.indexOf('dependencies:');
  final bloco = linhas
      .skip(inicio + 1)
      .takeWhile((l) => l.isEmpty || l.startsWith(' '));
  return {
    for (final l in bloco)
      if (RegExp(r'^  (tabloide_\w+):').firstMatch(l) case final m?)
        m.group(1)!,
  };
}

/// Arquivos `.dart` de `lib/` de [pasta] que contêm [padrao].
List<String> _arquivosCom(String pasta, Pattern padrao) => [
  for (final f in Directory(
    '${_raiz.path}/$pasta/lib',
  ).listSync(recursive: true))
    if (f is File &&
        f.path.endsWith('.dart') &&
        f.readAsStringSync().contains(padrao))
      f.path.substring(_raiz.path.length + 1),
];

/// Arquivos `.dart` de `lib/` de [pasta] dentro de uma pasta chamada [camada].
List<File> _arquivosDaCamada(String pasta, String camada) => [
  for (final f in Directory(
    '${_raiz.path}/$pasta/lib',
  ).listSync(recursive: true))
    if (f is File &&
        f.path.endsWith('.dart') &&
        f.parent.path.endsWith('/$camada'))
      f,
];

/// Tipo de retorno de cada método público de [arquivo] (indentação de membro).
Map<String, String> _retornosPublicos(File arquivo) => {
  for (final m in RegExp(
    r'^  (?!const |final |static |factory )(\S.*?) ([a-z]\w*)\(',
    multiLine: true,
  ).allMatches(arquivo.readAsStringSync()))
    m.group(2)!: m.group(1)!,
};

/// `Future<Either<Falha, T>>` com `T` sendo um tipo nomeado, nunca `Map`,
/// `Object`, `dynamic`, record ou coleção de `Map`.
final _retornoValido = RegExp(
  r'^Future<Either<Falha, (?!Map\b|Object\b|Record\b|List<Map|List<dynamic|List<Object)[A-Z]\w*(<[A-Z][\w<>, ]*>)?>>$',
);

void main() {
  group('Funcionalidade: regras de dependência entre pacotes', () {
    test('Cenário: Dado o core, então ele não depende de nenhum outro pacote do workspace', () {
      expect(_dependenciasDoWorkspace(_pacotes['tabloide_core']!), isEmpty);
    });

    test('Cenário: Dado o brands, então ele depende só do core', () {
      expect(_dependenciasDoWorkspace(_pacotes['tabloide_brands']!), {
        'tabloide_core',
      });
    });

    for (final pacote in ['tabloide_app', 'tabloide_web']) {
      test(
        'Cenário: Dado o $pacote, então ele depende só do core (não conhece clientes nem a outra plataforma)',
        () {
          expect(_dependenciasDoWorkspace(_pacotes[pacote]!), {
            'tabloide_core',
          });
        },
      );
    }

    test('Cenário: Dado a raiz, então só ela junta todos os pacotes', () {
      expect(_dependenciasDoWorkspace('.'), _pacotes.keys.toSet());
    });
  });

  group('Funcionalidade: imports pelo barrel', () {
    for (final MapEntry(key: nome, value: pasta) in _pacotes.entries) {
      if (nome == 'tabloide_core') continue;
      test(
        'Cenário: Dado o $nome, então nada importa package:tabloide_core/src/',
        () {
          expect(_arquivosCom(pasta, 'package:tabloide_core/src/'), isEmpty);
        },
      );
    }
  });

  group('Funcionalidade: white-label sem cor fixa nas telas', () {
    for (final pasta in ['packages/app', 'packages/web']) {
      test(
        'Cenário: Dado o $pasta, então nenhuma tela usa Color(0x...) literal',
        () {
          expect(_arquivosCom(pasta, RegExp(r'Color\(0x')), isEmpty);
        },
      );
    }
  });

  group('Funcionalidade: camadas de repository e service', () {
    for (final pasta in ['packages/app', 'packages/web']) {
      test(
        'Cenário: Dado o $pasta, então ele não tem repositories (todos ficam no core)',
        () {
          expect(_arquivosDaCamada(pasta, 'repositories'), isEmpty);
          expect(
            _arquivosCom(pasta, RegExp(r'implements \w*Repository\b')),
            isEmpty,
          );
        },
      );

      test(
        'Cenário: Dado os services do $pasta, então cada um recebe o repository por injeção e nunca cria um',
        () {
          final servicos = _arquivosDaCamada(pasta, 'services');
          expect(servicos, isNotEmpty);
          for (final f in servicos) {
            final codigo = f.readAsStringSync();
            expect(
              codigo,
              matches(RegExp(r'final \w*Repository _\w+;')),
              reason: '${f.path} deve guardar o contrato do repository',
            );
            expect(
              codigo,
              isNot(matches(RegExp(r'\w*Repository\w*\('))),
              reason: '${f.path} não pode instanciar repository',
            );
          }
        },
      );
    }

    for (final (pasta, camada) in [
      ('packages/core', 'repositories'),
      ('packages/core', 'services'),
      ('packages/app', 'services'),
      ('packages/web', 'services'),
    ]) {
      test(
        'Cenário: Dado os $camada do $pasta, então todo método público devolve Future<Either<Falha, Modelo>>, nunca objeto literal',
        () {
          final arquivos = _arquivosDaCamada(pasta, camada);
          expect(arquivos, isNotEmpty);
          for (final f in arquivos) {
            final retornos = _retornosPublicos(f);
            expect(retornos, isNotEmpty, reason: '${f.path} sem métodos');
            retornos.forEach((metodo, tipo) {
              expect(
                tipo,
                matches(_retornoValido),
                reason: '${f.path}: $metodo devolve $tipo',
              );
            });
          }
        },
      );
    }
  });
}
