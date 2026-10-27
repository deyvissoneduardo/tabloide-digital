import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/estrutura/repositories/estrutura_repository.dart';
import 'package:tabloide_core/src/features/vigencia/models/situacao_vigencia.dart';
import 'package:tabloide_core/src/features/vigencia/models/vigencia.dart';
import 'package:tabloide_core/src/requests/estrutura_request.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';

final produtoEstruturaFakeBanana = ProdutoEstruturaResponse(
  id: '0193a0b0-1111-7000-8000-000000000001',
  nome: 'Banana prata',
  quantidade: 'kg',
  precoPromocionalCentavos: 499,
  precoOriginalCentavos: 699,
  vigencia: Vigencia(
    dataInicio: DateTime(2026, 10, 20),
    dataLimite: DateTime(2026, 11, 20),
    situacao: SituacaoVigencia.vigente,
    editavel: true,
  ),
);

final produtoEstruturaFakeMaca = ProdutoEstruturaResponse(
  id: '0193a0b0-1111-7000-8000-000000000002',
  nome: 'Maçã gala',
  quantidade: 'kg',
  observacao: 'Limite 3 por cliente',
  precoPromocionalCentavos: 899,
  vigencia: Vigencia(
    dataInicio: DateTime(2026, 11, 1),
    situacao: SituacaoVigencia.agendado,
    editavel: true,
  ),
);

final produtoEstruturaFakeArroz = ProdutoEstruturaResponse(
  id: '0193a0b0-1111-7000-8000-000000000003',
  nome: 'Arroz 5 kg',
  descricao: 'Tipo 1',
  precoPromocionalCentavos: 2490,
  vigencia: Vigencia(
    dataInicio: DateTime(2026, 10, 20),
    situacao: SituacaoVigencia.vigente,
    editavel: true,
  ),
);

/// 2 categorias, 3 produtos (1 agendado).
final estruturaFake = EstruturaResponse(
  categorias: [
    CategoriaEstruturaResponse(
      id: '0192a0b0-2222-7000-8000-000000000001',
      nome: 'Hortifrúti',
      produtos: [produtoEstruturaFakeBanana, produtoEstruturaFakeMaca],
    ),
    CategoriaEstruturaResponse(
      id: '0192a0b0-2222-7000-8000-000000000002',
      nome: 'Mercearia',
      produtos: [produtoEstruturaFakeArroz],
    ),
  ],
);

final class EstruturaRepositoryFake implements EstruturaRepository {
  EstruturaRepositoryFake({
    EstruturaResponse? estrutura,
    this.falha,
    this.falhaAoSalvar,
    this.atraso = Duration.zero,
  }) : estrutura = estrutura ?? estruturaFake;

  EstruturaResponse estrutura;

  Falha? falha;

  Falha? falhaAoSalvar;

  Duration atraso;

  final obtidas = <String>[];

  final pedidos = <EstruturaRequest>[];

  @override
  Future<Either<Falha, EstruturaResponse>> obter(String filialId) async {
    obtidas.add(filialId);
    await Future<void>.delayed(atraso);
    return switch (falha) {
      final falha? => Failure(falha),
      null => Success(estrutura),
    };
  }

  @override
  Future<Either<Falha, EstruturaResponse>> salvar(
    String filialId,
    EstruturaRequest request,
  ) async {
    pedidos.add(request);
    await Future<void>.delayed(atraso);
    if (falhaAoSalvar ?? falha case final falha?) return Failure(falha);
    return Success(estrutura = _reordenar(request));
  }

  EstruturaResponse _reordenar(EstruturaRequest request) {
    int posicao(List<String> ids, String id) {
      final i = ids.indexOf(id);
      return i < 0 ? ids.length : i;
    }

    final idsCategorias = [for (final c in request.categorias) c.id];
    final categorias = [...estrutura.categorias]
      ..sort(
        (a, b) => posicao(
          idsCategorias,
          a.id,
        ).compareTo(posicao(idsCategorias, b.id)),
      );
    return EstruturaResponse(
      categorias: [
        for (final categoria in categorias)
          categoria.comProdutos(
            [...categoria.produtos]..sort((a, b) {
              final ids = [
                for (final c in request.categorias)
                  if (c.id == categoria.id) ...c.produtos,
              ];
              return posicao(ids, a.id).compareTo(posicao(ids, b.id));
            }),
          ),
      ],
    );
  }
}
