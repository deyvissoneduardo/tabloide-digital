import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

ConfiguracaoPaginaResponse? _valor(
  Either<Falha, ConfiguracaoPaginaResponse> resultado,
) => resultado.fold((_) => null, (c) => c);

void main() {
  group('Funcionalidade: aparência da página em memória para testes', () {
    test('Cenário: Dado uma descrição, quando edito, então a campanha vira DESCRICAO e as cores ficam maiúsculas', () async {
      final fake = ConfiguracaoPaginaRepositoryFake(
        configuracao: configuracaoPaginaFake,
      );
      final pedido = ConfiguracaoPaginaRequest.entre(
        configuracaoPaginaFake,
        configuracaoPaginaFake.copiar(
          banner: const BannerResponse(
            exibir: true,
            nome: 'Semana do Hortifrúti',
            urlLogo: 'https://midia.fake/logo/banner.webp',
            campanha: CampanhaDescricao('Tudo fresquinho'),
          ),
          cores: configuracaoPaginaFake.cores.com(CorPagina.texto, '#abcdef'),
        ),
      );

      final nova = _valor(await fake.editar(pedido))!;

      expect(nova.banner.campanha, const CampanhaDescricao('Tudo fresquinho'));
      expect(nova.cores.texto, '#ABCDEF');
      expect(fake.chamadas, ['PATCH']);
    });

    test('Cenário: Dado uploads e remoções, quando chamo, então a configuração acompanha e registro a ordem', () async {
      final fake = ConfiguracaoPaginaRepositoryFake();

      await fake.enviarLogoBanner(bytes: [1], nomeArquivo: 'logo.png');
      await fake.enviarFotoBanner(bytes: [1], nomeArquivo: 'foto.png');
      expect(
        fake.configuracao.banner.campanha,
        const CampanhaFoto('https://midia.fake/banner/foto.png'),
      );
      await fake.removerFotoBanner();
      await fake.removerLogoBanner();

      expect(fake.configuracao.banner.campanha, isNull);
      expect(fake.configuracao.banner.urlLogo, isNull);
      expect(fake.chamadas, [
        'PUT logo',
        'PUT foto',
        'DELETE foto',
        'DELETE logo',
      ]);
    });

    test('Cenário: Dado falha só no envio, quando edito e envio, então o PATCH passa e o upload falha', () async {
      final fake = ConfiguracaoPaginaRepositoryFake(
        falhaAoEnviar: const FalhaSemConexao(),
      );

      expect(
        (await fake.editar(
          ConfiguracaoPaginaRequest.entre(
            ConfiguracaoPaginaResponse.padrao,
            const ConfiguracaoPaginaResponse(exibirNomeCategoria: false),
          ),
        )).isSuccess,
        isTrue,
      );
      expect(
        await fake.enviarFotoBanner(bytes: [1], nomeArquivo: 'f.png'),
        const Failure<Falha, ConfiguracaoPaginaResponse>(FalhaSemConexao()),
      );
    });
  });
}
