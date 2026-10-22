import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

void main() {
  group('Funcionalidade: repository fake da home', () {
    test('Cenário: Dado o fake padrão, quando busco o resumo, então recebo Success com um ResumoPainel', () async {
      final resultado = await const HomeRepositoryFake(atraso: Duration.zero)
          .buscarResumo();

      expect(
        resultado,
        const Success<Falha, ResumoPainel>(
          ResumoPainel(filiais: 3, panfletosVigentes: 2, produtosVigentes: 48),
        ),
      );
    });

    test('Cenário: Dado um resumo configurado, quando busco, então recebo esse resumo', () async {
      const resumo = ResumoPainel(
        filiais: 1,
        panfletosVigentes: 0,
        produtosVigentes: 5,
      );

      final resultado = await const HomeRepositoryFake(
        resumo: resumo,
        atraso: Duration.zero,
      ).buscarResumo();

      expect(resultado, const Success<Falha, ResumoPainel>(resumo));
    });

    test('Cenário: Dado uma falha simulada, quando busco, então recebo Failure com essa falha', () async {
      final resultado = await const HomeRepositoryFake(
        atraso: Duration.zero,
        falhaSimulada: FalhaSemConexao(),
      ).buscarResumo();

      expect(resultado, const Failure<Falha, ResumoPainel>(FalhaSemConexao()));
    });
  });
}
