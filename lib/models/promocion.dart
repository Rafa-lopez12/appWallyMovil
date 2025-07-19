class Promocion {
  final int id;
  final String motivo;
  final String descripcion;
  final double descuento;
  final int estado;

  Promocion({
    required this.id,
    required this.motivo,
    required this.descripcion,
    required this.descuento,
    required this.estado,
  });

  // Factory constructor para crear desde JSON
  factory Promocion.fromJson(Map<String, dynamic> json) {
    return Promocion(
      id: json['id'] ?? 0,
      motivo: json['motivo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      descuento: (json['descuento'] ?? 0).toDouble(),
      estado: json['estado'] ?? 0,
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motivo': motivo,
      'descripcion': descripcion,
      'descuento': descuento,
      'estado': estado,
    };
  }

  // Método copyWith para crear copias con cambios
  Promocion copyWith({
    int? id,
    String? motivo,
    String? descripcion,
    double? descuento,
    int? estado,
  }) {
    return Promocion(
      id: id ?? this.id,
      motivo: motivo ?? this.motivo,
      descripcion: descripcion ?? this.descripcion,
      descuento: descuento ?? this.descuento,
      estado: estado ?? this.estado,
    );
  }

  // Getters para el estado de la promoción
  bool get isActiva => estado == 1;
  bool get isInactiva => estado == 0;
  bool get isExpirada => estado == 2;

  // Getter para texto del estado
  String get estadoTexto {
    switch (estado) {
      case 1:
        return 'Activa';
      case 0:
        return 'Inactiva';
      case 2:
        return 'Expirada';
      default:
        return 'Desconocido';
    }
  }

  // Getter para color del estado
  String get estadoColor {
    switch (estado) {
      case 1:
        return 'green';  // Activa
      case 0:
        return 'grey';   // Inactiva
      case 2:
        return 'red';    // Expirada
      default:
        return 'grey';
    }
  }

  // Getter para texto de descuento formateado
  String get descuentoTexto {
    if (descuento % 1 == 0) {
      return '${descuento.toInt()}%';
    } else {
      return '${descuento.toStringAsFixed(1)}%';
    }
  }

  // Método para calcular precio con descuento
  double calcularPrecioConDescuento(double precioOriginal) {
    if (!isActiva) return precioOriginal;
    return precioOriginal - (precioOriginal * descuento / 100);
  }

  // Método para calcular monto del descuento
  double calcularMontoDescuento(double precioOriginal) {
    if (!isActiva) return 0;
    return precioOriginal * descuento / 100;
  }

  @override
  String toString() {
    return 'Promocion{id: $id, motivo: $motivo, descripcion: $descripcion, descuento: $descuento, estado: $estado}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Promocion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// DTO para crear promoción
class CreatePromocionRequest {
  final String motivo;
  final String descripcion;
  final double descuento;
  final int estado;

  CreatePromocionRequest({
    required this.motivo,
    required this.descripcion,
    required this.descuento,
    this.estado = 1, // Por defecto activa
  });

  Map<String, dynamic> toJson() {
    return {
      'motivo': motivo,
      'descripcion': descripcion,
      'descuento': descuento,
      'estado': estado,
    };
  }
}

// DTO para actualizar promoción
class UpdatePromocionRequest {
  final String? motivo;
  final String? descripcion;
  final double? descuento;
  final int? estado;

  UpdatePromocionRequest({
    this.motivo,
    this.descripcion,
    this.descuento,
    this.estado,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (motivo != null) data['motivo'] = motivo;
    if (descripcion != null) data['descripcion'] = descripcion;
    if (descuento != null) data['descuento'] = descuento;
    if (estado != null) data['estado'] = estado;
    
    return data;
  }

  bool get hasUpdates {
    return motivo != null || 
           descripcion != null || 
           descuento != null || 
           estado != null;
  }
}