import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

void main() {
  group('Funcionalidade: converter exceção em Failure', () {
    test('Cenário: Dado uma ação que conclui, quando executo com tentar, então recebo Success com o valor', () async {
      expect(await tentar(() async => 7), const Success<Falha, int>(7));
    });

    test('Cenário: Dado uma ação que lança exceção, quando executo com tentar, então recebo FalhaInesperada guardando a causa', () async {
      final erro = StateError('quebrou');

      final resultado = await tentar<int>(() async => throw erro);

      expect(resultado, Failure<Falha, int>(FalhaInesperada(erro)));
      expect(
        (resultado as Failure<Falha, int>).falha.mensagem,
        isNot(contains('quebrou')),
        reason: 'a causa é para log, não para a tela',
      );
    });
  });
}
