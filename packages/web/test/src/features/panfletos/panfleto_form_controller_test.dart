import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

class _PanfletoRepositoryMock extends Mock implements PanfletoRepository {}

const _filial = '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02';

final _bytes = Uint8List.fromList([1, 2, 3]);

void main() {
  setUpAll(() => registerFallbackValue(const PanfletoRequest()));

  group('Funcionalidade: formulário de panfleto na web', () {
    late PanfletoRepositoryFake repository;
    late PanfletoFormController controller;

    setUp(() {
      repository = PanfletoRepositoryFake(
        panfletos: [panfletoFake, panfletoFakeAgendado],
      );
      controller = panfletoFormControllerDeTeste(repository: repository);
    });

    test('Cenário: Dado nenhum arquivo escolhido, quando publico, então peço a imagem no campo e nada é enviado', () async {
      await controller.salvar(filialId: _filial);

      expect(controller.erroDoCampo('imagem'), 'Escolha a imagem do panfleto.');
      expect(controller.estado, isA<PanfletoFormOcioso>());
      expect(repository.pedidos, isEmpty);
    });

    test('Cenário: Dado uma imagem acima de 10 MB, quando escolho, então recuso no campo antes do envio (RNF05)', () {
      controller.escolherImagem(Uint8List(maxBytesPanfleto + 1), 'grande.jpg');

      expect(controller.imagem, isNull);
      expect(
        controller.erroDoCampo('imagem'),
        'A imagem passa de 10 MB. Escolha uma menor.',
      );

      controller.escolherImagem(_bytes, 'ok.jpg');

      expect(controller.imagem?.nome, 'ok.jpg');
      expect(controller.erroDoCampo('imagem'), isNull);
    });

    test('Cenário: Dado imagem e datas, quando publico, então envio tudo junto e concluo com o panfleto', () async {
      final inicio = DataDia.hoje().add(const Duration(days: 10));
      final limite = inicio.add(const Duration(days: 7));
      controller.escolherImagem(_bytes, 'folheto.jpg');

      await controller.salvar(
        filialId: _filial,
        dataInicio: inicio,
        dataLimite: limite,
      );

      expect(repository.pedidos, [
        PanfletoRequest(dataInicio: inicio, dataLimite: limite),
      ]);
      expect(repository.imagensEnviadas, ['folheto.jpg']);
      expect(
        controller.estado,
        isA<PanfletoFormConcluido>().having(
          (e) => e.panfleto.vigencia.situacao,
          'situação',
          SituacaoVigencia.agendado,
        ),
      );
    });

    test('Cenário: Dado um panfleto vigente, quando mudo início e data limite, então só a data limite vai no PATCH (RN26)', () async {
      final limite = DateTime(2027, 1, 15);

      await controller.salvar(
        filialId: _filial,
        panfleto: panfletoFake,
        dataInicio: DateTime(2027),
        dataLimite: limite,
      );

      expect(repository.pedidos, [PanfletoRequest(dataLimite: limite)]);
      expect(repository.imagensEnviadas, isEmpty);
    });

    test('Cenário: Dado um panfleto agendado, quando mudo a data de início, então ela vai no PATCH', () async {
      final inicio = DateTime(2026, 11, 3);

      await controller.salvar(
        filialId: _filial,
        panfleto: panfletoFakeAgendado,
        dataInicio: inicio,
      );

      expect(repository.pedidos, [PanfletoRequest(dataInicio: inicio)]);
    });

    test('Cenário: Dado nada alterado além da imagem, quando salvo, então não faço PATCH e troco só a imagem', () async {
      controller.escolherImagem(_bytes, 'novo.png');

      await controller.salvar(
        filialId: _filial,
        panfleto: panfletoFake,
        dataInicio: panfletoFake.vigencia.dataInicio,
        dataLimite: panfletoFake.vigencia.dataLimite,
      );

      expect(repository.pedidos, isEmpty);
      expect(repository.imagensEnviadas, ['novo.png']);
      expect(
        controller.estado,
        isA<PanfletoFormConcluido>().having(
          (e) => e.panfleto.urlImagem,
          'url',
          'https://midia.fake/panfleto/novo.png',
        ),
      );
    });

    test('Cenário: Dado as datas salvas e a troca de imagem falhando, quando salvo, então a falha leva o panfleto com as datas novas', () async {
      final mock = _PanfletoRepositoryMock();
      final comDatas = PanfletoResponse(
        id: panfletoFake.id,
        filialId: panfletoFake.filialId,
        urlImagem: panfletoFake.urlImagem,
        largura: panfletoFake.largura,
        altura: panfletoFake.altura,
        vigencia: Vigencia(
          dataInicio: panfletoFake.vigencia.dataInicio,
          dataLimite: DateTime(2027, 1, 15),
          situacao: SituacaoVigencia.vigente,
          editavel: true,
        ),
        criadoEm: panfletoFake.criadoEm,
      );
      when(() => mock.editar(any(), any(), any()))
          .thenAnswer((_) async => Success(comDatas));
      when(
        () => mock.trocarImagem(
          any(),
          any(),
          bytes: any(named: 'bytes'),
          nomeArquivo: any(named: 'nomeArquivo'),
        ),
      ).thenAnswer((_) async => const Failure(FalhaSemConexao()));
      controller = panfletoFormControllerDeTeste(repository: mock)
        ..escolherImagem(_bytes, 'novo.png');

      await controller.salvar(
        filialId: _filial,
        panfleto: panfletoFake,
        dataLimite: DateTime(2027, 1, 15),
      );

      expect(
        controller.estado,
        isA<PanfletoFormComFalha>()
            .having((e) => e.falha, 'falha', const FalhaSemConexao())
            .having((e) => e.atualizado, 'atualizado', comDatas),
      );
    });

    test('Cenário: Dado só a troca de imagem falhando, quando salvo, então a falha não leva panfleto atualizado', () async {
      repository.falhaSimulada = const FalhaSemConexao();
      controller.escolherImagem(_bytes, 'novo.png');

      await controller.salvar(
        filialId: _filial,
        panfleto: panfletoFake,
        dataInicio: panfletoFake.vigencia.dataInicio,
        dataLimite: panfletoFake.vigencia.dataLimite,
      );

      expect(
        controller.estado,
        isA<PanfletoFormComFalha>().having(
          (e) => e.atualizado,
          'atualizado',
          isNull,
        ),
      );
    });

    test('Cenário: Dado a API com erro de campo, quando salvo, então o erro vai para o campo da data', () async {
      const mensagem =
          'A data limite não pode ser anterior à data de início nem a hoje.';
      repository.falhaSimulada = const FalhaApi(
        codigo: 'DATA_LIMITE_INVALIDA',
        mensagem: mensagem,
        campos: {
          'dataLimite': [mensagem],
        },
      );
      controller.escolherImagem(_bytes, 'p.jpg');

      await controller.salvar(filialId: _filial, dataLimite: DateTime(2026));

      expect(controller.erroDoCampo('dataLimite'), mensagem);
      expect(controller.estado, isA<PanfletoFormComFalha>());

      controller.limparErroDoCampo('dataLimite');
      expect(controller.erroDoCampo('dataLimite'), isNull);
    });

    test('Cenário: Dado a API recusando a imagem, quando publico, então o erro vai para o campo da imagem', () async {
      repository.falhaSimulada = const FalhaApi(
        codigo: 'IMAGEM_INVALIDA',
        mensagem: 'Envie uma imagem JPEG, PNG ou WebP válida.',
      );
      controller.escolherImagem(_bytes, 'animacao.gif');

      await controller.salvar(filialId: _filial);

      expect(
        controller.erroDoCampo('imagem'),
        'Envie uma imagem JPEG, PNG ou WebP válida.',
      );
    });

    test('Cenário: Dado o formulário usado, quando reinicio, então volta ao estado inicial sem imagem nem erros', () async {
      await controller.salvar(filialId: _filial);
      controller.escolherImagem(_bytes, 'p.jpg');

      controller.reiniciar();

      expect(controller.estado, isA<PanfletoFormOcioso>());
      expect(controller.imagem, isNull);
      expect(controller.erroDoCampo('imagem'), isNull);
    });
  });
}
