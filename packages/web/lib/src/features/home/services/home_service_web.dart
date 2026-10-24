import 'package:tabloide_core/tabloide_core.dart';

final class HomeServiceWeb implements HomeService {
  const HomeServiceWeb(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Falha, ResumoPainel>> buscarResumo() =>
      _repository.buscarResumo();
}
