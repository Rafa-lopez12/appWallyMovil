class User {
  final String id;
  final String nombre;
  final String username;
  final String telefono;
  final Role? rol;

  User({
    required this.id,
    required this.nombre,
    required this.username,
    required this.telefono,
    this.rol,
  });

  // Factory constructor para crear desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      username: json['username'] ?? '',
      telefono: json['telefono'] ?? '',
      rol: json['rol'] != null ? Role.fromJson(json['rol']) : null,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'username': username,
      'telefono': telefono,
      'rol': rol?.toJson(),
    };
  }

  // Método copyWith para crear copias con cambios
  User copyWith({
    String? id,
    String? nombre,
    String? username,
    String? telefono,
    Role? rol,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      username: username ?? this.username,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, nombre: $nombre, username: $username, telefono: $telefono, rol: $rol}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Modelo para el Rol (basado en tu entity Role)
class Role {
  final int id;
  final String rol;

  Role({
    required this.id,
    required this.rol,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? 0,
      rol: json['rol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rol': rol,
    };
  }

  @override
  String toString() {
    return 'Role{id: $id, rol: $rol}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Role &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// DTOs para requests de autenticación
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String nombre;
  final String username;
  final String password;
  final String telefono;

  RegisterRequest({
    required this.nombre,
    required this.username,
    required this.password,
    required this.telefono,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'username': username,
      'password': password,
      'telefono': telefono,
    };
  }
}

// Respuesta de login
class LoginResponse {
  final String id;
  final String nombre;
  final String username;
  final String token;

  LoginResponse({
    required this.id,
    required this.nombre,
    required this.username,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      username: json['username'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'username': username,
      'token': token,
    };
  }
}