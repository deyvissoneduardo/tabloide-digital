final class LoginRequest {
  const LoginRequest({required this.email, required this.senha});

  final String email;

  final String senha;

  Map<String, Object?> toJson() => {'email': email, 'senha': senha};

  @override
  bool operator ==(Object other) =>
      other is LoginRequest && other.email == email && other.senha == senha;

  @override
  int get hashCode => Object.hash(email, senha);

  @override
  String toString() => 'LoginRequest(email: $email)';
}
