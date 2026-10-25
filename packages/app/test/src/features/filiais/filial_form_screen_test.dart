import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

Finder _campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);
final _salvar = find.widgetWithText(ElevatedButton, 'Salvar filial');

void main() {
  group('Funcionalidade: formulário de filial no app', () {
    late FilialRepositoryFake repository;
    late FiliaisController filiais;

    Future<void> abrir(
      WidgetTester tester, {
      FilialResponse? filial,
      bool obrigatoria = false,
      FilialRepositoryFake? fake,
      CepRepositoryFake? cep,
    }) async {
      repository = fake ?? FilialRepositoryFake();
      filiais = filiaisControllerDeTeste(repository: repository);
      await tester.pumpWidget(
        montarTela(
          FilialFormScreen(filial: filial, obrigatoria: obrigatoria),
          filialRepository: repository,
          filiais: filiais,
          filialForm: filialFormControllerDeTeste(
            repository: repository,
            cep: cep ?? CepRepositoryFake(),
          ),
        ),
      );
    }

    Future<void> escolherUf(WidgetTester tester, String uf) async {
      await tester.ensureVisible(_campo('UF'));
      await tester.tap(_campo('UF'));
      await tester.pumpAndSettle();
      final opcao = find.textContaining('$uf · ');
      await tester.scrollUntilVisible(
        opcao,
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(opcao);
      await tester.pumpAndSettle();
    }

    Future<void> preencher(
      WidgetTester tester, {
      String cep = '13010111',
      String uf = 'SP',
    }) async {
      await tester.enterText(_campo('Nome da filial'), 'Centro');
      await tester.enterText(_campo('CEP'), cep);
      await tester.enterText(_campo('Rua ou avenida'), 'Rua das Flores');
      await tester.enterText(_campo('Número'), '120');
      await tester.enterText(_campo('Complemento (opcional)'), 'Loja 2');
      await tester.enterText(_campo('Bairro'), 'Centro');
      await tester.enterText(_campo('Cidade'), 'Campinas');
      await escolherUf(tester, uf);
    }

    Future<void> enviar(WidgetTester tester) async {
      await tester.ensureVisible(_salvar);
      await tester.tap(_salvar);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado uma filial nova, então mostra os campos na ordem, sem campo de fuso e "Salvar filial"',
      (tester) async {
        await abrir(tester);

        expect(find.text('Nova filial'), findsOneWidget);
        expect(find.byType(BackButton), findsNothing, reason: 'tela raiz');
        final rotulos = [
          'Nome da filial',
          'CEP',
          'Rua ou avenida',
          'Número',
          'Complemento (opcional)',
          'Bairro',
          'Cidade',
        ];
        final posicoes = [
          for (final r in rotulos) tester.getTopLeft(_campo(r)).dy,
        ];
        expect(posicoes, [...posicoes]..sort());
        expect(find.text('Fuso horário'), findsNothing);
        expect(_salvar, findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado os campos vazios, quando salvo, então cada obrigatório diz o que falta e nada é enviado',
      (tester) async {
        await abrir(tester);

        await enviar(tester);

        for (final mensagem in [
          'Informe o nome da filial.',
          'Informe o CEP.',
          'Informe a rua ou avenida.',
          'Informe o número.',
          'Informe o bairro.',
          'Informe a cidade.',
          'Escolha a UF.',
        ]) {
          expect(find.text(mensagem), findsOneWidget, reason: mensagem);
        }
        expect(repository.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado um CEP incompleto, quando salvo, então o campo pede 8 números',
      (tester) async {
        await abrir(tester);

        await preencher(tester, cep: '1301');
        await enviar(tester);

        expect(find.text('Digite um CEP com 8 números.'), findsOneWidget);
        expect(repository.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado o CEP digitado, então ele aparece com máscara 00000-000',
      (tester) async {
        await abrir(tester);

        await tester.enterText(_campo('CEP'), '13010111');

        expect(find.text('13010-111'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado os dados preenchidos com a UF AM, quando salvo, então crio a filial com o fuso do estado e ela entra na lista',
      (tester) async {
        await abrir(tester);
        await preencher(tester, uf: 'AM');

        await enviar(tester);

        expect(repository.pedidos, [
          const FilialRequest(
            nome: 'Centro',
            endereco: Endereco(
              cep: '13010-111',
              logradouro: 'Rua das Flores',
              numero: '120',
              complemento: 'Loja 2',
              bairro: 'Centro',
              cidade: 'Campinas',
              uf: 'AM',
            ),
            fusoHorario: 'America/Manaus',
          ),
        ]);
        expect(filiais.filiais, hasLength(1));
      },
    );

    testWidgets(
      'Cenário: Dado um CEP existente, quando termino de digitar, então rua, bairro, cidade e UF são preenchidos e o complemento não',
      (tester) async {
        await abrir(tester);

        await tester.enterText(_campo('CEP'), '01001000');
        await tester.pumpAndSettle();

        expect(find.text('Praça da Sé'), findsOneWidget);
        expect(find.text('Sé'), findsOneWidget);
        expect(find.text('São Paulo'), findsOneWidget);
        expect(find.text('SP'), findsOneWidget);
        expect(
          tester
              .widget<TextFormField>(_campo('Complemento (opcional)'))
              .controller
              ?.text,
          isEmpty,
        );
      },
    );

    testWidgets(
      'Cenário: Dado a busca em andamento, então o campo CEP mostra o carregando',
      (tester) async {
        await abrir(
          tester,
          cep: CepRepositoryFake(atraso: const Duration(seconds: 1)),
        );

        await tester.enterText(_campo('CEP'), '01001000');
        await tester.pump();
        expect(find.bySemanticsLabel('Buscando CEP'), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('Buscando CEP'), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado um CEP de cidade com CEP único, quando a busca volta sem rua e bairro, então mantenho o que o lojista digitou',
      (tester) async {
        await abrir(
          tester,
          cep: CepRepositoryFake(
            ceps: {
              '78890000': const CepResponse(
                cep: '78890-000',
                logradouro: '',
                bairro: '',
                cidade: 'Sorriso',
                uf: 'MT',
              ),
            },
          ),
        );
        await tester.enterText(_campo('Rua ou avenida'), 'Rua das Flores');

        await tester.enterText(_campo('CEP'), '78890000');
        await tester.pumpAndSettle();

        expect(find.text('Rua das Flores'), findsOneWidget);
        expect(find.text('Sorriso'), findsOneWidget);
        expect(find.text('MT'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um CEP inexistente, quando termino de digitar, então o erro aparece no campo CEP e some ao editar',
      (tester) async {
        await abrir(tester);

        await tester.enterText(_campo('CEP'), '99999999');
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: _campo('CEP'),
            matching: find.text(cepNaoEncontrado.mensagem),
          ),
          findsOneWidget,
        );

        await tester.enterText(_campo('CEP'), '9999999');
        await tester.pump();
        expect(find.text(cepNaoEncontrado.mensagem), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado o ViaCEP fora do ar, quando termino de digitar, então aviso de forma amigável para preencher à mão',
      (tester) async {
        await abrir(
          tester,
          cep: CepRepositoryFake(falhaSimulada: const FalhaSemConexao()),
        );

        await tester.enterText(_campo('CEP'), '01001000');
        await tester.pumpAndSettle();

        expect(find.text('CEP indisponível'), findsOneWidget);
        expect(
          find.text(
            'Não conseguimos buscar o CEP agora. Preencha o endereço à mão.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado uma filial existente, quando abro, então os campos vêm preenchidos; quando salvo, então edito pelo id',
      (tester) async {
        await abrir(
          tester,
          filial: filialFake,
          fake: FilialRepositoryFake(filiais: [filialFake]),
        );

        expect(find.text('Editar filial'), findsOneWidget);
        expect(find.text('13010-111'), findsOneWidget);
        expect(find.text('Rua das Flores'), findsOneWidget);
        expect(find.text('SP'), findsOneWidget);

        await tester.enterText(_campo('Nome da filial'), 'Centro Novo');
        await enviar(tester);

        expect(repository.filiais.single.id, filialFake.id);
        expect(repository.filiais.single.nome, 'Centro Novo');
      },
    );

    testWidgets(
      'Cenário: Dado a API recusando com erros por campo, quando salvo, então cada erro aparece no seu campo e some ao editar',
      (tester) async {
        await abrir(
          tester,
          fake: FilialRepositoryFake(
            falhaSimulada: const FalhaApi(
              codigo: 'VALIDACAO_INVALIDA',
              mensagem: 'Dados inválidos.',
              campos: {
                'endereco.cep': ['CEP inválido.'],
                'fusoHorario': ['Fuso horário inválido.'],
              },
            ),
          ),
        );

        await preencher(tester);
        await enviar(tester);

        expect(
          find.descendant(
            of: _campo('CEP'),
            matching: find.text('CEP inválido.'),
          ),
          findsOneWidget,
        );
        expect(find.text('Fuso horário inválido.'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('Dados inválidos.'),
          ),
          findsOneWidget,
        );

        await tester.enterText(_campo('CEP'), '13010112');
        await tester.pump();
        expect(find.text('CEP inválido.'), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado o limite do plano atingido (409), quando salvo, então fico no formulário com o aviso da API',
      (tester) async {
        await abrir(
          tester,
          fake: FilialRepositoryFake(
            falhaSimulada: const FalhaApi(
              codigo: 'LIMITE_DO_PLANO_ATINGIDO',
              mensagem: 'O limite do seu plano foi atingido.',
            ),
          ),
        );

        await preencher(tester);
        await enviar(tester);

        expect(
          find.text('O limite do seu plano foi atingido.'),
          findsOneWidget,
        );
        expect(find.byType(FilialFormScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado o cadastro obrigatório da primeira filial, quando salvo, então a filial fica em uso e vou para a home',
      (tester) async {
        await abrir(tester, obrigatoria: true);

        expect(find.text('Cadastre sua filial'), findsOneWidget);
        expect(
          find.text('Para começar, cadastre a primeira filial da sua loja.'),
          findsOneWidget,
        );

        await preencher(tester);
        await enviar(tester);

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(filiais.emUso?.nome, 'Centro');
      },
    );

    testWidgets(
      'Cenário: Dado o envio em andamento, então o botão fica desabilitado com spinner e os campos bloqueados',
      (tester) async {
        await abrir(
          tester,
          fake: FilialRepositoryFake(atraso: const Duration(seconds: 1)),
        );

        await preencher(tester);
        await tester.ensureVisible(_salvar);
        await tester.tap(_salvar);
        await tester.pump();

        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );
        expect(
          tester.widget<TextFormField>(_campo('Nome da filial')).enabled,
          isFalse,
        );

        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(repository.pedidos, hasLength(1));
      },
    );
  });
}
