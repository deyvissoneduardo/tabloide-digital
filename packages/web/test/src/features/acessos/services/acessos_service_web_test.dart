import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

class _AcessosRepositoryMock extends Mock implements AcessosRepository {}

void main() {
  group('Funcionalidade: service de acessos na web', () {
    test('Cenário: Dado o repository respondendo, quando peço o resumo e os panfletos, então devolvo o mesmo resultado de cada chamada', () async {
      final repository = _AcessosRepositoryMock();
      final service = AcessosServiceWeb(repository);
      const periodo = PeriodoPredefinido(7);
      when(() => repository.resumo(periodo, filialId: 'f1'))
          .thenAnswer((_) async => Success(resumoAcessosFake));
      when(() => repository.panfletos('f1', periodo))
          .thenAnswer((_) async => const Failure(FalhaSemConexao()));

      expect(
        await service.resumo(periodo, filialId: 'f1'),
        Success<Falha, ResumoAcessosResponse>(resumoAcessosFake),
      );
      expect(
        await service.panfletos('f1', periodo),
        const Failure<Falha, AcessosPanfletosResponse>(FalhaSemConexao()),
      );
    });
  });
}
