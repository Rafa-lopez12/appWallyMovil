import 'package:flutter/material.dart';
import '../models/sugerencia.dart';
import '../services/api_service.dart';

enum SugerenciasStatus { loading, loaded, error, empty }

class SugerenciasProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  SugerenciasStatus _status = SugerenciasStatus.loading;
  List<Sugerencia> _sugerencias = [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _isCreating = false;

  // Getters
  SugerenciasStatus get status => _status;
  List<Sugerencia> get sugerencias => _sugerencias;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;

  // Cargar todas las sugerencias (solo para admins)
  Future<void> loadSugerencias() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getSugerencias();
      
      if (response is List) {
        _sugerencias = response.map((json) => Sugerencia.fromJson(json)).toList();
        
        // Ordenar por ID descendente (más recientes primero)
        _sugerencias.sort((a, b) => b.id.compareTo(a.id));
        
        if (_sugerencias.isEmpty) {
          _status = SugerenciasStatus.empty;
        } else {
          _status = SugerenciasStatus.loaded;
        }
      } else {
        _setError('Formato de respuesta inválido');
        _status = SugerenciasStatus.error;
      }
    } catch (e) {
      _setError('Error al cargar sugerencias: ${e.toString()}');
      _status = SugerenciasStatus.error;
    }

    _setLoading(false);
  }

  // Crear nueva sugerencia
  Future<bool> createSugerencia(String descripcion) async {
    _setCreating(true);
    _clearError();

    try {
      final createRequest = CreateSugerenciaRequest(descripcion: descripcion);
      final response = await _apiService.createSugerencia(createRequest.toJson());
      
      if (response != null) {
        final nuevaSugerencia = Sugerencia.fromJson(response);
        _sugerencias.insert(0, nuevaSugerencia);
        
        if (_status == SugerenciasStatus.empty) {
          _status = SugerenciasStatus.loaded;
        }
        
        _setCreating(false);
        notifyListeners();
        return true;
      } else {
        _setError('Error al enviar la sugerencia');
        _setCreating(false);
        return false;
      }
    } catch (e) {
      _setError('Error al crear sugerencia: ${e.toString()}');
      _setCreating(false);
      return false;
    }
  }

  // Actualizar sugerencia (solo admins)
  Future<bool> updateSugerencia(int sugerenciaId, String nuevaDescripcion) async {
    _setLoading(true);
    _clearError();

    try {
      final updateRequest = UpdateSugerenciaRequest(descripcion: nuevaDescripcion);
      final response = await _apiService.updateSugerencia(sugerenciaId, updateRequest.toJson());
      
      if (response != null) {
        final sugerenciaActualizada = Sugerencia.fromJson(response);
        
        final index = _sugerencias.indexWhere((s) => s.id == sugerenciaId);
        if (index != -1) {
          _sugerencias[index] = sugerenciaActualizada;
        }
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Error al actualizar la sugerencia');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar sugerencia: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Eliminar sugerencia (solo admins)
  Future<bool> deleteSugerencia(int sugerenciaId) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.deleteSugerencia(sugerenciaId);
      
      _sugerencias.removeWhere((s) => s.id == sugerenciaId);
      
      if (_sugerencias.isEmpty) {
        _status = SugerenciasStatus.empty;
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar sugerencia: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Obtener sugerencia por ID
  Sugerencia? getSugerenciaById(int id) {
    try {
      return _sugerencias.firstWhere((sugerencia) => sugerencia.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener sugerencias por cliente
  List<Sugerencia> getSugerenciasByCliente(String clienteId) {
    return _sugerencias.where((sugerencia) => 
      sugerencia.cliente.id == clienteId
    ).toList();
  }

  // Buscar sugerencias
  List<Sugerencia> searchSugerencias(String query) {
    if (query.isEmpty) return _sugerencias;
    
    final queryLower = query.toLowerCase();
    return _sugerencias.where((sugerencia) {
      return sugerencia.descripcion.toLowerCase().contains(queryLower) ||
             sugerencia.cliente.nombre.toLowerCase().contains(queryLower);
    }).toList();
  }

  // Filtrar sugerencias por cliente
  List<Sugerencia> filterByCliente(String clienteNombre) {
    if (clienteNombre.isEmpty) return _sugerencias;
    
    return _sugerencias.where((sugerencia) {
      return sugerencia.cliente.nombre.toLowerCase()
          .contains(clienteNombre.toLowerCase());
    }).toList();
  }

  // Obtener estadísticas de sugerencias
  Map<String, dynamic> getEstadisticas() {
    final total = _sugerencias.length;
    
    // Contar sugerencias por cliente (top clientes que más sugieren)
    final Map<String, int> sugerenciasPorCliente = {};
    for (var sugerencia in _sugerencias) {
      final clienteNombre = sugerencia.cliente.nombre;
      sugerenciasPorCliente[clienteNombre] = 
          (sugerenciasPorCliente[clienteNombre] ?? 0) + 1;
    }
    
    // Ordenar clientes por cantidad de sugerencias
    final topClientes = sugerenciasPorCliente.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Calcular promedio de caracteres por sugerencia
    final promedioCaracteres = _sugerencias.isNotEmpty 
        ? _sugerencias.map((s) => s.descripcion.length).reduce((a, b) => a + b) / _sugerencias.length
        : 0.0;
    
    // Contar sugerencias largas (más de 100 caracteres)
    final sugerenciasLargas = _sugerencias.where((s) => s.isDescripcionLarga).length;

    return {
      'total': total,
      'topClientes': topClientes.take(5).toList(),
      'promedioCaracteres': promedioCaracteres.round(),
      'sugerenciasLargas': sugerenciasLargas,
      'clientesUnicos': sugerenciasPorCliente.keys.length,
    };
  }

  // Obtener sugerencias recientes (últimas 5)
  List<Sugerencia> getSugerenciasRecientes({int limit = 5}) {
    return _sugerencias.take(limit).toList();
  }

  // Validar sugerencia antes de enviar
  String? validateSugerencia(String descripcion) {
    if (descripcion.trim().isEmpty) {
      return 'La descripción no puede estar vacía';
    }
    
    if (descripcion.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    
    if (descripcion.length > 500) {
      return 'La descripción no puede exceder 500 caracteres';
    }
    
    // Verificar palabras inapropiadas básicas
    final palabrasInapropiadas = ['spam', 'test', 'prueba'];
    final descripcionLower = descripcion.toLowerCase();
    
    for (String palabra in palabrasInapropiadas) {
      if (descripcionLower.contains(palabra)) {
        return 'La descripción contiene contenido no permitido';
      }
    }
    
    return null; // Válida
  }

  // Enviar sugerencia con validación
  Future<bool> enviarSugerencia(String descripcion) async {
    // Validar antes de enviar
    final validationError = validateSugerencia(descripcion);
    if (validationError != null) {
      _setError(validationError);
      return false;
    }
    
    return await createSugerencia(descripcion.trim());
  }

  // Marcar sugerencia como leída (funcionalidad futura)
  void marcarComoLeida(int sugerenciaId) {
    // Esta funcionalidad se puede implementar más adelante
    // agregando un campo 'leida' al modelo de sugerencia
    notifyListeners();
  }

  // Refrescar sugerencias
  Future<void> refresh() async {
    await loadSugerencias();
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
    _sugerencias.clear();
    _status = SugerenciasStatus.loading;
    _errorMessage = null;
    _isLoading = false;
    _isCreating = false;
    notifyListeners();
  }
}