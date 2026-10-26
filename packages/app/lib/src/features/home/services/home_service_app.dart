import 'package:tabloide_core/tabloide_core.dart';

final class HomeServiceApp implements HomeService {
  const HomeServiceApp(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Falha, ResumoPainel>> buscarResumo(List<String> filialIds) =>
      _repository.buscarResumo(filialIds);
}
