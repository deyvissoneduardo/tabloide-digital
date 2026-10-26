import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/features/categorias/models/contagem_produtos.dart';
import 'package:tabloide_core/src/features/categorias/repositories/categoria_repository.dart';
import 'package:tabloide_core/src/requests/categoria_request.dart';
import 'package:tabloide_core/src/responses/categoria_response.dart';

final categoriaFake = CategoriaResponse(
  id: '0192f0c1-9f51-7e43-8a6d-4f5a6b7c8d04',
  nome: 'Mercearia',
  produtos: const ContagemProdutos(vigentes: 12, agendados: 3, vencidos: 7),
  podeExcluir: false,
  criadoEm: DateTime.utc(2026, 10, 18, 13, 2, 11),
  atualizadoEm: DateTime.utc(2026, 10, 18, 13, 2, 11),
);

final categoriaFakeVazia = CategoriaResponse(
  id: '0192f0c1-9f51-7e43-8a6d-4f5a6b7c8d05',
  nome: 'Bebidas',
  produtos: const ContagemProdutos(vigentes: 0, agendados: 0, vencidos: 2),
  podeExcluir: true,
  criadoEm: DateTime.utc(2026, 10, 18, 13, 5),
  atualizadoEm: DateTime.utc(2026, 10, 18, 13, 5),
);

final class CategoriaRepositoryFake implements CategoriaRepository {
  CategoriaRepositoryFake({
    List<CategoriaResponse>? categorias,
    this.falhaSimulada,
    this.atraso = Duration.zero,
  }) : categorias = [...?categorias];

  final List<CategoriaResponse> categorias;

  Falha? falhaSimulada;

  final Duration atraso;

  final pedidos = <CategoriaRequest>[];

  final excluidos = <String>[];

  @override
  Future<Either<Falha, List<CategoriaResponse>>> listar(String filialId) =>
      _responder(() => Success([...categorias]));

  @override
  Future<Either<Falha, CategoriaResponse>> criar(
    String filialId,
    CategoriaRequest request,
  ) {
    pedidos.add(request);
    return _responder(() {
      if (_repetida(request.nome)) return const Failure(_jaExiste);
      final agora = DateTime.now().toUtc();
      final categoria = CategoriaResponse(
        id: 'categoria-fake-${categorias.length + 1}',
        nome: request.nome.trim(),
        produtos: const ContagemProdutos(
          vigentes: 0,
          agendados: 0,
          vencidos: 0,
        ),
        podeExcluir: true,
        criadoEm: agora,
        atualizadoEm: agora,
      );
      categorias.add(categoria);
      return Success(categoria);
    });
  }

  @override
  Future<Either<Falha, CategoriaResponse>> renomear(
    String filialId,
    String id,
    CategoriaRequest request,
  ) {
    pedidos.add(request);
    return _responder(() {
      final i = categorias.indexWhere((c) => c.id == id);
      if (i < 0) return const Failure(_naoEncontrado);
      if (_repetida(request.nome, exceto: id)) {
        return const Failure(_jaExiste);
      }
      final atual = categorias[i];
      return Success(
        categorias[i] = CategoriaResponse(
          id: atual.id,
          nome: request.nome.trim(),
          produtos: atual.produtos,
          podeExcluir: atual.podeExcluir,
          criadoEm: atual.criadoEm,
          atualizadoEm: DateTime.now().toUtc(),
        ),
      );
    });
  }

  @override
  Future<Either<Falha, Nada>> excluir(String filialId, String id) {
    excluidos.add(id);
    return _responder(() {
      final categoria = categorias.where((c) => c.id == id).firstOrNull;
      if (categoria == null) return const Failure(_naoEncontrado);
      if (!categoria.podeExcluir) {
        return Failure(
          FalhaApi(
            codigo: 'CATEGORIA_COM_PRODUTOS_ATIVOS',
            mensagem:
                'Exclua os produtos vigentes e agendados antes de excluir a '
                'categoria.',
            detalhes: {
              'vigentes': categoria.produtos.vigentes,
              'agendados': categoria.produtos.agendados,
            },
          ),
        );
      }
      categorias.remove(categoria);
      return const Success(Nada());
    });
  }

  bool _repetida(String nome, {String? exceto}) => categorias.any(
    (c) =>
        c.id != exceto &&
        c.nome.trim().toLowerCase() == nome.trim().toLowerCase(),
  );

  Future<Either<Falha, T>> _responder<T>(
    Either<Falha, T> Function() acao,
  ) async {
    await Future<void>.delayed(atraso);
    return switch (falhaSimulada) {
      final falha? => Failure(falha),
      null => acao(),
    };
  }
}

const _jaExiste = FalhaApi(
  codigo: 'CATEGORIA_JA_EXISTE',
  mensagem: 'Já existe uma categoria com esse nome nesta filial.',
);

const _naoEncontrado = FalhaApi(
  codigo: 'RECURSO_NAO_ENCONTRADO',
  mensagem: 'Não encontrado.',
);
