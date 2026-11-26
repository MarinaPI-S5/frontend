import 'dart:convert';

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
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final userMap = json['user'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['user'] as Map<String, dynamic>)
        : (dataMap['user'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(
                  dataMap['user'] as Map<String, dynamic>,
                )
              : <String, dynamic>{});

    final token =
        (json['token'] ??
                json['accessToken'] ??
                dataMap['token'] ??
                dataMap['accessToken'] ??
                '')
            .toString();

    final jwtPayload = _decodeJwtPayload(token);

    final roleResolvido = _resolverRole(
      userMap: userMap,
      dataMap: dataMap,
      rootMap: json,
      jwtMap: jwtPayload,
    );

    if (roleResolvido.isNotEmpty) {
      userMap['role'] = roleResolvido;
    }

    final idResolvido =
        (userMap['id'] ??
                userMap['_id'] ??
                jwtPayload['id'] ??
                jwtPayload['_id'] ??
                jwtPayload['sub'] ??
                '')
            .toString();
    if (idResolvido.isNotEmpty &&
        (userMap['id'] == null || userMap['id'].toString().isEmpty)) {
      userMap['id'] = idResolvido;
    }

    final emailResolvido = (userMap['email'] ?? jwtPayload['email'] ?? '')
        .toString();
    if (emailResolvido.isNotEmpty &&
        (userMap['email'] == null || userMap['email'].toString().isEmpty)) {
      userMap['email'] = emailResolvido;
    }

    final hasSuccess = json['success'] is bool
        ? json['success'] as bool
        : token.isNotEmpty || userMap.isNotEmpty;

    return AuthSession(
      success: hasSuccess,
      token: token,
      user: AuthUser.fromJson(userMap),
    );
  }

  Map<String, dynamic> toStorage() {
    return {'success': success, 'token': token, 'user': user.toJson()};
  }

  factory AuthSession.fromStorage(Map<String, dynamic> json) {
    return AuthSession(
      success: json['success'] ?? false,
      token: json['token'] ?? '',
      user: AuthUser.fromJson(
        json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
    );
  }

  static String _resolverRole({
    required Map<String, dynamic> userMap,
    required Map<String, dynamic> dataMap,
    required Map<String, dynamic> rootMap,
    required Map<String, dynamic> jwtMap,
  }) {
    for (final map in [userMap, dataMap, rootMap, jwtMap]) {
      final candidato =
          map['role'] ?? map['perfil'] ?? map['tipo'] ?? map['userType'];
      if (candidato != null && candidato.toString().trim().isNotEmpty) {
        return candidato.toString().trim();
      }
      if (map['isAdmin'] == true) {
        return 'admin';
      }
    }
    return '';
  }

  static Map<String, dynamic> _decodeJwtPayload(String token) {
    try {
      final partes = token.split('.');
      if (partes.length != 3) return <String, dynamic>{};
      final normalized = base64Url.normalize(partes[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final parsed = jsonDecode(decoded);
      return parsed is Map<String, dynamic> ? parsed : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}

class AuthUser {
  final String id;
  final String email;
  final String role;

  const AuthUser({required this.id, required this.email, this.role = ''});

  bool get isAdmin {
    final r = role.trim().toLowerCase();
    return r == 'admin' || r == 'administrator';
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? json['_id'] ?? json['sub'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'role': role};
  }
}
