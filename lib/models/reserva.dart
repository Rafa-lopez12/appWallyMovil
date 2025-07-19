


import 'package:appwally/models/cancha.dart';
import 'package:appwally/models/cliente.dart';
import 'package:appwally/models/promocion.dart';
import 'package:appwally/models/users.dart';

class Reserva {
  final int id;
  final double monto;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final User? usuario;
  final Cliente cliente;
  final Cancha cancha;
  final Promocion promocion;

  Reserva({
    required this.id,
    required this.monto,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    this.usuario,
    required this.cliente,
    required this.cancha,
    required this.promocion,
  });

  // Factory constructor para crear desde JSON
  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] ?? 0,
      monto: (json['monto'] ?? 0).toDouble(),
      fechaHoraInicio: DateTime.parse(json['fecha_hora_inicio']),
      fechaHoraFin: DateTime.parse(json['fecha_hora_fin']),
      usuario: json['usuario'] != null ? User.fromJson(json['usuario']) : null,
      cliente: Cliente.fromJson(json['cliente']),
      cancha: Cancha.fromJson(json['cancha']),
      promocion: Promocion.fromJson(json['promocion']),
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monto': monto,
      'fecha_hora_inicio': fechaHoraInicio.toIso8601String(),
      'fecha_hora_fin': fechaHoraFin.toIso8601String(),
      'usuario': usuario?.toJson(),
      'cliente': cliente.toJson(),
      'cancha': cancha.toJson(),
      'promocion': promocion.toJson(),
    };
  }

  // Método copyWith para crear copias con cambios
  Reserva copyWith({
    int? id,
    double? monto,
    DateTime? fechaHoraInicio,
    DateTime? fechaHoraFin,
    User? usuario,
    Cliente? cliente,
    Cancha? cancha,
    Promocion? promocion,
  }) {
    return Reserva(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      fechaHoraInicio: fechaHoraInicio ?? this.fechaHoraInicio,
      fechaHoraFin: fechaHoraFin ?? this.fechaHoraFin,
      usuario: usuario ?? this.usuario,
      cliente: cliente ?? this.cliente,
      cancha: cancha ?? this.cancha,
      promocion: promocion ?? this.promocion,
    );
  }

  // Getters útiles
  Duration get duracion => fechaHoraFin.difference(fechaHoraInicio);
  
  int get duracionEnMinutos => duracion.inMinutes;
  
  int get duracionEnHoras => duracion.inHours;

  bool get isHoy {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reservaDate = DateTime(fechaHoraInicio.year, fechaHoraInicio.month, fechaHoraInicio.day);
    return today == reservaDate;
  }

  bool get isEnProgreso {
    final now = DateTime.now();
    return now.isAfter(fechaHoraInicio) && now.isBefore(fechaHoraFin);
  }

  bool get isTerminada {
    final now = DateTime.now();
    return now.isAfter(fechaHoraFin);
  }

  bool get isPendiente {
    final now = DateTime.now();
    return now.isBefore(fechaHoraInicio);
  }

  String get estadoTexto {
    if (isTerminada) return 'Terminada';
    if (isEnProgreso) return 'En progreso';
    if (isPendiente) return 'Pendiente';
    return 'Desconocido';
  }

  String get estadoColor {
    if (isTerminada) return 'grey';
    if (isEnProgreso) return 'green';
    if (isPendiente) return 'blue';
    return 'grey';
  }

  // Formatear fecha para mostrar
  String get fechaFormateada {
    return '${fechaHoraInicio.day.toString().padLeft(2, '0')}/'
           '${fechaHoraInicio.month.toString().padLeft(2, '0')}/'
           '${fechaHoraInicio.year}';
  }

  // Formatear hora de inicio
  String get horaInicioFormateada {
    return '${fechaHoraInicio.hour.toString().padLeft(2, '0')}:'
           '${fechaHoraInicio.minute.toString().padLeft(2, '0')}';
  }

  // Formatear hora de fin
  String get horaFinFormateada {
    return '${fechaHoraFin.hour.toString().padLeft(2, '0')}:'
           '${fechaHoraFin.minute.toString().padLeft(2, '0')}';
  }

  // Formatear rango de horas
  String get rangoHoras => '$horaInicioFormateada - $horaFinFormateada';

  @override
  String toString() {
    return 'Reserva{id: $id, monto: $monto, fechaHoraInicio: $fechaHoraInicio, fechaHoraFin: $fechaHoraFin, cliente: ${cliente.nombre}, cancha: ${cancha.cancha}}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reserva &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// DTO para crear reserva
class CreateReservaRequest {
  final double monto;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final String? usuario;
  final String cliente;
  final String cancha;
  final int promocion;

  CreateReservaRequest({
    required this.monto,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    this.usuario,
    required this.cliente,
    required this.cancha,
    required this.promocion,
  });

  Map<String, dynamic> toJson() {
    return {
      'monto': monto,
      'fecha_hora_inicio': fechaHoraInicio.toIso8601String(),
      'fecha_hora_fin': fechaHoraFin.toIso8601String(),
      if (usuario != null) 'usuario': usuario,
      'cliente': cliente,
      'cancha': cancha,
      'promocion': promocion,
    };
  }
}

// DTO para actualizar reserva
class UpdateReservaRequest {
  final double? monto;
  final DateTime? fechaHoraInicio;
  final DateTime? fechaHoraFin;
  final String? usuario;
  final String? cliente;
  final String? cancha;
  final int? promocion;

  UpdateReservaRequest({
    this.monto,
    this.fechaHoraInicio,
    this.fechaHoraFin,
    this.usuario,
    this.cliente,
    this.cancha,
    this.promocion,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (monto != null) data['monto'] = monto;
    if (fechaHoraInicio != null) data['fecha_hora_inicio'] = fechaHoraInicio!.toIso8601String();
    if (fechaHoraFin != null) data['fecha_hora_fin'] = fechaHoraFin!.toIso8601String();
    if (usuario != null) data['usuario'] = usuario;
    if (cliente != null) data['cliente'] = cliente;
    if (cancha != null) data['cancha'] = cancha;
    if (promocion != null) data['promocion'] = promocion;
    
    return data;
  }

  bool get hasUpdates {
    return monto != null || 
           fechaHoraInicio != null || 
           fechaHoraFin != null || 
           usuario != null || 
           cliente != null || 
           cancha != null || 
           promocion != null;
  }
}