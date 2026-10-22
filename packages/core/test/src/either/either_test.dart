import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';

void main() {
  group('Funcionalidade: Either com Success e Failure', () {
    group('Cenário: Dado um Success com o valor 2', () {
      const Either<Falha, int> resultado = Success(2);

      test('Então é sucesso e não é falha', () {
        expect(resultado.isSuccess, isTrue);
        expect(resultado.isFailure, isFalse);
      });

      test('Quando faço fold, então executo só o ramo de sucesso', () {
        expect(resultado.fold((_) => 'falha', (v) => 'valor $v'), 'valor 2');
      });

      test('Quando faço map, então transformo o valor', () {
        expect(resultado.map((v) => v * 10), const Success<Falha, int>(20));
      });

      test('Quando faço flatMap para outra operação que falha, então recebo a falha dela', () {
        expect(
          resultado.flatMap<int>((_) => const Failure(FalhaSemConexao())),
          const Failure<Falha, int>(FalhaSemConexao()),
        );
      });

      test('Quando uso switch, então o compilador garante os dois casos', () {
        final texto = switch (resultado) {
          Success(:final valor) => 'ok $valor',
          Failure(:final falha) => falha.mensagem,
        };
        expect(texto, 'ok 2');
      });
    });

    group('Cenário: Dado um Failure sem conexão', () {
      const Either<Falha, int> resultado = Failure(FalhaSemConexao());

      test('Então é falha e não é sucesso', () {
        expect(resultado.isFailure, isTrue);
        expect(resultado.isSuccess, isFalse);
      });

      test('Quando faço fold, então executo só o ramo de falha', () {
        expect(
          resultado.fold((f) => f.mensagem, (_) => 'valor'),
          const FalhaSemConexao().mensagem,
        );
      });

      test(
        'Quando faço map ou flatMap, então a falha passa sem executar a função',
        () {
          var chamou = false;
          expect(
            resultado.map((v) {
              chamou = true;
              return v;
            }),
            const Failure<Falha, int>(FalhaSemConexao()),
          );
          expect(
            resultado.flatMap((v) {
              chamou = true;
              return Success<Falha, int>(v);
            }),
            isA<Failure<Falha, int>>(),
          );
          expect(chamou, isFalse);
        },
      );
    });

    test(
      'Cenário: Dado dois Success iguais, então são iguais e têm o mesmo hash',
      () {
        expect(const Success<Falha, int>(1), const Success<Falha, int>(1));
        expect(
          const Success<Falha, int>(1).hashCode,
          const Success<Falha, int>(1).hashCode,
        );
        expect(
          const Success<Falha, int>(1),
          isNot(const Success<Falha, int>(2)),
        );
      },
    );
  });
}
