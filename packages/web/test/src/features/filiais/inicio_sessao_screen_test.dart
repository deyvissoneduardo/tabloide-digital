import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/testing.dart';
import 'package:tabloide_web/tabloide_web.dart';

import '../../../helpers/montar.dart';

final _cacheValido = {
  Sessao.chaveToken: 'eyJ.token',
  Sessao.chaveExpiraEm: '2026-10-18T21:00:00.000Z',
};

void main() {
  group('Funcionalidade: entrada no painel conforme sessão e filiais', () {
    Future<void> abrir(
      WidgetTester tester, {
      Map<String, String>? cache,
      FilialRepositoryFake? filiais,
      ArmazenamentoMemoria? armazenamento,
    }) async {
      await tester.pumpWidget(
        montarTela(
          const InicioSessaoScreen(),
          sessao: sessaoDeTeste(
            armazenamento: armazenamento ?? ArmazenamentoMemoria(cache),
          ),
          filiais: filiaisControllerDeTeste(
            repository: filiais ?? FilialRepositoryFake(filiais: [filialFake]),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado nenhuma sessão no cache, quando o painel abre, então vai para o login',
      (tester) async {
        await abrir(tester);

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(InicioSessaoScreen), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado uma sessão válida no cache e uma única filial, quando o painel abre, então usa essa filial e vai para a home',
      (tester) async {
        final filiais = filiaisControllerDeTeste();
        await tester.pumpWidget(
          montarTela(
            const InicioSessaoScreen(),
            sessao: sessaoDeTeste(
              armazenamento: ArmazenamentoMemoria(_cacheValido),
            ),
            filiais: filiais,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(filiais.emUso, filialFake);
      },
    );

    testWidgets(
      'Cenário: Dado uma sessão vencida no cache, quando o painel abre, então vai para o login',
      (tester) async {
        await abrir(
          tester,
          cache: {
            Sessao.chaveToken: 'eyJ.token',
            Sessao.chaveExpiraEm: '2026-10-18T13:00:00.000Z',
          },
        );

        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um lojista sem filiais, quando o painel abre, então vai direto para o cadastro de filial, sem voltar',
      (tester) async {
        await abrir(
          tester,
          cache: _cacheValido,
          filiais: FilialRepositoryFake(),
        );

        expect(find.byType(FilialFormScreen), findsOneWidget);
        expect(find.text('Cadastre sua filial'), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado mais de uma filial, quando o painel abre, então o lojista escolhe a filial e vai para a home com ela em uso',
      (tester) async {
        final filiais = filiaisControllerDeTeste(
          repository: FilialRepositoryFake(
            filiais: [filialFake, filialFakeBairro],
          ),
        );
        await tester.pumpWidget(
          montarTela(
            const InicioSessaoScreen(),
            sessao: sessaoDeTeste(
              armazenamento: ArmazenamentoMemoria(_cacheValido),
            ),
            filiais: filiais,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(EscolherFilialScreen), findsOneWidget);
        expect(find.text('Centro'), findsOneWidget);
        expect(find.text('Bairro Alto'), findsOneWidget);

        await tester.tap(find.text('Bairro Alto'));
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(
          find.byType(EscolherFilialScreen, skipOffstage: false),
          findsNothing,
        );
        expect(filiais.emUso, filialFakeBairro);
      },
    );

    testWidgets(
      'Cenário: Dado a lista de filiais falhando, quando o painel abre, então mostra a falha e tenta de novo',
      (tester) async {
        final repository = FilialRepositoryFake(
          filiais: [filialFake],
          falhaSimulada: const FalhaSemConexao(),
        );
        await abrir(tester, cache: _cacheValido, filiais: repository);

        expect(find.byType(EstadoFalha), findsOneWidget);
        expect(find.text(const FalhaSemConexao().mensagem), findsOneWidget);

        repository.falhaSimulada = null;
        await tester.tap(find.text('Tentar de novo'));
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado o token recusado pela API (401), quando o painel abre, então a sessão é encerrada e vai para o login',
      (tester) async {
        final armazenamento = ArmazenamentoMemoria(_cacheValido);
        await abrir(
          tester,
          armazenamento: armazenamento,
          filiais: FilialRepositoryFake(
            falhaSimulada: const FalhaApi(
              codigo: 'NAO_AUTENTICADO',
              mensagem: 'Faça login para continuar.',
            ),
          ),
        );

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(armazenamento.valores, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado o login com sucesso, quando entro, então a sessão vai para o cache e sigo para a home',
      (tester) async {
        final armazenamento = ArmazenamentoMemoria();
        await abrir(tester, armazenamento: armazenamento);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'E-mail'),
          'teste01@gmail.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Senha'),
          'Teste1234',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(armazenamento.valores[Sessao.chaveToken], 'token-fake');
      },
    );
  });
}
