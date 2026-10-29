import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

Map<String, Object?> _cores([Map<String, Object?> valores = const {}]) => {
  for (final cor in CorPagina.values) cor.name: valores[cor.name],
};

/// Exemplo do plano.md §4.2.
Map<String, Object?> corpoConfiguracaoPagina() => {
  'banner': {
    'exibir': true,
    'nome': 'Semana do Hortifrúti',
    'urlLogo': 'https://midia.fake/logo/banner.webp',
    'campanha': {
      'tipo': 'FOTO',
      'urlFoto': 'https://midia.fake/banner/foto.webp',
    },
  },
  'exibirNomeCategoria': false,
  'cores': _cores({'primaria': '#C8102E', 'fundoBanner': '#0B3D91'}),
};

void main() {
  group('Funcionalidade: aparência da página vinda da API (plano.md §4.2)', () {
    test('Cenário: Dado o exemplo do contrato, quando leio, então banner, campanha FOTO, categoria e cores batem', () {
      expect(
        ConfiguracaoPaginaResponse.fromJson(corpoConfiguracaoPagina()),
        configuracaoPaginaFake,
      );
    });

    test('Cenário: Dado tudo null e banner desligado, quando leio, então é a configuração padrão', () {
      expect(
        ConfiguracaoPaginaResponse.fromJson({
          'banner': {
            'exibir': false,
            'nome': null,
            'urlLogo': null,
            'campanha': null,
          },
          'exibirNomeCategoria': true,
          'cores': _cores(),
        }),
        ConfiguracaoPaginaResponse.padrao,
      );
    });

    test('Cenário: Dado campanha DESCRICAO, quando leio, então CampanhaDescricao com o texto', () {
      final corpo = corpoConfiguracaoPagina();
      (corpo['banner']! as Map<String, Object?>)['campanha'] = {
        'tipo': 'DESCRICAO',
        'descricao': 'Tudo fresquinho',
      };

      expect(
        ConfiguracaoPaginaResponse.fromJson(corpo).banner.campanha,
        const CampanhaDescricao('Tudo fresquinho'),
      );
    });

    for (final (nome, alterar)
        in <(String, void Function(Map<String, Object?>))>[
          ('sem cores', (c) => c.remove('cores')),
          (
            'sem uma das 10 cores',
            (c) => (c['cores']! as Map).remove('neutra'),
          ),
          (
            'campanha de tipo desconhecido',
            (c) {
              (c['banner']! as Map)['campanha'] = {'tipo': 'VIDEO'};
            },
          ),
          (
            'exibir null',
            (c) {
              c['banner'] = <String, Object?>{
                ...(c['banner']! as Map<String, Object?>),
                'exibir': null,
              };
            },
          ),
        ]) {
      test(
        'Cenário: Dado um corpo $nome, quando leio, então lanço FormatException',
        () {
          final corpo = corpoConfiguracaoPagina();
          alterar(corpo);

          expect(
            () => ConfiguracaoPaginaResponse.fromJson(corpo),
            throwsFormatException,
          );
        },
      );
    }

    test(
      'Cenário: Dado as cores, quando troco uma pela chave, então só ela muda',
      () {
        const cores = CoresPaginaResponse(primaria: '#C8102E');

        final novas = cores.com(CorPagina.neutra, '#EEEEEE');

        expect(novas.primaria, '#C8102E');
        expect(novas[CorPagina.neutra], '#EEEEEE');
        expect(novas.com(CorPagina.neutra, null), cores);
      },
    );
  });
}
