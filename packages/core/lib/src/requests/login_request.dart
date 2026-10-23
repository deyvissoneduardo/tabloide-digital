/// Credenciais enviadas em `POST /auth/login`.
final class LoginRequest {
  /// Cria o pedido com o [email] e a [senha] do lojista.
  const LoginRequest({required this.email, required this.senha});

  /// E-mail de acesso.
  final String email;

  /// Senha em texto puro; só trafega no corpo do pedido.
  final String senha;

  /// Corpo JSON do pedido.
  Map<String, Object?> toJson() => {'email': email, 'senha': senha};

  @override
  bool operator ==(Object other) =>
      other is LoginRequest && other.email == email && other.senha == senha;

  @override
  int get hashCode => Object.hash(email, senha);

  @override
  String toString() => 'LoginRequest(email: $email)';
}
