class AuthSession {
  final bool success;
  final String token;
  final AuthUser user;

  const AuthSession({
    required this.success,
    required this.token,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      success: json['success'] ?? false,
      token: json['token'] ?? '',
      user: AuthUser.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toStorage() {
    return {'success': success, 'token': token, 'user': user.toJson()};
  }

  factory AuthSession.fromStorage(Map<String, dynamic> json) {
    return AuthSession(
      success: json['success'] ?? false,
      token: json['token'] ?? '',
      user: AuthUser.fromJson(json['user'] ?? {}),
    );
  }
}

class AuthUser {
  final String id;
  final String email;

  const AuthUser({required this.id, required this.email});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(id: json['id'] ?? '', email: json['email'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }
}
