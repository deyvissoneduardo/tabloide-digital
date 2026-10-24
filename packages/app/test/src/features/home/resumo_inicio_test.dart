import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';

import '../../../helpers/montar.dart';

final class _RepositoryInstavel implements HomeRepository {
  var chamadas = 0;

  @override
  Future<Either<Falha, ResumoPainel>> buscarResumo() async {
    chamadas++;
    return chamadas == 1
        ? const Failure(FalhaSemConexao())
        : const Success(
            ResumoPainel(
              filiais: 7,
              panfletosVigentes: 1,
              produtosVigentes: 30,
            ),
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
      'Cenário: Dado o resumo 3/2/48, quando a home carrega, então vejo os três números',
      (tester) async {
        await tester.pumpWidget(montar());
        await tester.pumpAndSettle();

        expect(find.text('Filiais'), findsWidgets);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('Panfletos no ar'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('Produtos no ar'), findsOneWidget);
        expect(find.text('48'), findsOneWidget);
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
        expect(find.text('7'), findsOneWidget);
      },
    );
  });
}
