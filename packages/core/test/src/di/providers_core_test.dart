import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

final class _ServicoDeTeste implements HomeService {
  _ServicoDeTeste(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Falha, ResumoPainel>> buscarResumo() =>
      _repository.buscarResumo();
}

void main() {
  group('Funcionalidade: injeção compartilhada', () {
    testWidgets(
      'Cenário: Dado os providers do core com o service da plataforma, quando monto a árvore, então cada camada recebe a de baixo',
      (tester) async {
        const marca = MarcaFake(nome: 'Marca DI');
        const resumo = ResumoPainel(
          filiais: 9,
          panfletosVigentes: 9,
          produtosVigentes: 9,
        );
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
        await tester.pumpAndSettle();
        expect(
          controller.resumo,
          isA<ResumoCarregado>().having((e) => e.resumo, 'resumo', resumo),
          reason: 'o controller já carrega o resumo ao ser criado, passando por service e repository',
        );
      },
    );

    testWidgets(
      'Cenário: Dado os providers sem repositories injetados, quando leio cada um, então recebo o padrão (fake da home, API no login e no cadastro)',
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

        expect(contexto.read<HomeRepository>(), isA<HomeRepositoryFake>());
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
      },
    );
  });
}
