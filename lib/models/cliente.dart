class Cliente {
  final String id;
  final String nombre;
  final String username;
  final String telefono;

  Cliente({
    required this.id,
    required this.nombre,
    required this.username,
    required this.telefono,
  });

  // Factory constructor para crear desde JSON
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      username: json['username'] ?? '',
      telefono: json['telefono'] ?? '',
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'username': username,
      'telefono': telefono,
    };
  }

  // Método copyWith para crear copias con cambios
  Cliente copyWith({
    String? id,
    String? nombre,
    String? username,
    String? telefono,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      username: username ?? this.username,
      telefono: telefono ?? this.telefono,
    );
  }

  @override
  String toString() {
    return 'Cliente{id: $id, nombre: $nombre, username: $username, telefono: $telefono}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cliente &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// DTO para crear cliente
class CreateClienteRequest {
  final String nombre;
  final String username;
  final String password;
  final String telefono;

  CreateClienteRequest({
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

// DTO para actualizar cliente
class UpdateClienteRequest {
  final String? nombre;
  final String? username;
  final String? password;
  final String? telefono;

  UpdateClienteRequest({
    this.nombre,
    this.username,
    this.password,
    this.telefono,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (nombre != null) data['nombre'] = nombre;
    if (username != null) data['username'] = username;
    if (password != null) data['password'] = password;
    if (telefono != null) data['telefono'] = telefono;
    
    return data;
  }

  // Verificar si el request tiene algún campo para actualizar
  bool get hasUpdates {
    return nombre != null || 
           username != null || 
           password != null || 
           telefono != null;
  }
}