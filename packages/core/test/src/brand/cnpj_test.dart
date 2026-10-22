import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/src/brand/cnpj.dart';

void main() {
  group('Funcionalidade: validação de CNPJ', () {
    group('Esquema do Cenário: Dado o CNPJ <valor>', () {
      const casos = <(String, bool, String)>[
        ('11222333000181', true, 'numérico válido'),
        ('11.222.333/0001-81', true, 'numérico com máscara'),
        ('11444777000161', true, 'outro numérico válido'),
        ('11222333000182', false, 'segundo DV errado'),
        ('11222333000171', false, 'primeiro DV errado'),
        ('00000000000000', false, 'todos os dígitos iguais'),
        ('1122233300018', false, 'tamanho menor'),
        ('112223330001811', false, 'tamanho maior'),
        ('12ABC34501DE35', true, 'alfanumérico válido'),
        ('12abc34501de35', true, 'alfanumérico em minúsculas'),
        ('12.ABC.345/01DE-35', true, 'alfanumérico com máscara'),
        ('12ABC34501DE36', false, 'alfanumérico com DV errado'),
        ('12ABC34501DE3A', false, 'letra no dígito verificador'),
        ('', false, 'vazio'),
      ];

      for (final (valor, esperado, descricao) in casos) {
        test(
          'Quando valido "$valor" ($descricao), então o resultado é $esperado',
          () {
            expect(cnpjValido(valor), esperado);
          },
        );
      }
    });
  });
}
