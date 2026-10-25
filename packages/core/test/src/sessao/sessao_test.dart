import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

final _agora = DateTime.utc(2026, 10, 18, 14);

final class _ArmazenamentoQuebrado implements ArmazenamentoLocal {
  @override
  Future<String?> ler(String chave) async => throw StateError('disco');

  @override
  Future<void> gravar(String chave, String valor) async =>
      throw StateError('disco');

  @override
  Future<void> remover(String chave) async => throw StateError('disco');
}

void main() {
  group('Funcionalidade: sessão do lojista', () {
    test('Cenário: Dado uma sessão nova, então não há token', () {
      final sessao = Sessao(ArmazenamentoMemoria(), agora: () => _agora);

      expect(sessao.token, isNull);
      expect(sessao.ativa, isFalse);
    });

    test('Cenário: Dado um login, quando inicio a sessão, então o token fica disponível e vai para o cache', () async {
      final armazenamento = ArmazenamentoMemoria();
      final sessao = Sessao(armazenamento, agora: () => _agora);

      await sessao.iniciar(
        token: 'eyJ.token',
        expiraEm: DateTime.utc(2026, 10, 18, 21),
      );

      expect(sessao.token, 'eyJ.token');
      expect(armazenamento.valores, {
        Sessao.chaveToken: 'eyJ.token',
        Sessao.chaveExpiraEm: '2026-10-18T21:00:00.000Z',
      });
    });

    test('Cenário: Dado um token válido no cache, quando restauro, então a sessão volta ativa', () async {
      final sessao = Sessao(
        ArmazenamentoMemoria({
          Sessao.chaveToken: 'eyJ.token',
          Sessao.chaveExpiraEm: '2026-10-18T21:00:00.000Z',
        }),
        agora: () => _agora,
      );

      expect(await sessao.restaurar(), isTrue);
      expect(sessao.token, 'eyJ.token');
    });

    test('Cenário: Dado um token vencido no cache, quando restauro, então não há sessão e o cache é limpo', () async {
      final armazenamento = ArmazenamentoMemoria({
        Sessao.chaveToken: 'eyJ.token',
        Sessao.chaveExpiraEm: '2026-10-18T13:00:00.000Z',
      });
      final sessao = Sessao(armazenamento, agora: () => _agora);

      expect(await sessao.restaurar(), isFalse);
      expect(sessao.token, isNull);
      expect(armazenamento.valores, isEmpty);
    });

    test(
      'Cenário: Dado o cache vazio, quando restauro, então não há sessão',
      () async {
        final sessao = Sessao(ArmazenamentoMemoria(), agora: () => _agora);

        expect(await sessao.restaurar(), isFalse);
      },
    );

    test('Cenário: Dado uma sessão que vence, quando o tempo passa do vencimento, então o token deixa de ser enviado', () async {
      var agora = _agora;
      final sessao = Sessao(ArmazenamentoMemoria(), agora: () => agora);
      await sessao.iniciar(
        token: 'eyJ.token',
        expiraEm: DateTime.utc(2026, 10, 18, 21),
      );

      agora = DateTime.utc(2026, 10, 18, 21);

      expect(sessao.token, isNull);
    });

    test('Cenário: Dado uma sessão ativa, quando encerro, então token e cache somem', () async {
      final armazenamento = ArmazenamentoMemoria();
      final sessao = Sessao(armazenamento, agora: () => _agora);
      await sessao.iniciar(
        token: 'eyJ.token',
        expiraEm: DateTime.utc(2026, 10, 18, 21),
      );

      await sessao.encerrar();

      expect(sessao.ativa, isFalse);
      expect(armazenamento.valores, isEmpty);
    });

    test('Cenário: Dado o cache quebrado, quando inicio, restauro e encerro, então nada lança e o token fica só em memória', () async {
      final sessao = Sessao(_ArmazenamentoQuebrado(), agora: () => _agora);

      expect(await sessao.restaurar(), isFalse);
      await sessao.iniciar(
        token: 'eyJ.token',
        expiraEm: DateTime.utc(2026, 10, 18, 21),
      );
      expect(sessao.token, 'eyJ.token');
      await sessao.encerrar();
      expect(sessao.token, isNull);
    });
  });
}
