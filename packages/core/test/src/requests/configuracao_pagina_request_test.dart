import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group(
    'Funcionalidade: PATCH da aparência só com o que mudou (plano.md §4.3)',
    () {
      test(
        'Cenário: Dado nada mudou, quando comparo, então o pedido é vazio',
        () {
          final pedido = ConfiguracaoPaginaRequest.entre(
            configuracaoPaginaFake,
            configuracaoPaginaFake,
          );

          expect(pedido.vazio, isTrue);
          expect(pedido.toJson(), isEmpty);
        },
      );

      test('Cenário: Dado banner, categoria e 2 cores alterados, quando comparo, então só essas chaves vão no JSON', () {
        const salvo = ConfiguracaoPaginaResponse.padrao;
        final novo = salvo.copiar(
          banner: const BannerResponse(
            exibir: true,
            nome: 'Semana do Hortifrúti',
            campanha: CampanhaDescricao('Tudo fresquinho'),
          ),
          exibirNomeCategoria: false,
          cores: const CoresPaginaResponse(texto: '#112233', neutra: '#EEEEEE'),
        );

        expect(ConfiguracaoPaginaRequest.entre(salvo, novo).toJson(), {
          'banner': {
            'exibir': true,
            'nome': 'Semana do Hortifrúti',
            'descricao': 'Tudo fresquinho',
          },
          'exibirNomeCategoria': false,
          'cores': {'texto': '#112233', 'neutra': '#EEEEEE'},
        });
      });

      test('Cenário: Dado uma cor e o nome apagados, quando comparo, então vão como null (= padrão / sem nome)', () {
        final novo = configuracaoPaginaFake.copiar(
          banner: const BannerResponse(
            exibir: true,
            urlLogo: 'https://midia.fake/logo/banner.webp',
            campanha: CampanhaFoto('https://midia.fake/banner/foto.webp'),
          ),
          cores: configuracaoPaginaFake.cores.com(CorPagina.primaria, null),
        );

        expect(
          ConfiguracaoPaginaRequest.entre(
            configuracaoPaginaFake,
            novo,
          ).toJson(),
          {
            'banner': {'nome': null},
            'cores': {'primaria': null},
          },
        );
      });

      test('Cenário: Dado a descrição apagada, quando comparo, então descricao vai null', () {
        const salvo = ConfiguracaoPaginaResponse(
          banner: BannerResponse(campanha: CampanhaDescricao('Oferta')),
        );

        expect(
          ConfiguracaoPaginaRequest.entre(
            salvo,
            ConfiguracaoPaginaResponse.padrao,
          ).toJson(),
          {
            'banner': {'descricao': null},
          },
        );
      });

      test('Cenário: Dado só a foto ou o logo diferentes, quando comparo, então nada vai no PATCH (vão pelas rotas de upload)', () {
        final novo = configuracaoPaginaFake.copiar(
          banner: const BannerResponse(
            exibir: true,
            nome: 'Semana do Hortifrúti',
            campanha: CampanhaFoto('https://midia.fake/banner/outra.webp'),
          ),
        );

        expect(
          ConfiguracaoPaginaRequest.entre(configuracaoPaginaFake, novo).vazio,
          isTrue,
        );
      });
    },
  );
}
