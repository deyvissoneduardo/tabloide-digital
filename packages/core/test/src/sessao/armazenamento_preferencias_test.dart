import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabloide_core/tabloide_core.dart';

class _PreferenciasMock extends Mock implements SharedPreferencesAsync {}

void main() {
  group('Funcionalidade: cache com shared_preferences', () {
    test('Cenário: Dado as preferências, quando leio, gravo e removo, então cada chamada vai para a mesma chave', () async {
      final preferencias = _PreferenciasMock();
      when(() => preferencias.getString('k')).thenAnswer((_) async => 'v');
      when(() => preferencias.setString('k', 'v')).thenAnswer((_) async {});
      when(() => preferencias.remove('k')).thenAnswer((_) async {});
      final armazenamento = ArmazenamentoPreferencias(
        preferencias: preferencias,
      );

      expect(await armazenamento.ler('k'), 'v');
      await armazenamento.gravar('k', 'v');
      await armazenamento.remover('k');

      verify(() => preferencias.setString('k', 'v')).called(1);
      verify(() => preferencias.remove('k')).called(1);
    });
  });
}
