import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/features/produtos/models/categoria_do_produto.dart';
import 'package:tabloide_core/src/features/produtos/repositories/produto_repository.dart';
import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';
import 'package:tabloide_core/src/features/vigencia/models/situacao_vigencia.dart';
import 'package:tabloide_core/src/features/vigencia/models/vigencia.dart';
import 'package:tabloide_core/src/requests/editar_produto_request.dart';
import 'package:tabloide_core/src/requests/produto_request.dart';
import 'package:tabloide_core/src/responses/produto_response.dart';

final produtoFake = ProdutoResponse(
  id: '0192f0d0-a062-7f54-9b7e-5a6b7c8d9e05',
  filialId: '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02',
  categoria: const CategoriaDoProduto(
    id: '0192f0c1-9f51-7e43-8a6d-4f5a6b7c8d04',
    nome: 'Mercearia',
  ),
  nome: 'Arroz Tipo 1',
  quantidade: '5kg',
  precoPromocionalCentavos: 2199,
  precoOriginalCentavos: 2649,
  observacao: 'Limite 3 por cliente',
  urlFoto:
      'https://xyz.supabase.co/storage/v1/object/public/midia/'
      '0192f0a1-6c2e-7b10-9f3a-1c2d3e4f5a01/produto/0192f0d1.webp',
  vigencia: Vigencia(
    dataInicio: DateTime(2026, 10, 18),
    dataLimite: DateTime(2026, 10, 25),
    situacao: SituacaoVigencia.vigente,
    editavel: true,
  ),
  criadoEm: DateTime.utc(2026, 10, 18, 15, 10),
  atualizadoEm: DateTime.utc(2026, 10, 18, 15, 10),
);

final produtoFakeAgendado = ProdutoResponse(
  id: '0192f0d0-a062-7f54-9b7e-5a6b7c8d9e06',
  filialId: '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02',
  categoria: const CategoriaDoProduto(
    id: '0192f0c1-9f51-7e43-8a6d-4f5a6b7c8d05',
    nome: 'Bebidas',
  ),
  nome: 'Refrigerante cola',
  quantidade: '2 L',
  precoPromocionalCentavos: 799,
  vigencia: Vigencia(
    dataInicio: DateTime(2026, 11, 1),
    situacao: SituacaoVigencia.agendado,
    editavel: true,
  ),
  criadoEm: DateTime.utc(2026, 10, 19, 9),
  atualizadoEm: DateTime.utc(2026, 10, 19, 9),
);

final class ProdutoRepositoryFake implements ProdutoRepository {
  ProdutoRepositoryFake({
    List<ProdutoResponse>? produtos,
    this.falhaSimulada,
    this.atraso = Duration.zero,
  }) : produtos = [...?produtos];

  final List<ProdutoResponse> produtos;

  Falha? falhaSimulada;

  final Duration atraso;

  final pedidos = <ProdutoRequest>[];

  final edicoes = <EditarProdutoRequest>[];

  final fotosEnviadas = <String>[];

  final fotosRemovidas = <String>[];

  final excluidos = <String>[];

  @override
  Future<Either<Falha, List<ProdutoResponse>>> listar(String filialId) =>
      _responder(() => [...produtos]);

  @override
  Future<Either<Falha, ProdutoResponse>> obter(
    String filialId,
    String id,
  ) async {
    await Future<void>.delayed(atraso);
    if (falhaSimulada case final falha?) return Failure(falha);
    return switch (produtos.where((p) => p.id == id).firstOrNull) {
      final produto? => Success(produto),
      null => const Failure(_naoEncontrado),
    };
  }

  @override
  Future<Either<Falha, ProdutoResponse>> criar(
    String filialId,
    ProdutoRequest request, {
    ArquivoProduto? foto,
  }) {
    pedidos.add(request);
    if (foto != null) fotosEnviadas.add(foto.nome);
    return _responder(() {
      final hoje = DataDia.hoje();
      final inicio = request.dataInicio ?? hoje;
      final agora = DateTime.now().toUtc();
      final json = request.toJson();
      final produto = ProdutoResponse(
        id: 'produto-fake-${produtos.length + 1}',
        filialId: filialId,
        categoria: CategoriaDoProduto(
          id: request.categoriaId,
          nome: _nomeDaCategoria(request.categoriaId),
        ),
        nome: request.nome.trim(),
        quantidade: json['quantidade'] as String?,
        precoPromocionalCentavos: request.precoPromocionalCentavos,
        precoOriginalCentavos: request.precoOriginalCentavos,
        descricao: json['descricao'] as String?,
        observacao: json['observacao'] as String?,
        urlFoto: foto == null
            ? null
            : 'https://midia.fake/produto/${foto.nome}',
        vigencia: Vigencia(
          dataInicio: inicio,
          dataLimite: request.dataLimite,
          situacao: inicio.isAfter(hoje)
              ? SituacaoVigencia.agendado
              : SituacaoVigencia.vigente,
          editavel: true,
        ),
        criadoEm: agora,
        atualizadoEm: agora,
      );
      produtos.add(produto);
      return produto;
    });
  }

  @override
  Future<Either<Falha, ProdutoResponse>> editar(
    String filialId,
    String id,
    EditarProdutoRequest request,
  ) {
    edicoes.add(request);
    return _responder(
      () => _substituir(id, (atual) {
        final json = request.toJson();
        T valor<T>(String campo, T atual) =>
            json.containsKey(campo) ? json[campo] as T : atual;
        final vigencia = atual.vigencia;
        final categoriaId = valor('categoriaId', atual.categoria.id);
        return ProdutoResponse(
          id: atual.id,
          filialId: atual.filialId,
          categoria: categoriaId == atual.categoria.id
              ? atual.categoria
              : CategoriaDoProduto(
                  id: categoriaId,
                  nome: _nomeDaCategoria(categoriaId),
                ),
          nome: valor('nome', atual.nome),
          quantidade: valor('quantidade', atual.quantidade),
          precoPromocionalCentavos: valor(
            'precoPromocionalCentavos',
            atual.precoPromocionalCentavos,
          ),
          precoOriginalCentavos: valor(
            'precoOriginalCentavos',
            atual.precoOriginalCentavos,
          ),
          descricao: valor('descricao', atual.descricao),
          observacao: valor('observacao', atual.observacao),
          urlFoto: atual.urlFoto,
          vigencia: Vigencia(
            dataInicio: switch (json['dataInicio']) {
              final String inicio => DataDia.ler(inicio),
              _ => vigencia.dataInicio,
            },
            dataLimite: json.containsKey('dataLimite')
                ? switch (json['dataLimite']) {
                    final String limite => DataDia.ler(limite),
                    _ => null,
                  }
                : vigencia.dataLimite,
            situacao: vigencia.situacao,
            editavel: vigencia.editavel,
          ),
          criadoEm: atual.criadoEm,
          atualizadoEm: DateTime.now().toUtc(),
          excluidoEm: atual.excluidoEm,
        );
      }),
    );
  }

  @override
  Future<Either<Falha, ProdutoResponse>> trocarFoto(
    String filialId,
    String id,
    ArquivoProduto foto,
  ) {
    fotosEnviadas.add(foto.nome);
    return _responder(
      () => _substituir(
        id,
        (atual) => _comFoto(atual, 'https://midia.fake/produto/${foto.nome}'),
      ),
    );
  }

  @override
  Future<Either<Falha, ProdutoResponse>> removerFoto(
    String filialId,
    String id,
  ) {
    fotosRemovidas.add(id);
    return _responder(() => _substituir(id, (atual) => _comFoto(atual, null)));
  }

  @override
  Future<Either<Falha, Nada>> excluir(String filialId, String id) {
    excluidos.add(id);
    return _responder(() {
      produtos.removeWhere((p) => p.id == id);
      return const Nada();
    });
  }

  String _nomeDaCategoria(String categoriaId) =>
      produtos
          .where((p) => p.categoria.id == categoriaId)
          .firstOrNull
          ?.categoria
          .nome ??
      'Categoria';

  ProdutoResponse _substituir(
    String id,
    ProdutoResponse Function(ProdutoResponse atual) alterar,
  ) {
    final i = produtos.indexWhere((p) => p.id == id);
    return produtos[i] = alterar(produtos[i]);
  }

  ProdutoResponse _comFoto(ProdutoResponse atual, String? urlFoto) =>
      ProdutoResponse(
        id: atual.id,
        filialId: atual.filialId,
        categoria: atual.categoria,
        nome: atual.nome,
        quantidade: atual.quantidade,
        precoPromocionalCentavos: atual.precoPromocionalCentavos,
        precoOriginalCentavos: atual.precoOriginalCentavos,
        descricao: atual.descricao,
        observacao: atual.observacao,
        urlFoto: urlFoto,
        vigencia: atual.vigencia,
        criadoEm: atual.criadoEm,
        atualizadoEm: DateTime.now().toUtc(),
        excluidoEm: atual.excluidoEm,
      );

  Future<Either<Falha, T>> _responder<T>(T Function() acao) async {
    await Future<void>.delayed(atraso);
    return switch (falhaSimulada) {
      final falha? => Failure(falha),
      null => Success(acao()),
    };
  }
}

const _naoEncontrado = FalhaApi(
  codigo: 'RECURSO_NAO_ENCONTRADO',
  mensagem: 'Não encontrado.',
);
