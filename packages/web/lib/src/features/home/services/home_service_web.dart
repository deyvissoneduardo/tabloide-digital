import 'package:tabloide_core/tabloide_core.dart';

/// [HomeService] da web: depende só do contrato [HomeRepository].
///
/// Regras exclusivas do navegador (ex.: cache em `localStorage`) entram aqui,
/// sem mudar o repository nem o controller.
final class HomeServiceWeb implements HomeService {
  /// Cria o service com o repository injetado.
  const HomeServiceWeb(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Falha, ResumoPainel>> buscarResumo() =>
      _repository.buscarResumo();
}
