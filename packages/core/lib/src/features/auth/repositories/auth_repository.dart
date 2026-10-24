import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/requests/login_request.dart';
import 'package:tabloide_core/src/responses/login_response.dart';

abstract interface class AuthRepository {
  Future<Either<Falha, LoginResponse>> entrar(LoginRequest request);
}
