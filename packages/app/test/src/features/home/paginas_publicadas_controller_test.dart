import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _comPanfleto = IdentidadeResponse(
  nomeFantasia: 'Mercado Bom Preço',
  sePanfleto: true,
);

void main() {
  group('Funcionalidade: Páginas publicadas na home', () {
    test('Cenário: Dado lojista ATIVO e sePanfleto com panfleto vigente, então situacao panfleto', () async {
      final controller = paginasPublicadasControllerDeTeste(
        identidade: IdentidadeRepositoryFake(identidade: _comPanfleto),
      );

      await controller.carregar();

      final contexto = (controller.estado as PaginasCarregadas).contexto;
      expect(contexto.contaAtiva, isTrue);
      expect(contexto.nomeFantasia, 'Mercado Bom Preço');
      expect(
        controller.situacaoDe(
          const ResumoFilial(
            filialId: 'f1',
            panfletosVigentes: 1,
            produtosVigentes: 5,
          ),
        ),
        SituacaoPaginaFilial.panfleto,
      );
    });

    test('Cenário: Dado sePanfleto sem panfleto vigente e 5 produtos, então produtos com 5', () async {
      final controller = paginasPublicadasControllerDeTeste(
        identidade: IdentidadeRepositoryFake(identidade: _comPanfleto),
      );
      await controller.carregar();

      expect(
        controller.situacaoDe(
          const ResumoFilial(
            filialId: 'f1',
            panfletosVigentes: 0,
            produtosVigentes: 5,
          ),
        ),
        SituacaoPaginaFilial.produtos,
      );
    });

    test('Cenário: Dado sePanfleto desligado com panfleto vigente e sem produtos, então vazia', () async {
      final controller = paginasPublicadasControllerDeTeste();
      await controller.carregar();

      expect(
        controller.situacaoDe(
          const ResumoFilial(
            filialId: 'f1',
            panfletosVigentes: 1,
            produtosVigentes: 0,
          ),
        ),
        SituacaoPaginaFilial.vazia,
      );
      expect(controller.situacaoDe(null), SituacaoPaginaFilial.vazia);
    });

    test('Cenário: Dado AGUARDANDO_ATIVACAO, então contaAtiva false', () async {
      final controller = paginasPublicadasControllerDeTeste(
        lojista: LojistaRepositoryFake(
          lojista: LojistaResponse(
            id: lojistaFake.id,
            nomeFantasia: lojistaFake.nomeFantasia,
            nomeResponsavel: lojistaFake.nomeResponsavel,
            email: lojistaFake.email,
            whatsapp: lojistaFake.whatsapp,
            cnpj: lojistaFake.cnpj,
            status: 'AGUARDANDO_ATIVACAO',
            criadoEm: lojistaFake.criadoEm,
          ),
        ),
      );

      await controller.carregar();

      expect(
        (controller.estado as PaginasCarregadas).contexto.contaAtiva,
        isFalse,
      );
    });

    test(
      'Cenário: Dado falha ao carregar a identidade, então o estado é de falha',
      () async {
        final controller = paginasPublicadasControllerDeTeste(
          identidade: IdentidadeRepositoryFake(
            falhaSimulada: const FalhaSemConexao(),
          ),
        );

        await controller.carregar();

        expect(controller.estado, isA<PaginasComFalha>());
      },
    );

    test('Cenário: Dado carregarQrCode duas vezes para a mesma filial, então o repository é chamado uma vez', () async {
      final filiais = FilialRepositoryFake(filiais: [filialFake]);
      final controller = paginasPublicadasControllerDeTeste(filiais: filiais);

      await Future.wait([
        controller.carregarQrCode(filialFake.id),
        controller.carregarQrCode(filialFake.id),
      ]);
      await controller.carregarQrCode(filialFake.id);

      expect(filiais.qrCodesPedidos, [filialFake.id]);
      expect(controller.qrCodes[filialFake.id], pngQrCodeFake);
    });

    test('Cenário: Dado falha no QR de uma filial, então só aquele card mostra a falha', () async {
      final filiais = FilialRepositoryFake(
        filiais: [filialFake, filialFakeBairro],
      )..qrCodesComFalha.add(filialFakeBairro.id);
      final controller = paginasPublicadasControllerDeTeste(filiais: filiais);

      await controller.carregarQrCode(filialFake.id);
      await controller.carregarQrCode(filialFakeBairro.id);

      expect(controller.qrCodesComFalha, {filialFakeBairro.id});
      expect(controller.qrCodes[filialFake.id], pngQrCodeFake);
    });
  });
}
