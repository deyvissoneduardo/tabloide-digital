import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

Map<String, Object?> corpoIdentidade({
  Object? corPrimaria = '#C8102E',
  Object? corSecundaria = '#FFD100',
  Object? urlLogo =
      'https://xyz.supabase.co/storage/v1/object/public/midia/'
      '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01/logo/0192f0e0.webp',
  bool sePanfleto = false,
}) => {
  'nomeFantasia': 'Mercado Bom Preço',
  'corPrimaria': corPrimaria,
  'corSecundaria': corSecundaria,
  'urlLogo': urlLogo,
  'sePanfleto': sePanfleto,
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
        sePanfleto: false,
        corPrimaria: '#C8102E',
      );

      expect(pedido.toJson(), {
        'nomeFantasia': 'Mercado Bom Preço',
        'corPrimaria': '#C8102E',
        'corSecundaria': null,
        'sePanfleto': false,
      });
    });

    test('Cenário: Dado sePanfleto true no corpo, quando leio, então a identidade liga a chave (RN44)', () {
      expect(
        IdentidadeResponse.fromJson(corpoIdentidade(sePanfleto: true))
            .sePanfleto,
        isTrue,
      );
    });

    test('Cenário: Dado um corpo sem sePanfleto, quando leio, então lanço FormatException', () {
      expect(
        () => IdentidadeResponse.fromJson(
          {...corpoIdentidade()}..remove('sePanfleto'),
        ),
        throwsFormatException,
      );
    });

    test('Cenário: Dado a chave ligada no pedido, quando gero o JSON, então envio sePanfleto true', () {
      const pedido = IdentidadeRequest(
        nomeFantasia: 'Mercado Bom Preço',
        sePanfleto: true,
      );

      expect(pedido.toJson()['sePanfleto'], isTrue);
    });
  });
}
