import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

String _hex(Color cor) => AppCoresPagina.paraHex(cor);

Map<CorPagina, String> _resolvidas(AppCoresPagina cores) => {
  CorPagina.primaria: _hex(cores.primaria),
  CorPagina.secundaria: _hex(cores.secundaria),
  CorPagina.texto: _hex(cores.texto),
  CorPagina.textoSuave: _hex(cores.textoSuave),
  CorPagina.fundoCartao: _hex(cores.fundoCartao),
  CorPagina.fundoPagina: _hex(cores.fundoPagina),
  CorPagina.neutra: _hex(cores.neutra),
  CorPagina.sobreCor: _hex(cores.sobreCor),
  CorPagina.fundoBanner: _hex(cores.fundoBanner),
  CorPagina.categoria: _hex(cores.categoria),
};

/// Tabela de padrões do plano.md §4.4 (a mesma da API e do React).
const _padroes = {
  CorPagina.primaria: '#1565C0',
  CorPagina.secundaria: '#996B00',
  CorPagina.texto: '#1F1F1F',
  CorPagina.textoSuave: '#5C5C5C',
  CorPagina.fundoCartao: '#FFFFFF',
  CorPagina.fundoPagina: '#F3F4F6',
  CorPagina.neutra: '#EEEEEE',
  CorPagina.sobreCor: '#FFFFFF',
  CorPagina.fundoBanner: '#1565C0',
  CorPagina.categoria: '#1565C0',
};

/// 10 cores distintas, todas escolhidas.
const _distintas = CoresPaginaResponse(
  primaria: '#C8102E',
  secundaria: '#FFD100',
  texto: '#112233',
  textoSuave: '#445566',
  fundoCartao: '#FFF8E1',
  fundoPagina: '#E8F5E9',
  neutra: '#E0E0E0',
  sobreCor: '#FFFDE7',
  fundoBanner: '#0B3D91',
  categoria: '#0B8043',
);

void main() {
  group('Funcionalidade: 10 cores da página (plano.md §4.4, U13, U14)', () {
    test('Cenário: Dado nenhuma cor escolhida, quando resolvo, então cada chave recebe o padrão da tabela', () {
      expect(_resolvidas(AppCoresPagina.de()), _padroes);
    });

    test('Cenário: Dado as 10 cores escolhidas, quando resolvo, então cada uma volta exata', () {
      expect(_resolvidas(AppCoresPagina.de(_distintas)), {
        for (final cor in CorPagina.values) cor: _distintas[cor],
      });
    });

    for (final (entrada, esperado) in [
      ('#FFD100', '#FFD100'),
      ('#FFFFFF', '#FFFFFF'),
      ('#00FF00', '#00FF00'),
      ('#ffd100', '#1565C0'),
      ('FFD100', '#1565C0'),
      ('#FFD10', '#1565C0'),
      ('#GGGGGG', '#1565C0'),
    ]) {
      test(
        'Cenário: Dado a primária $entrada, quando resolvo, então a cor é $esperado (exata ou padrão, sem ajuste de contraste)',
        () {
          final cores = AppCoresPagina.de(
            CoresPaginaResponse(primaria: entrada),
          );

          expect(_hex(cores.primaria), esperado);
        },
      );
    }

    test('Cenário: Dado só a primária escolhida, quando resolvo, então fundoBanner e categoria seguem a primária escolhida', () {
      final cores = AppCoresPagina.de(
        const CoresPaginaResponse(primaria: '#C8102E'),
      );

      expect(_hex(cores.fundoBanner), '#C8102E');
      expect(_hex(cores.categoria), '#C8102E');
    });

    test('Cenário: Dado fundoBanner e categoria escolhidos, quando resolvo, então valem sobre a primária', () {
      final cores = AppCoresPagina.de(
        const CoresPaginaResponse(
          primaria: '#C8102E',
          fundoBanner: '#0B3D91',
          categoria: '#0B8043',
        ),
      );

      expect(_hex(cores.fundoBanner), '#0B3D91');
      expect(_hex(cores.categoria), '#0B8043');
    });

    test('Cenário: Dado fundoBanner inválido e primária padrão, quando resolvo, então fundoBanner é a primária padrão', () {
      final cores = AppCoresPagina.de(
        const CoresPaginaResponse(fundoBanner: 'azul'),
      );

      expect(_hex(cores.fundoBanner), '#1565C0');
    });
  });
}
