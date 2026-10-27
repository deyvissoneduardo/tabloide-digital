import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: panfletos falsos para testes', () {
    test('Cenário: Dado nenhuma data de início, quando cadastro, então o panfleto começa hoje e fica vigente', () async {
      final repository = PanfletoRepositoryFake();

      final resultado = await repository.criar(
        'filial',
        const PanfletoRequest(),
        bytes: [1],
        nomeArquivo: 'p.jpg',
      );

      final panfleto = resultado.fold((_) => null, (p) => p)!;
      expect(panfleto.vigencia.dataInicio, DataDia.hoje());
      expect(panfleto.vigencia.situacao, SituacaoVigencia.vigente);
      expect(repository.panfletos, [panfleto]);
      expect(repository.imagensEnviadas, ['p.jpg']);
    });

    test('Cenário: Dado um início futuro, quando cadastro, então o panfleto fica agendado', () async {
      final repository = PanfletoRepositoryFake();

      final resultado = await repository.criar(
        'filial',
        PanfletoRequest(
          dataInicio: DataDia.hoje().add(const Duration(days: 3)),
        ),
        bytes: [1],
        nomeArquivo: 'p.jpg',
      );

      expect(
        resultado.fold((_) => null, (p) => p.vigencia.situacao),
        SituacaoVigencia.agendado,
      );
    });

    test('Cenário: Dado um panfleto, quando edito a data limite e troco a imagem, então a lista guarda as mudanças', () async {
      final repository = PanfletoRepositoryFake(panfletos: [panfletoFake]);

      await repository.editar(
        'filial',
        panfletoFake.id,
        PanfletoRequest(dataLimite: DateTime(2027, 1, 15)),
      );
      await repository.trocarImagem(
        'filial',
        panfletoFake.id,
        bytes: [1],
        nomeArquivo: 'novo.png',
      );

      final atual = repository.panfletos.single;
      expect(atual.vigencia.dataLimite, DateTime(2027, 1, 15));
      expect(atual.vigencia.dataInicio, panfletoFake.vigencia.dataInicio);
      expect(atual.urlArquivo, 'https://midia.fake/panfleto/novo.png');
      expect(atual.tipo, TipoArquivoPanfleto.imagem);
    });

    test('Cenário: Dado uma falha simulada, quando listo, obtenho ou excluo, então recebo a falha', () async {
      final repository = PanfletoRepositoryFake(
        panfletos: [panfletoFake],
        falhaSimulada: const FalhaSemConexao(),
      );

      expect(await repository.listar('f'), isA<Failure<Falha, Object>>());
      expect(
        await repository.obter('f', panfletoFake.id),
        isA<Failure<Falha, Object>>(),
      );
      expect(
        await repository.excluir('f', panfletoFake.id),
        isA<Failure<Falha, Object>>(),
      );
      expect(repository.panfletos, [panfletoFake]);
    });

    test('Cenário: Dado um id inexistente, quando obtenho, então recebo RECURSO_NAO_ENCONTRADO', () async {
      final resultado = await PanfletoRepositoryFake().obter('f', 'x');

      expect(
        resultado.fold((f) => f, (_) => null),
        isA<FalhaApi>().having(
          (f) => f.codigo,
          'codigo',
          'RECURSO_NAO_ENCONTRADO',
        ),
      );
    });
  });
}
