import 'package:flutter/material.dart';
import '../models/promocion.dart';
import '../services/api_service.dart';

enum PromocionesStatus { loading, loaded, error, empty }

class PromocionesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  PromocionesStatus _status = PromocionesStatus.loading;
  List<Promocion> _promociones = [];
  List<Promocion> _promocionesActivas = [];
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  PromocionesStatus get status => _status;
  List<Promocion> get promociones => _promociones;
  List<Promocion> get promocionesActivas => _promocionesActivas;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Cargar todas las promociones
  Future<void> loadPromociones() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getPromociones();
      
      if (response is List) {
        _promociones = response.map((json) => Promocion.fromJson(json)).toList();
        _updatePromocionesActivas();
        
        if (_promociones.isEmpty) {
          _status = PromocionesStatus.empty;
        } else {
          _status = PromocionesStatus.loaded;
        }
      } else {
        _setError('Formato de respuesta inválido');
        _status = PromocionesStatus.error;
      }
    } catch (e) {
      _setError('Error al cargar promociones: ${e.toString()}');
      _status = PromocionesStatus.error;
    }

    _setLoading(false);
  }

  // Crear nueva promoción (solo admins)
  Future<bool> createPromocion({
    required String motivo,
    required String descripcion,
    required double descuento,
    int estado = 1,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final createRequest = CreatePromocionRequest(
        motivo: motivo,
        descripcion: descripcion,
        descuento: descuento,
        estado: estado,
      );

      final response = await _apiService.createPromocion(createRequest.toJson());
      
      if (response != null) {
        final nuevaPromocion = Promocion.fromJson(response);
        _promociones.insert(0, nuevaPromocion);
        _updatePromocionesActivas();
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Error al crear la promoción');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al crear promoción: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Actualizar promoción (solo admins)
  Future<bool> updatePromocion(int promocionId, UpdatePromocionRequest updateData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.updatePromocion(promocionId, updateData.toJson());
      
      if (response != null) {
        final promocionActualizada = Promocion.fromJson(response);
        
        final index = _promociones.indexWhere((p) => p.id == promocionId);
        if (index != -1) {
          _promociones[index] = promocionActualizada;
          _updatePromocionesActivas();
        }
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Error al actualizar la promoción');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar promoción: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Obtener promoción por ID
  Promocion? getPromocionById(int id) {
    try {
      return _promociones.firstWhere((promocion) => promocion.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener promociones por estado
  List<Promocion> getPromocionesByEstado(int estado) {
    return _promociones.where((promocion) => promocion.estado == estado).toList();
  }

  // Obtener solo promociones activas
  List<Promocion> getPromocionesActivas() {
    return _promociones.where((promocion) => promocion.isActiva).toList();
  }

  // Obtener mejor promoción disponible
  Promocion? getMejorPromocion() {
    if (_promocionesActivas.isEmpty) return null;
    
    // Ordenar por descuento descendente y tomar la primera
    final promocionesOrdenadas = List<Promocion>.from(_promocionesActivas);
    promocionesOrdenadas.sort((a, b) => b.descuento.compareTo(a.descuento));
    
    return promocionesOrdenadas.first;
  }

  // Calcular precio con promoción
  double calcularPrecioConPromocion(double precioOriginal, int? promocionId) {
    if (promocionId == null) return precioOriginal;
    
    final promocion = getPromocionById(promocionId);
    if (promocion == null || !promocion.isActiva) return precioOriginal;
    
    return promocion.calcularPrecioConDescuento(precioOriginal);
  }

  // Obtener descuento aplicable
  double getDescuentoAplicable(int? promocionId) {
    if (promocionId == null) return 0;
    
    final promocion = getPromocionById(promocionId);
    if (promocion == null || !promocion.isActiva) return 0;
    
    return promocion.descuento;
  }

  // Buscar promociones
  List<Promocion> searchPromociones(String query) {
    if (query.isEmpty) return _promociones;
    
    final queryLower = query.toLowerCase();
    return _promociones.where((promocion) {
      return promocion.motivo.toLowerCase().contains(queryLower) ||
             promocion.descripcion.toLowerCase().contains(queryLower);
    }).toList();
  }

  // Activar promoción
  Future<bool> activarPromocion(int promocionId) async {
    return await updatePromocion(
      promocionId,
      UpdatePromocionRequest(estado: 1),
    );
  }

  // Desactivar promoción
  Future<bool> desactivarPromocion(int promocionId) async {
    return await updatePromocion(
      promocionId,
      UpdatePromocionRequest(estado: 0),
    );
  }

  // Marcar promoción como expirada
  Future<bool> expirarPromocion(int promocionId) async {
    return await updatePromocion(
      promocionId,
      UpdatePromocionRequest(estado: 2),
    );
  }

  // Contar promociones por estado
  Map<String, int> getPromocionesCountByEstado() {
    return {
      'activas': _promociones.where((p) => p.isActiva).length,
      'inactivas': _promociones.where((p) => p.isInactiva).length,
      'expiradas': _promociones.where((p) => p.isExpirada).length,
    };
  }

  // Obtener estadísticas de promociones
  Map<String, dynamic> getEstadisticas() {
    final total = _promociones.length;
    final activas = _promociones.where((p) => p.isActiva).length;
    final inactivas = _promociones.where((p) => p.isInactiva).length;
    final expiradas = _promociones.where((p) => p.isExpirada).length;
    
    // Promoción con mayor descuento
    final mayorDescuento = _promocionesActivas.isNotEmpty 
        ? _promocionesActivas.map((p) => p.descuento).reduce((a, b) => a > b ? a : b)
        : 0.0;
    
    // Descuento promedio
    final descuentoPromedio = _promocionesActivas.isNotEmpty
        ? _promocionesActivas.map((p) => p.descuento).reduce((a, b) => a + b) / _promocionesActivas.length
        : 0.0;

    return {
      'total': total,
      'activas': activas,
      'inactivas': inactivas,
      'expiradas': expiradas,
      'mayorDescuento': mayorDescuento,
      'descuentoPromedio': descuentoPromedio.toStringAsFixed(1),
      'porcentajeActivas': total > 0 ? (activas / total * 100).round() : 0,
    };
  }

  // Validar si una promoción se puede aplicar
  bool puedeAplicarPromocion(int promocionId, double montoReserva) {
    final promocion = getPromocionById(promocionId);
    if (promocion == null || !promocion.isActiva) return false;
    
    // Aquí puedes agregar más validaciones específicas:
    // - Monto mínimo de reserva
    // - Fecha de validez
    // - Límite de usos por cliente
    // - etc.
    
    return true;
  }

  // Aplicar la mejor promoción automáticamente
  Promocion? aplicarMejorPromocion(double montoReserva) {
    if (_promocionesActivas.isEmpty) return null;
    
    // Filtrar promociones aplicables
    final promocionesAplicables = _promocionesActivas.where((promocion) {
      return puedeAplicarPromocion(promocion.id, montoReserva);
    }).toList();
    
    if (promocionesAplicables.isEmpty) return null;
    
    // Ordenar por descuento descendente
    promocionesAplicables.sort((a, b) => b.descuento.compareTo(a.descuento));
    
    return promocionesAplicables.first;
  }

  // Refrescar promociones
  Future<void> refresh() async {
    await loadPromociones();
  }

  // Métodos privados
  void _updatePromocionesActivas() {
    _promocionesActivas = _promociones.where((promocion) => promocion.isActiva).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Limpiar estado
  void clearState() {
    _promociones.clear();
    _promocionesActivas.clear();
    _status = PromocionesStatus.loading;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}