import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/either/nada.dart';
import 'package:tabloide_core/src/features/filiais/models/endereco.dart';
import 'package:tabloide_core/src/features/filiais/repositories/filial_repository.dart';
import 'package:tabloide_core/src/requests/filial_request.dart';
import 'package:tabloide_core/src/responses/filial_response.dart';

final filialFake = FilialResponse(
  id: '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b02',
  nome: 'Centro',
  endereco: const Endereco(
    cep: '13010111',
    logradouro: 'Rua das Flores',
    numero: '120',
    complemento: 'Loja 2',
    bairro: 'Centro',
    cidade: 'Campinas',
    uf: 'SP',
  ),
  fusoHorario: 'America/Sao_Paulo',
  codigoPublico: 'k7Qm2xPa',
  urlPublica: 'https://tabloide.app/f/k7Qm2xPa',
  criadaEm: DateTime.utc(2026, 10, 18, 13, 5),
  atualizadaEm: DateTime.utc(2026, 10, 18, 13, 5),
);

final filialFakeBairro = FilialResponse(
  id: '0192f0b4-7d3f-7c21-8e4b-2d3e4f5a6b03',
  nome: 'Bairro Alto',
  endereco: const Endereco(
    cep: '13020200',
    logradouro: 'Avenida Brasil',
    numero: '900',
    bairro: 'Jardim Chapadão',
    cidade: 'Campinas',
    uf: 'SP',
  ),
  fusoHorario: 'America/Sao_Paulo',
  codigoPublico: 'p3Rt8yLb',
  urlPublica: 'https://tabloide.app/f/p3Rt8yLb',
  criadaEm: DateTime.utc(2026, 10, 19, 9),
  atualizadaEm: DateTime.utc(2026, 10, 19, 9),
);

final class FilialRepositoryFake implements FilialRepository {
  FilialRepositoryFake({
    List<FilialResponse>? filiais,
    this.falhaSimulada,
    this.atraso = Duration.zero,
  }) : filiais = [...?filiais];

  final List<FilialResponse> filiais;

  Falha? falhaSimulada;

  final Duration atraso;

  final pedidos = <FilialRequest>[];

  final excluidas = <String>[];

  @override
  Future<Either<Falha, List<FilialResponse>>> listar() =>
      _responder(() => [...filiais]);

  @override
  Future<Either<Falha, FilialResponse>> obter(String id) async {
    await Future<void>.delayed(atraso);
    if (falhaSimulada case final falha?) return Failure(falha);
    return switch (filiais.where((f) => f.id == id).firstOrNull) {
      final filial? => Success(filial),
      null => const Failure(_naoEncontrada),
    };
  }

  @override
  Future<Either<Falha, FilialResponse>> criar(FilialRequest request) {
    pedidos.add(request);
    return _responder(() {
      final filial = _filialDe('filial-fake-${filiais.length + 1}', request);
      filiais.add(filial);
      return filial;
    });
  }

  @override
  Future<Either<Falha, FilialResponse>> editar(
    String id,
    FilialRequest request,
  ) {
    pedidos.add(request);
    return _responder(() {
      final filial = _filialDe(id, request);
      final i = filiais.indexWhere((f) => f.id == id);
      if (i >= 0) filiais[i] = filial;
      return filial;
    });
  }

  @override
  Future<Either<Falha, Nada>> excluir(String id) {
    excluidas.add(id);
    return _responder(() {
      filiais.removeWhere((f) => f.id == id);
      return const Nada();
    });
  }

  Future<Either<Falha, T>> _responder<T>(T Function() acao) async {
    await Future<void>.delayed(atraso);
    return switch (falhaSimulada) {
      final falha? => Failure(falha),
      null => Success(acao()),
    };
  }

  FilialResponse _filialDe(String id, FilialRequest request) => FilialResponse(
    id: id,
    nome: request.nome,
    endereco: request.endereco,
    fusoHorario: request.fusoHorario,
    codigoPublico: 'codigo-$id',
    urlPublica: 'https://tabloide.app/f/codigo-$id',
    criadaEm: filialFake.criadaEm,
    atualizadaEm: filialFake.atualizadaEm,
  );
}

const _naoEncontrada = FalhaApi(
  codigo: 'RECURSO_NAO_ENCONTRADO',
  mensagem: 'Não encontrado.',
);
