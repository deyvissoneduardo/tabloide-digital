import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

class _ImagePickerMock extends Mock implements ImagePicker {}

Finder _campo(String rotulo) => find.widgetWithText(TextFormField, rotulo);

void main() {
  setUpAll(() => registerFallbackValue(ImageSource.gallery));

  group('Funcionalidade: formulário de produto no app', () {
    late ProdutoRepositoryFake repository;
    late _ImagePickerMock seletor;
    late ProdutosController produtos;

    void escolherFoto(Future<XFile?> Function() resposta) => when(
      () => seletor.pickImage(
        source: any(named: 'source'),
        maxWidth: any(named: 'maxWidth'),
        maxHeight: any(named: 'maxHeight'),
      ),
    ).thenAnswer((_) => resposta());

    Future<void> abrir(WidgetTester tester, {ProdutoResponse? produto}) async {
      tester.view.physicalSize = const Size(390, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      repository = ProdutoRepositoryFake(produtos: [produtoFake]);
      seletor = _ImagePickerMock();
      produtos = produtosControllerDeTeste(repository: repository);
      final categorias = categoriasControllerDeTeste(
        repository: CategoriaRepositoryFake(
          categorias: [categoriaFake, categoriaFakeVazia],
        ),
      );
      await tester.runAsync(() async {
        await produtos.carregar(produtoFake.filialId);
        await categorias.carregar(produtoFake.filialId);
      });
      await tester.pumpWidget(
        montarTela(
          ProdutoFormScreen(filialId: produtoFake.filialId, produto: produto),
          produtos: produtos,
          categorias: categorias,
          produtoRepository: repository,
          seletorImagem: seletor,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> tocar(WidgetTester tester, String rotulo) async {
      await tester.tap(find.widgetWithText(ElevatedButton, rotulo));
      await tester.pumpAndSettle();
    }

    Future<void> escolherCategoria(WidgetTester tester, String nome) async {
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(nome).last);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'Cenário: Dado um produto novo, então os obrigatórios vêm primeiro (Nome, Categoria, Preço promocional)',
      (tester) async {
        await abrir(tester);

        double topo(Finder f) => tester.getTopLeft(f).dy;
        expect(find.text('Novo produto'), findsOneWidget);
        expect(
          topo(_campo('Nome do produto')),
          lessThan(topo(find.byType(DropdownButtonFormField<String>))),
        );
        expect(
          topo(find.byType(DropdownButtonFormField<String>)),
          lessThan(topo(_campo('Preço promocional'))),
        );
        expect(
          topo(_campo('Preço promocional')),
          lessThan(topo(_campo('Preço original (opcional)'))),
        );
      },
    );

    testWidgets(
      'Cenário: Dado o formulário vazio, quando publico, então peço nome, categoria e preço nos campos e nada é enviado',
      (tester) async {
        await abrir(tester);

        await tocar(tester, 'Publicar produto');

        expect(find.text('Informe o nome do produto.'), findsOneWidget);
        expect(find.text('Escolha a categoria.'), findsOneWidget);
        expect(find.text('Informe o preço promocional.'), findsOneWidget);
        expect(repository.pedidos, isEmpty);
      },
    );

    testWidgets(
      'Cenário: Dado preço original menor ou igual ao promocional, quando publico, então o erro aparece no campo (RN21)',
      (tester) async {
        await abrir(tester);

        await tester.enterText(_campo('Preço promocional'), '2199');
        await tester.enterText(_campo('Preço original (opcional)'), '2199');
        await tocar(tester, 'Publicar produto');

        expect(find.text('R\$ 21,99'), findsNWidgets(2));
        expect(
          find.text('Precisa ser maior que o preço promocional.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado os campos preenchidos, quando publico, então envio centavos e volto atualizando a lista',
      (tester) async {
        await abrir(tester);

        await tester.enterText(_campo('Nome do produto'), 'Feijão Carioca');
        await escolherCategoria(tester, 'Mercearia');
        await tester.enterText(_campo('Preço promocional'), '899');
        await tester.enterText(_campo('Preço original (opcional)'), '1099');
        await tester.enterText(_campo('Quantidade (opcional)'), '1kg');
        await tocar(tester, 'Publicar produto');

        expect(
          repository.pedidos.single,
          const ProdutoRequest(
            nome: 'Feijão Carioca',
            categoriaId: '0192f0c1-9f51-7e43-8a6d-4f5a6b7c8d04',
            precoPromocionalCentavos: 899,
            precoOriginalCentavos: 1099,
            quantidade: '1kg',
            descricao: '',
            observacao: '',
          ),
        );
        expect(find.byType(ProdutoFormScreen), findsNothing);
        expect(
          produtos.produtos.map((p) => p.nome),
          contains('Feijão Carioca'),
        );
      },
    );

    testWidgets(
      'Cenário: Dado limite do plano atingido, quando publico, então aviso o erro e continuo no formulário',
      (tester) async {
        await abrir(tester);
        repository.falhaSimulada = const FalhaApi(
          codigo: 'LIMITE_DO_PLANO_ATINGIDO',
          mensagem: 'O limite do seu plano foi atingido.',
        );

        await tester.enterText(_campo('Nome do produto'), 'Feijão');
        await escolherCategoria(tester, 'Bebidas');
        await tester.enterText(_campo('Preço promocional'), '899');
        await tocar(tester, 'Publicar produto');

        expect(
          find.text('O limite do seu plano foi atingido.'),
          findsOneWidget,
        );
        expect(find.byType(ProdutoFormScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado um produto vigente, então os campos vêm preenchidos e a data de início fica bloqueada (RN26)',
      (tester) async {
        await abrir(tester, produto: produtoFake);

        expect(find.text('Editar produto'), findsOneWidget);
        expect(find.text('Arroz Tipo 1'), findsOneWidget);
        expect(find.text('R\$ 21,99'), findsOneWidget);
        expect(find.text('R\$ 26,49'), findsOneWidget);
        expect(find.text('Mercearia'), findsOneWidget);
        expect(
          tester
              .widget<TextFormField>(_campo('Data de início (opcional)'))
              .enabled,
          isFalse,
        );
        expect(
          find.text('Produto vigente: a data de início não muda mais.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário: Dado um produto com foto, quando removo a foto e salvo, então chamo só a remoção e saio',
      (tester) async {
        await abrir(tester, produto: produtoFake);

        await tester.tap(find.text('Remover imagem'));
        await tester.pumpAndSettle();
        expect(find.text('Escolher imagem'), findsOneWidget);
        await tocar(tester, 'Salvar produto');

        expect(repository.fotosRemovidas, [produtoFake.id]);
        expect(repository.edicoes, isEmpty);
        expect(find.byType(ProdutoFormScreen), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado uma foto escolhida, quando publico, então ela vai junto no cadastro',
      (tester) async {
        await abrir(tester);
        escolherFoto(
          () async => XFile.fromData(
            Uint8List.fromList([1, 2, 3]),
            name: 'feijao.jpg',
            path: 'feijao.jpg',
          ),
        );

        await tester.tap(find.text('Escolher imagem'));
        await tester.pumpAndSettle();
        await tester.enterText(_campo('Nome do produto'), 'Feijão');
        await escolherCategoria(tester, 'Mercearia');
        await tester.enterText(_campo('Preço promocional'), '899');
        await tocar(tester, 'Publicar produto');

        expect(repository.fotosEnviadas, ['feijao.jpg']);
      },
    );

    testWidgets(
      'Cenário: Dado o seletor sem permissão, quando escolho a foto, então aviso o erro',
      (tester) async {
        await abrir(tester);
        escolherFoto(() async => throw PlatformException(code: 'negado'));

        await tester.tap(find.text('Escolher imagem'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Não conseguimos abrir suas imagens. Verifique a permissão e tente de novo.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
