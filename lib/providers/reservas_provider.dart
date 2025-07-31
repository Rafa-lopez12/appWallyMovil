import 'package:appwally/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reserva.dart';
import '../models/cliente.dart';
import '../models/cancha.dart';
import '../models/promocion.dart';
import '../services/api_service.dart';

enum ReservasStatus { loading, loaded, error, empty }

class ReservasProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  ReservasStatus _status = ReservasStatus.loading;
  List<Reserva> _reservas = [];
  List<Reserva> _misReservas = [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _isCreating = false;

  // Getters
  ReservasStatus get status => _status;
  List<Reserva> get reservas => _reservas;
  List<Reserva> get misReservas => _misReservas;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;

  // Cargar todas las reservas
  Future<void> loadReservas() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getReservas();
      
      if (response is List) {
        _reservas = response.map((json) => Reserva.fromJson(json)).toList();
        
        // Ordenar por fecha más reciente
        _reservas.sort((a, b) => b.fechaHoraInicio.compareTo(a.fechaHoraInicio));
        
        if (_reservas.isEmpty) {
          _status = ReservasStatus.empty;
        } else {
          _status = ReservasStatus.loaded;
        }
      } else {
        _setError('Formato de respuesta inválido');
        _status = ReservasStatus.error;
      }
    } catch (e) {
      _setError('Error al cargar reservas: ${e.toString()}');
      _status = ReservasStatus.error;
    }

    _setLoading(false);
  }

  // Cargar mis reservas (de un cliente específico)
  Future<void> loadMisReservas(String clienteId) async {
    _setLoading(true);
    _clearError();

    try {
      await loadReservas(); // Primero cargar todas
      
      // Filtrar las reservas del cliente
      _misReservas = _reservas.where((reserva) => 
        reserva.cliente.id == clienteId
      ).toList();
      
      if (_misReservas.isEmpty) {
        _status = ReservasStatus.empty;
      } else {
        _status = ReservasStatus.loaded;
      }
    } catch (e) {
      _setError('Error al cargar mis reservas: ${e.toString()}');
      _status = ReservasStatus.error;
    }

    _setLoading(false);
  }

  // Crear nueva reserva
Future<bool> createReservaWithAuth({
  required double monto,
  required DateTime fechaHoraInicio,
  required DateTime fechaHoraFin,
  required String canchaNombre,
  required int promocionId,
  required String clienteNombre, // Siempre requerido - puede ser el mismo usuario o otro cliente
  String? usuarioNombre, // Opcional - solo si un usuario hace la reserva
}) async {
  _setCreating(true);
  _clearError();

  try {
    final createRequest = CreateReservaRequest(
      monto: monto,
      fechaHoraInicio: fechaHoraInicio,
      fechaHoraFin: fechaHoraFin,
      cliente: clienteNombre,
      cancha: canchaNombre,
      promocion: promocionId,
      usuario: usuarioNombre,
    );

    final response = await _apiService.createReserva(createRequest.toJson());
    
    if (response != null) {
      final nuevaReserva = Reserva.fromJson(response);
      _reservas.insert(0, nuevaReserva);
      
      // Si es una reserva del usuario actual, agregarla a misReservas
      if (_misReservas.isNotEmpty && 
          nuevaReserva.cliente.id == _misReservas.first.cliente.id) {
        _misReservas.insert(0, nuevaReserva);
      }
      
      _setCreating(false);
      notifyListeners();
      return true;
    } else {
      _setError('Error al crear la reserva');
      _setCreating(false);
      return false;
    }
  } catch (e) {
    _setError('Error al crear reserva: ${e.toString()}');
    _setCreating(false);
    return false;
  }
}

  // Actualizar reserva
  Future<bool> updateReserva(int reservaId, UpdateReservaRequest updateData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.updateReserva(reservaId, updateData.toJson());
      
      if (response != null) {
        final reservaActualizada = Reserva.fromJson(response);
        
        // Actualizar en la lista principal
        final index = _reservas.indexWhere((r) => r.id == reservaId);
        if (index != -1) {
          _reservas[index] = reservaActualizada;
        }
        
        // Actualizar en mis reservas si existe
        final misIndex = _misReservas.indexWhere((r) => r.id == reservaId);
        if (misIndex != -1) {
          _misReservas[misIndex] = reservaActualizada;
        }
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Error al actualizar la reserva');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar reserva: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Cancelar/Eliminar reserva
  Future<bool> cancelReserva(int reservaId) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.deleteReserva(reservaId);
      
      // Remover de las listas locales
      _reservas.removeWhere((r) => r.id == reservaId);
      _misReservas.removeWhere((r) => r.id == reservaId);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al cancelar reserva: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Obtener reserva por ID
  Reserva? getReservaById(int id) {
    try {
      return _reservas.firstWhere((reserva) => reserva.id == id);
    } catch (e) {
      return null;
    }
  }

  // Verificar disponibilidad de horario
  bool isHorarioDisponible({
    required String canchaNombre,
    required DateTime fechaHoraInicio,
    required DateTime fechaHoraFin,
    int? excludeReservaId,
  }) {
    return !_reservas.any((reserva) {
      // Excluir la reserva que se está editando
      if (excludeReservaId != null && reserva.id == excludeReservaId) {
        return false;
      }
      
      // Verificar si es la misma cancha
      if (reserva.cancha.cancha != canchaNombre) {
        return false;
      }
      
      // Verificar solapamiento de horarios
      return (fechaHoraInicio.isBefore(reserva.fechaHoraFin) &&
              fechaHoraFin.isAfter(reserva.fechaHoraInicio));
    });
  }

  // Obtener reservas por fecha
  List<Reserva> getReservasByFecha(DateTime fecha) {
    return _reservas.where((reserva) {
      final reservaDate = DateTime(
        reserva.fechaHoraInicio.year,
        reserva.fechaHoraInicio.month,
        reserva.fechaHoraInicio.day,
      );
      final targetDate = DateTime(fecha.year, fecha.month, fecha.day);
      return reservaDate == targetDate;
    }).toList();
  }

  // Obtener reservas de hoy
  List<Reserva> getReservasHoy() {
    return getReservasByFecha(DateTime.now());
  }

  // Obtener próximas reservas
  List<Reserva> getProximasReservas({int limit = 5}) {
    final now = DateTime.now();
    return _reservas
        .where((reserva) => reserva.fechaHoraInicio.isAfter(now))
        .take(limit)
        .toList();
  }

  // Obtener reservas en progreso
  List<Reserva> getReservasEnProgreso() {
    return _reservas.where((reserva) => reserva.isEnProgreso).toList();
  }

  // Filtrar reservas
  List<Reserva> filterReservas({
    String? clienteNombre,
    String? canchaNombre,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    return _reservas.where((reserva) {
      bool matches = true;
      
      if (clienteNombre != null && clienteNombre.isNotEmpty) {
        matches = matches && 
            reserva.cliente.nombre.toLowerCase().contains(clienteNombre.toLowerCase());
      }
      
      if (canchaNombre != null && canchaNombre.isNotEmpty) {
        matches = matches && 
            reserva.cancha.cancha.toLowerCase().contains(canchaNombre.toLowerCase());
      }
      
      if (fechaInicio != null) {
        matches = matches && 
            reserva.fechaHoraInicio.isAfter(fechaInicio.subtract(const Duration(days: 1)));
      }
      
      if (fechaFin != null) {
        matches = matches && 
            reserva.fechaHoraInicio.isBefore(fechaFin.add(const Duration(days: 1)));
      }
      
      return matches;
    }).toList();
  }

  // Obtener estadísticas de reservas
  Map<String, dynamic> getEstadisticas() {
    final total = _reservas.length;
    final hoy = getReservasHoy().length;
    final enProgreso = getReservasEnProgreso().length;
    final proximas = getProximasReservas().length;
    
    // Calcular ingresos del día
    final ingresosHoy = getReservasHoy()
        .fold<double>(0, (sum, reserva) => sum + reserva.monto);
    
    // Calcular ingresos totales
    final ingresosTotal = _reservas
        .fold<double>(0, (sum, reserva) => sum + reserva.monto);

    return {
      'total': total,
      'hoy': hoy,
      'enProgreso': enProgreso,
      'proximas': proximas,
      'ingresosHoy': ingresosHoy,
      'ingresosTotal': ingresosTotal,
    };
  }

  // Refrescar reservas
  Future<void> refresh() async {
    await loadReservas();
  }

  // Métodos privados
 

  void _setCreating(bool creating) {
    _isCreating = creating;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      // Usar addPostFrameCallback para evitar llamar notifyListeners durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Limpiar estado
  void clearState() {
    _reservas.clear();
    _misReservas.clear();
    _status = ReservasStatus.loading;
    _errorMessage = null;
    _isLoading = false;
    _isCreating = false;
    notifyListeners();
  }
}