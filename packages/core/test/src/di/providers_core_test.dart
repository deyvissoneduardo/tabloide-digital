import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

final class _ServicoDeTeste implements HomeService {
  _ServicoDeTeste(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Falha, ResumoPainel>> buscarResumo(List<String> filialIds) =>
      _repository.buscarResumo(filialIds);
}

void main() {
  group('Funcionalidade: injeção compartilhada', () {
    testWidgets(
      'Cenário: Dado os providers do core com o service da plataforma, quando monto a árvore, então cada camada recebe a de baixo',
      (tester) async {
        const marca = MarcaFake(nome: 'Marca DI');
        const resumo = ResumoPainel(panfletosVigentes: 9, produtosVigentes: 9);
        late BuildContext contexto;

        await tester.pumpWidget(
          MultiProvider(
            providers: providersCore(
              marca: marca,
              baseUrl: 'http://api',
              homeRepository: const HomeRepositoryFake(
                resumo: resumo,
                atraso: Duration.zero,
              ),
              servicos: [
                Provider<HomeService>(
                  create: (c) => _ServicoDeTeste(c.read<HomeRepository>()),
                ),
              ],
            ),
            child: Builder(
              builder: (context) {
                contexto = context;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(contexto.read<BrandConfig>(), same(marca));
        expect(contexto.read<RestClient>(), isA<RestClient>());
        expect(contexto.read<HomeService>(), isA<_ServicoDeTeste>());

        final controller = contexto.read<HomeController>();
        expect(
          controller.resumo,
          isA<ResumoCarregando>(),
          reason: 'o resumo depende das filiais, então espera a tela pedir',
        );
        await tester.runAsync(() => controller.carregarResumo(const ['f1']));
        expect(
          controller.resumo,
          isA<ResumoCarregado>().having((e) => e.resumo, 'resumo', resumo),
          reason: 'o resumo passa por service e repository',
        );
      },
    );

    testWidgets(
      'Cenário: Dado os providers sem repositories injetados, quando leio cada um, então recebo o padrão (API em todos os repositories)',
      (tester) async {
        late BuildContext contexto;
        await tester.pumpWidget(
          MultiProvider(
            providers: providersCore(
              marca: const MarcaFake(),
              baseUrl: 'http://api',
              servicos: const [],
            ),
            child: Builder(
              builder: (context) {
                contexto = context;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(contexto.read<HomeRepository>(), isA<HomeRepositoryApi>());
        expect(
          contexto.read<AuthRepository>(),
          isA<AuthRepositoryApi>(),
          reason: 'o login fala com a API de verdade',
        );
        expect(
          contexto.read<CadastroRepository>(),
          isA<CadastroRepositoryApi>(),
          reason: 'o cadastro fala com a API de verdade',
        );
        expect(contexto.read<FilialRepository>(), isA<FilialRepositoryApi>());
        expect(contexto.read<CepRepository>(), isA<CepRepositoryViaCep>());
        expect(
          contexto.read<IdentidadeRepository>(),
          isA<IdentidadeRepositoryApi>(),
        );
        expect(contexto.read<LojistaRepository>(), isA<LojistaRepositoryApi>());
        expect(
          contexto.read<PanfletoRepository>(),
          isA<PanfletoRepositoryApi>(),
        );
        expect(
          contexto.read<CategoriaRepository>(),
          isA<CategoriaRepositoryApi>(),
        );
        expect(contexto.read<ProdutoRepository>(), isA<ProdutoRepositoryApi>());
        expect(contexto.read<Sessao>().ativa, isFalse);
      },
    );

    testWidgets(
      'Cenário: Dado um cache injetado, quando inicio a sessão, então ela grava nesse cache',
      (tester) async {
        final armazenamento = ArmazenamentoMemoria();
        late BuildContext contexto;
        await tester.pumpWidget(
          MultiProvider(
            providers: providersCore(
              marca: const MarcaFake(),
              baseUrl: 'http://api',
              armazenamento: armazenamento,
              servicos: const [],
            ),
            child: Builder(
              builder: (context) {
                contexto = context;
                return const SizedBox();
              },
            ),
          ),
        );

        await tester.runAsync(
          () => contexto.read<Sessao>().iniciar(
            token: 'eyJ.token',
            expiraEm: DateTime.now().add(const Duration(hours: 1)),
          ),
        );

        expect(armazenamento.valores[Sessao.chaveToken], 'eyJ.token');
      },
    );
  });
}
