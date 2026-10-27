import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _filial = '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02';

PanfletoResponse _semLimite() => PanfletoResponse(
  id: panfletoFake.id,
  filialId: panfletoFake.filialId,
  tipo: panfletoFake.tipo,
  urlArquivo: panfletoFake.urlArquivo,
  largura: panfletoFake.largura,
  altura: panfletoFake.altura,
  vigencia: Vigencia(
    dataInicio: panfletoFake.vigencia.dataInicio,
    situacao: SituacaoVigencia.vigente,
    editavel: true,
  ),
  criadoEm: panfletoFake.criadoEm,
);

void main() {
  group('Funcionalidade: lista de panfletos da filial na web', () {
    late PanfletoRepositoryFake repository;
    late PanfletosController controller;

    setUp(() {
      repository = PanfletoRepositoryFake(
        panfletos: [panfletoFakeAgendado, panfletoFake],
      );
      controller = panfletosControllerDeTeste(repository: repository);
    });

    test('Cenário: Dado panfletos na API, quando carrego a filial, então ficam ordenados pela data de início', () async {
      await controller.carregar(_filial);

      expect(controller.filialId, _filial);
      expect(controller.panfletos, [panfletoFake, panfletoFakeAgendado]);
    });

    test('Cenário: Dado a API falhando, quando carrego, então o estado guarda a falha', () async {
      repository.falhaSimulada = const FalhaSemConexao();

      await controller.carregar(_filial);

      expect(
        controller.estado,
        isA<PanfletosComFalha>().having(
          (e) => e.falha,
          'falha',
          const FalhaSemConexao(),
        ),
      );
    });

    test('Cenário: Dado um panfleto novo salvo, quando aviso a lista, então ele entra na ordem certa; um editado é substituído', () async {
      repository.panfletos.remove(panfletoFakeAgendado);
      await controller.carregar(_filial);

      controller.salvo(panfletoFakeAgendado);
      final editado = _semLimite();
      controller.salvo(editado);

      expect(controller.panfletos, [editado, panfletoFakeAgendado]);
    });

    test('Cenário: Dado um panfleto de outra filial, quando aviso a lista, então ela não muda', () async {
      await controller.carregar('outra-filial');

      controller.salvo(panfletoFake);

      expect(controller.panfletos, [panfletoFake, panfletoFakeAgendado]);
    });

    test('Cenário: Dado o vigente sem data limite, então a lista avisa que é preciso defini-la antes de agendar (RN17)', () async {
      expect(controller.atualSemDataLimite, isFalse);
      repository.panfletos
        ..clear()
        ..add(_semLimite());

      await controller.carregar(_filial);

      expect(controller.atualSemDataLimite, isTrue);
    });

    test('Cenário: Dado um panfleto, quando excluo, então ele sai da lista; com falha, fica', () async {
      await controller.carregar(_filial);

      repository.falhaSimulada = const FalhaSemConexao();
      expect((await controller.excluir(panfletoFake)).isSuccess, isFalse);
      expect(controller.panfletos, hasLength(2));

      repository.falhaSimulada = null;
      expect((await controller.excluir(panfletoFake)).isSuccess, isTrue);
      expect(controller.panfletos, [panfletoFakeAgendado]);
      expect(repository.excluidos, [panfletoFake.id, panfletoFake.id]);
    });
  });
}
