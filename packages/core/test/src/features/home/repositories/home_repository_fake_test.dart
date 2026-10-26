import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: repository fake da home', () {
    test('Cenário: Dado o fake padrão, quando busco o resumo, então recebo Success com um ResumoPainel', () async {
      final resultado = await const HomeRepositoryFake(atraso: Duration.zero)
          .buscarResumo(const ['f1']);

      expect(
        resultado,
        const Success<Falha, ResumoPainel>(
          ResumoPainel(panfletosVigentes: 2, produtosVigentes: 48),
        ),
      );
    });

    test('Cenário: Dado um resumo configurado, quando busco, então recebo esse resumo', () async {
      const resumo = ResumoPainel(panfletosVigentes: 0, produtosVigentes: 5);

      final resultado = await const HomeRepositoryFake(
        resumo: resumo,
        atraso: Duration.zero,
      ).buscarResumo(const ['f1']);

      expect(resultado, const Success<Falha, ResumoPainel>(resumo));
    });

    test('Cenário: Dado uma falha simulada, quando busco, então recebo Failure com essa falha', () async {
      final resultado = await const HomeRepositoryFake(
        atraso: Duration.zero,
        falhaSimulada: FalhaSemConexao(),
      ).buscarResumo(const ['f1']);

      expect(resultado, const Failure<Falha, ResumoPainel>(FalhaSemConexao()));
    });
  });
}
