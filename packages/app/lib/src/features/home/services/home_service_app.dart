import 'package:tabloide_core/tabloide_core.dart';

/// [HomeService] do app: depende só do contrato [HomeRepository].
///
/// Regras exclusivas do mobile (ex.: cache offline) entram aqui, sem mudar o
/// repository nem o controller.
final class HomeServiceApp implements HomeService {
  /// Cria o service com o repository injetado.
  const HomeServiceApp(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Falha, ResumoPainel>> buscarResumo() =>
      _repository.buscarResumo();
}
