import 'cliente.dart';

class Sugerencia {
  final int id;
  final String descripcion;
  final Cliente cliente;

  Sugerencia({
    required this.id,
    required this.descripcion,
    required this.cliente,
  });

  // Factory constructor para crear desde JSON
  factory Sugerencia.fromJson(Map<String, dynamic> json) {
    return Sugerencia(
      id: json['id'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      cliente: Cliente.fromJson(json['cliente']),
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'cliente': cliente.toJson(),
    };
  }

  // Método copyWith para crear copias con cambios
  Sugerencia copyWith({
    int? id,
    String? descripcion,
    Cliente? cliente,
  }) {
    return Sugerencia(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      cliente: cliente ?? this.cliente,
    );
  }

  // Getter para obtener el nombre del cliente
  String get nombreCliente => cliente.nombre;

  // Getter para verificar si la descripción es larga
  bool get isDescripcionLarga => descripcion.length > 100;

  // Getter para obtener descripción truncada
  String get descripcionTruncada {
    if (descripcion.length <= 100) return descripcion;
    return '${descripcion.substring(0, 100)}...';
  }

  @override
  String toString() {
    return 'Sugerencia{id: $id, descripcion: $descripcion, cliente: ${cliente.nombre}}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sugerencia &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// DTO para crear sugerencia
class CreateSugerenciaRequest {
  final String descripcion;

  CreateSugerenciaRequest({
    required this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      'descripcion': descripcion,
    };
  }
}

// DTO para actualizar sugerencia
class UpdateSugerenciaRequest {
  final String? descripcion;

  UpdateSugerenciaRequest({
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (descripcion != null) data['descripcion'] = descripcion;
    
    return data;
  }

  bool get hasUpdates => descripcion != null;
}