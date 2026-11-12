import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: repository falso de acessos', () {
    test('Cenário: Dado o fake padrão, quando peço o resumo e os panfletos, então recebo os dados fake e registro os pedidos', () async {
      final repository = AcessosRepositoryFake();

      final resumo = await repository.resumo(
        const PeriodoPredefinido(7),
        filialId: 'f1',
      );
      final panfletos = await repository.panfletos('f1', PeriodoAcessos.padrao);

      expect(resumo, Success<Falha, ResumoAcessosResponse>(resumoAcessosFake));
      expect(
        panfletos,
        Success<Falha, AcessosPanfletosResponse>(panfletosAcessosFake),
      );
      expect(repository.pedidos, [
        (
          periodo: const PeriodoPredefinido(7),
          filialId: 'f1',
          panfletos: false,
        ),
        (periodo: PeriodoAcessos.padrao, filialId: 'f1', panfletos: true),
      ]);
    });

    test('Cenário: Dado uma falha simulada, quando peço o resumo, então recebo a falha', () async {
      final repository = AcessosRepositoryFake(
        falhaSimulada: const FalhaSemConexao(),
      );

      expect(
        await repository.resumo(PeriodoAcessos.padrao),
        const Failure<Falha, ResumoAcessosResponse>(FalhaSemConexao()),
      );
    });

    test('Cenário: Dado os dados fake, então a soma por dia e por filial bate com o total', () {
      expect(
        resumoAcessosFake.porDia.fold(0, (s, d) => s + d.total),
        resumoAcessosFake.total,
      );
      expect(
        resumoAcessosFake.porFilial.fold(0, (s, f) => s + f.total),
        resumoAcessosFake.total,
      );
      expect(
        resumoAcessosPoucosFake.porDia.fold(0, (s, d) => s + d.total),
        resumoAcessosPoucosFake.total,
      );
    });
  });
}
