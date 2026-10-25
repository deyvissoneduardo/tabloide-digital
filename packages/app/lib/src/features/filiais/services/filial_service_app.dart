import 'package:tabloide_core/tabloide_core.dart';

final class FilialServiceApp {
  const FilialServiceApp(this._repository, this._cepRepository);

  final FilialRepository _repository;

  final CepRepository _cepRepository;

  Future<Either<Falha, List<FilialResponse>>> listar() => _repository.listar();

  Future<Either<Falha, FilialResponse>> criar(FilialRequest request) =>
      _repository.criar(request);

  Future<Either<Falha, FilialResponse>> editar(
    String id,
    FilialRequest request,
  ) => _repository.editar(id, request);

  Future<Either<Falha, Nada>> excluir(String id) => _repository.excluir(id);

  Future<Either<Falha, CepResponse>> buscarCep(String cep) =>
      _cepRepository.buscar(cep);
}
