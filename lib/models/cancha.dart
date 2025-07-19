class Cancha {
  final int id;
  final String cancha;
  final int estado;

  Cancha({
    required this.id,
    required this.cancha,
    required this.estado,
  });

  // Factory constructor para crear desde JSON
  factory Cancha.fromJson(Map<String, dynamic> json) {
    return Cancha(
      id: json['id'] ?? 0,
      cancha: json['cancha'] ?? '',
      estado: json['estado'] ?? 0,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cancha': cancha,
      'estado': estado,
    };
  }

  // Método copyWith para crear copias con cambios
  Cancha copyWith({
    int? id,
    String? cancha,
    int? estado,
  }) {
    return Cancha(
      id: id ?? this.id,
      cancha: cancha ?? this.cancha,
      estado: estado ?? this.estado,
    );
  }

  // Getters para el estado de la cancha
  bool get isDisponible => estado == 1;
  bool get isOcupada => estado == 0;
  bool get isMantenimiento => estado == 2;

  // Getter para texto del estado
  String get estadoTexto {
    switch (estado) {
      case 1:
        return 'Disponible';
      case 0:
        return 'Ocupada';
      case 2:
        return 'Mantenimiento';
      default:
        return 'Desconocido';
    }
  }

  // Getter para color del estado
  String get estadoColor {
    switch (estado) {
      case 1:
        return 'green'; // Disponible
      case 0:
        return 'red';   // Ocupada
      case 2:
        return 'orange'; // Mantenimiento
      default:
        return 'grey';
    }
  }

  @override
  String toString() {
    return 'Cancha{id: $id, cancha: $cancha, estado: $estado}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cancha &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// DTO para crear cancha (si fuera necesario)
class CreateCanchaRequest {
  final String cancha;
  final int estado;

  CreateCanchaRequest({
    required this.cancha,
    this.estado = 1, // Por defecto disponible
  });

  Map<String, dynamic> toJson() {
    return {
      'cancha': cancha,
      'estado': estado,
    };
  }
}

// DTO para actualizar cancha
class UpdateCanchaRequest {
  final String? cancha;
  final int? estado;

  UpdateCanchaRequest({
    this.cancha,
    this.estado,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (cancha != null) data['cancha'] = cancha;
    if (estado != null) data['estado'] = estado;
    
    return data;
  }

  bool get hasUpdates => cancha != null || estado != null;
}