import 'package:flutter/material.dart';
import '../models/cancha.dart';
import '../services/api_service.dart';

enum CanchasStatus { loading, loaded, error, empty }

class CanchasProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  CanchasStatus _status = CanchasStatus.loading;
  List<Cancha> _canchas = [];
  List<Cancha> _canchasDisponibles = [];
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  CanchasStatus get status => _status;
  List<Cancha> get canchas => _canchas;
  List<Cancha> get canchasDisponibles => _canchasDisponibles;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Cargar todas las canchas
  Future<void> loadCanchas() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getCanchas();
      
      if (response is List) {
        _canchas = response.map((json) => Cancha.fromJson(json)).toList();
        _updateCanchasDisponibles();
        
        if (_canchas.isEmpty) {
          _status = CanchasStatus.empty;
        } else {
          _status = CanchasStatus.loaded;
        }
      } else {
        _setError('Formato de respuesta inválido');
        _status = CanchasStatus.error;
      }
    } catch (e) {
      _setError('Error al cargar canchas: ${e.toString()}');
      _status = CanchasStatus.error;
    }

    _setLoading(false);
  }

  // Obtener cancha por ID
  Cancha? getCanchaById(int id) {
    try {
      return _canchas.firstWhere((cancha) => cancha.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener cancha por nombre
  Cancha? getCanchaByName(String nombre) {
    try {
      return _canchas.firstWhere(
        (cancha) => cancha.cancha.toLowerCase() == nombre.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Filtrar canchas por estado
  List<Cancha> getCanchasByEstado(int estado) {
    return _canchas.where((cancha) => cancha.estado == estado).toList();
  }

  // Obtener solo canchas disponibles
  List<Cancha> getCanchasDisponibles() {
    return _canchas.where((cancha) => cancha.isDisponible).toList();
  }

  // Verificar si una cancha está disponible
  bool isCanchaDisponible(int canchaId) {
    final cancha = getCanchaById(canchaId);
    return cancha?.isDisponible ?? false;
  }

  // Verificar si una cancha está en mantenimiento
  bool isCanchaEnMantenimiento(int canchaId) {
    final cancha = getCanchaById(canchaId);
    return cancha?.isMantenimiento ?? false;
  }

  // Contar canchas por estado
  Map<String, int> getCanchasCountByEstado() {
    return {
      'disponibles': _canchas.where((c) => c.isDisponible).length,
      'ocupadas': _canchas.where((c) => c.isOcupada).length,
      'mantenimiento': _canchas.where((c) => c.isMantenimiento).length,
    };
  }

  // Buscar canchas
  List<Cancha> searchCanchas(String query) {
    if (query.isEmpty) return _canchas;
    
    final queryLower = query.toLowerCase();
    return _canchas.where((cancha) {
      return cancha.cancha.toLowerCase().contains(queryLower) ||
             cancha.estadoTexto.toLowerCase().contains(queryLower);
    }).toList();
  }

  // Refrescar canchas
  Future<void> refresh() async {
    await loadCanchas();
  }

  // Actualizar estado de una cancha localmente
  void updateCanchaEstado(int canchaId, int nuevoEstado) {
    final index = _canchas.indexWhere((cancha) => cancha.id == canchaId);
    if (index != -1) {
      _canchas[index] = _canchas[index].copyWith(estado: nuevoEstado);
      _updateCanchasDisponibles();
      notifyListeners();
    }
  }

  // Marcar cancha como ocupada (para reservas en tiempo real)
  void marcarCanchaOcupada(int canchaId) {
    updateCanchaEstado(canchaId, 0); // 0 = ocupada
  }

  // Marcar cancha como disponible
  void marcarCanchaDisponible(int canchaId) {
    updateCanchaEstado(canchaId, 1); // 1 = disponible
  }

  // Marcar cancha en mantenimiento
  void marcarCanchaMantenimiento(int canchaId) {
    updateCanchaEstado(canchaId, 2); // 2 = mantenimiento
  }

  // Métodos privados
  void _updateCanchasDisponibles() {
    _canchasDisponibles = _canchas.where((cancha) => cancha.isDisponible).toList();
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
    _canchas.clear();
    _canchasDisponibles.clear();
    _status = CanchasStatus.loading;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // Simular actualización en tiempo real (WebSocket o polling)
  void simulateRealtimeUpdate() {
    // Este método se puede usar para simular cambios en tiempo real
    // En una implementación real, aquí irían los listeners de WebSocket
    loadCanchas();
  }

  // Obtener estadísticas de canchas
  Map<String, dynamic> getEstadisticas() {
    final total = _canchas.length;
    final disponibles = _canchas.where((c) => c.isDisponible).length;
    final ocupadas = _canchas.where((c) => c.isOcupada).length;
    final mantenimiento = _canchas.where((c) => c.isMantenimiento).length;

    return {
      'total': total,
      'disponibles': disponibles,
      'ocupadas': ocupadas,
      'mantenimiento': mantenimiento,
      'porcentajeDisponibles': total > 0 ? (disponibles / total * 100).round() : 0,
      'porcentajeOcupadas': total > 0 ? (ocupadas / total * 100).round() : 0,
    };
  }
}