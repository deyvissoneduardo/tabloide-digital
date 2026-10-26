import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

Map<String, Object?> corpoIdentidade({
  Object? corPrimaria = '#C8102E',
  Object? corSecundaria = '#FFD100',
  Object? urlLogo =
      'https://xyz.supabase.co/storage/v1/object/public/midia/'
      '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01/logo/0192f0e0.webp',
}) => {
  'nomeFantasia': 'Mercado Bom Preço',
  'corPrimaria': corPrimaria,
  'corSecundaria': corSecundaria,
  'urlLogo': urlLogo,
};

void main() {
  group('Funcionalidade: ler e enviar identidade visual', () {
    test('Cenário: Dado o corpo 200 da API, quando leio, então todos os campos viram tipos do Dart', () {
      expect(IdentidadeResponse.fromJson(corpoIdentidade()), identidadeFake);
    });

    test('Cenário: Dado um lojista sem cores e sem logo, quando leio, então esses campos ficam nulos', () {
      final identidade = IdentidadeResponse.fromJson(
        corpoIdentidade(corPrimaria: null, corSecundaria: null, urlLogo: null),
      );

      expect(
        identidade,
        const IdentidadeResponse(nomeFantasia: 'Mercado Bom Preço'),
      );
    });

    test('Cenário: Dado um corpo sem nome fantasia, quando leio, então lanço FormatException', () {
      expect(
        () => IdentidadeResponse.fromJson({'corPrimaria': '#C8102E'}),
        throwsFormatException,
      );
    });

    test('Cenário: Dado um pedido sem cor secundária, quando gero o JSON, então envio null para remover a cor', () {
      const pedido = IdentidadeRequest(
        nomeFantasia: 'Mercado Bom Preço',
        corPrimaria: '#C8102E',
      );

      expect(pedido.toJson(), {
        'nomeFantasia': 'Mercado Bom Preço',
        'corPrimaria': '#C8102E',
        'corSecundaria': null,
      });
    });
  });
}
