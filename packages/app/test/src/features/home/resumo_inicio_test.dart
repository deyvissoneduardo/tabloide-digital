import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

final class _RepositoryInstavel implements HomeRepository {
  var chamadas = 0;

  final pedidos = <List<String>>[];

  @override
  Future<Either<Falha, ResumoPainel>> buscarResumo(
    List<String> filialIds,
  ) async {
    chamadas++;
    pedidos.add(filialIds);
    return chamadas == 1
        ? const Failure(FalhaSemConexao())
        : const Success(
            ResumoPainel(panfletosVigentes: 1, produtosVigentes: 30),
          );
  }
}

void main() {
  group('Funcionalidade: seção Início do app', () {
    testWidgets(
      'Cenário: Dado que o repository demora, quando abro a home, então vejo o skeleton da lista',
      (tester) async {
        await tester.pumpWidget(
          montar(
            controller: controllerDeTeste(
              repository: const HomeRepositoryFake(),
            ),
          ),
        );

        expect(find.byType(EsqueletoLista), findsOneWidget);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        expect(find.byType(EsqueletoLista), findsNothing);
      },
    );

    testWidgets(
      'Cenário: Dado 2 filiais e o resumo 2/48, quando a home carrega, então peço o resumo das 2 filiais e mostro 2, 2 e 48',
      (tester) async {
        final repository = _RepositoryInstavel()..chamadas = 1;
        final filiais = filiaisControllerDeTeste(
          repository: FilialRepositoryFake(
            filiais: [filialFake, filialFakeBairro],
          ),
        );
        await tester.runAsync(filiais.carregar);
        await tester.pumpWidget(
          montar(
            filiais: filiais,
            controller: controllerDeTeste(repository: repository),
          ),
        );
        await tester.pumpAndSettle();

        expect(repository.pedidos, [
          [filialFake.id, filialFakeBairro.id],
        ]);
        expect(find.text('Filiais'), findsWidgets);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('Panfletos no ar'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('Produtos no ar'), findsOneWidget);
        expect(find.text('30'), findsOneWidget);
      },
    );

    testWidgets(
      'Cenário: Dado uma filial nova na lista, quando ela chega, então recarrego o resumo com todas as filiais',
      (tester) async {
        final repository = _RepositoryInstavel()..chamadas = 1;
        final filialRepository = FilialRepositoryFake(filiais: [filialFake]);
        final filiais = filiaisControllerDeTeste(repository: filialRepository);
        await tester.runAsync(filiais.carregar);
        await tester.pumpWidget(
          montar(
            filiais: filiais,
            controller: controllerDeTeste(repository: repository),
          ),
        );
        await tester.pumpAndSettle();

        filiais.salva(filialFakeBairro);
        await tester.pumpAndSettle();

        expect(repository.pedidos, [
          [filialFake.id],
          [filialFake.id, filialFakeBairro.id],
        ]);
      },
    );

    testWidgets(
      'Cenário: Dado sem conexão, quando a home carrega e toco em "Tentar de novo", então vejo a mensagem e depois os números',
      (tester) async {
        final repository = _RepositoryInstavel();
        await tester.pumpWidget(
          montar(controller: controllerDeTeste(repository: repository)),
        );
        await tester.pumpAndSettle();

        expect(find.text(const FalhaSemConexao().mensagem), findsOneWidget);

        await tester.tap(find.text('Tentar de novo'));
        await tester.pumpAndSettle();

        expect(repository.chamadas, 2);
        expect(find.text('30'), findsOneWidget);
      },
    );
  });
}
