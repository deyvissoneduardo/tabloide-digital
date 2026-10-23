import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

void main() {
  group('Funcionalidade: classes de tamanho (Material 3)', () {
    for (final (largura, classe) in [
      (360.0, ClasseTamanho.compacto),
      (599.0, ClasseTamanho.compacto),
      (600.0, ClasseTamanho.medio),
      (839.0, ClasseTamanho.medio),
      (840.0, ClasseTamanho.expandido),
      (1440.0, ClasseTamanho.expandido),
    ]) {
      test(
        'Cenário: Dado a largura $largura, então a classe é ${classe.name}',
        () {
          expect(ClasseTamanho.daLargura(largura), classe);
        },
      );
    }
  });
}
