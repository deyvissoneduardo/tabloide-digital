import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_core/tabloide_core.dart';

class _HomeServiceMock extends Mock implements HomeService {}

const _filiais = ['f1', 'f2'];

const _resumo = ResumoPainel(panfletosVigentes: 1, produtosVigentes: 10);

void main() {
  late _HomeServiceMock service;
  late HomeController controller;
  late int avisos;

  setUp(() {
    service = _HomeServiceMock();
    controller = HomeController(service);
    avisos = 0;
    controller.addListener(() => avisos++);
  });
  tearDown(() => controller.dispose());

  group('Funcionalidade: navegação do painel', () {
    group('Cenário: Dado que o painel acabou de abrir', () {
      test('Então a seção selecionada é Início', () {
        expect(controller.secao, SecaoPainel.inicio);
      });

      test('Quando seleciono Filiais, então a seção muda e os ouvintes são avisados', () {
        controller.selecionar(SecaoPainel.filiais);

        expect(controller.secao, SecaoPainel.filiais);
        expect(avisos, 1);
      });

      test('Quando seleciono a seção atual, então ninguém é avisado', () {
        controller.selecionar(SecaoPainel.inicio);

        expect(avisos, 0);
      });
    });
  });

  group('Funcionalidade: resumo da seção Início', () {
    test(
      'Cenário: Dado o controller novo, então o resumo começa carregando',
      () {
        expect(controller.resumo, isA<ResumoCarregando>());
      },
    );

    test('Cenário: Dado que o service responde Success, quando carrego, então o estado vira ResumoCarregado com os dados', () async {
      when(() => service.buscarResumo(_filiais))
          .thenAnswer((_) async => const Success(_resumo));

      await controller.carregarResumo(_filiais);

      expect(
        controller.resumo,
        isA<ResumoCarregado>().having((e) => e.resumo, 'resumo', _resumo),
      );
      expect(avisos, 2, reason: 'avisa ao começar e ao terminar');
      verify(() => service.buscarResumo(_filiais)).called(1);
    });

    test('Cenário: Dado que o service responde Failure, quando carrego, então o estado vira ResumoComFalha', () async {
      when(() => service.buscarResumo(_filiais))
          .thenAnswer((_) async => const Failure(FalhaSemConexao()));

      await controller.carregarResumo(_filiais);

      expect(
        controller.resumo,
        isA<ResumoComFalha>().having(
          (e) => e.falha,
          'falha',
          const FalhaSemConexao(),
        ),
      );
    });

    test('Cenário: Dado uma falha, quando tento de novo e o service responde, então o estado vira carregado', () async {
      when(() => service.buscarResumo(_filiais))
          .thenAnswer((_) async => const Failure(FalhaSemConexao()));
      await controller.carregarResumo(_filiais);

      when(() => service.buscarResumo(_filiais))
          .thenAnswer((_) async => const Success(_resumo));
      final recarga = controller.carregarResumo(_filiais);

      expect(
        controller.resumo,
        isA<ResumoCarregando>(),
        reason: 'volta a carregar durante a nova busca',
      );
      await recarga;
      expect(controller.resumo, isA<ResumoCarregado>());
    });

    test('Cenário: Dado duas cargas seguidas, quando a primeira responde por último, então fico com o resultado da segunda', () async {
      final primeira = Completer<Either<Falha, ResumoPainel>>();
      when(() => service.buscarResumo(['f1']))
          .thenAnswer((_) => primeira.future);
      when(() => service.buscarResumo(_filiais))
          .thenAnswer((_) async => const Success(_resumo));

      final antiga = controller.carregarResumo(const ['f1']);
      await controller.carregarResumo(_filiais);
      primeira.complete(const Failure(FalhaSemConexao()));
      await antiga;

      expect(controller.filialIds, _filiais);
      expect(controller.resumo, isA<ResumoCarregado>());
    });
  });
}
