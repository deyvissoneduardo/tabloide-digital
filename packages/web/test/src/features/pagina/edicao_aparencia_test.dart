import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

final _imagem = ImagemPendente(
  bytes: Uint8List.fromList([1, 2, 3]),
  nomeArquivo: 'foto.png',
);

void main() {
  group('Funcionalidade: Aparência em edição (T6)', () {
    final salva = EdicaoAparencia.de(configuracaoPaginaFake);

    test('Cenário: Dado a configuração salva, quando crio a edição, então a configuração derivada é a mesma', () {
      expect(salva.configuracao, configuracaoPaginaFake);
      expect(salva.tipoCampanha, TipoCampanha.foto);
      expect(salva.mudouDesde(configuracaoPaginaFake), isFalse);
    });

    test('Cenário: Dado foto pendente, quando troco Foto → Descrição, então a foto pendente é descartada', () {
      final edicao = salva
          .comFoto(_imagem)
          .comTipoCampanha(TipoCampanha.descricao);

      expect(edicao.foto, isNull);
      expect(edicao.bytesFoto, isNull);
      expect(edicao.enviaFoto, isFalse);
    });

    test('Cenário: Dado o banner desligado, quando desligo e religo, então os valores são mantidos', () {
      final edicao = salva.comExibirBanner(false).comExibirBanner(true);

      expect(edicao.configuracao, configuracaoPaginaFake);
    });

    test('Cenário: Dado descrição digitada e tipo Foto, quando volto para Descrição, então o texto continua', () {
      final edicao = salva
          .comTipoCampanha(TipoCampanha.descricao)
          .comDescricao('  Oferta  ')
          .comTipoCampanha(TipoCampanha.foto)
          .comTipoCampanha(TipoCampanha.descricao);

      expect(
        edicao.configuracao.banner.campanha,
        const CampanhaDescricao('Oferta'),
      );
    });

    test('Cenário: Dado cor apagada ou minúscula, quando edito, então null = padrão e o hex fica maiúsculo', () {
      final edicao = salva
          .comCor(CorPagina.primaria, null)
          .comCor(CorPagina.texto, '#abcdef');

      expect(edicao.cores.primaria, isNull);
      expect(edicao.cores.texto, '#ABCDEF');
      expect(edicao.pedido(configuracaoPaginaFake).toJson(), {
        'cores': {'primaria': null, 'texto': '#ABCDEF'},
      });
    });

    test('Cenário: Dado foto salva removida com tipo Foto, então a remoção é pendente e a prévia fica sem campanha', () {
      final edicao = salva.semFoto();

      expect(edicao.removeFoto(configuracaoPaginaFake), isTrue);
      expect(edicao.configuracao.banner.campanha, isNull);
      expect(edicao.mudouDesde(configuracaoPaginaFake), isTrue);
    });

    test('Cenário: Dado nome com espaços extras ou vazio, quando edito, então normalizo ou viro null', () {
      expect(salva.comNomeBanner('  a   b ').nomeBanner, 'a b');
      expect(salva.comNomeBanner('   ').nomeBanner, isNull);
    });
  });
}
