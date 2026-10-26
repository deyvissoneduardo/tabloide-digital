import 'package:tabloide_core/tabloide_core.dart';

final class PerfilServiceApp {
  const PerfilServiceApp(this._lojistaRepository, this._identidadeRepository);

  final LojistaRepository _lojistaRepository;

  final IdentidadeRepository _identidadeRepository;

  Future<Either<Falha, LojistaResponse>> obterLojista() =>
      _lojistaRepository.obter();

  Future<Either<Falha, LojistaResponse>> editarLojista(
    LojistaRequest request,
  ) => _lojistaRepository.editar(request);

  Future<Either<Falha, IdentidadeResponse>> obterIdentidade() =>
      _identidadeRepository.obter();

  Future<Either<Falha, IdentidadeResponse>> editarIdentidade(
    IdentidadeRequest request,
  ) => _identidadeRepository.editar(request);

  Future<Either<Falha, IdentidadeResponse>> enviarLogo({
    required List<int> bytes,
    required String nomeArquivo,
  }) =>
      _identidadeRepository.enviarLogo(bytes: bytes, nomeArquivo: nomeArquivo);
}
