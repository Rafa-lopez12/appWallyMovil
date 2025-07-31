import 'package:flutter/material.dart';
import '../models/cliente.dart';
import '../services/api_service.dart';

enum ClientesStatus { loading, loaded, error, empty }

class ClientesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  ClientesStatus _status = ClientesStatus.loading;
  List<Cliente> _clientes = [];
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  ClientesStatus get status => _status;
  List<Cliente> get clientes => _clientes;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Cargar todos los clientes (solo para usuarios)
  Future<void> loadClientes() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getClientes();
      
      if (response is List) {
        _clientes = response.map((json) => Cliente.fromJson(json)).toList();
        
        // Ordenar alfabéticamente
        _clientes.sort((a, b) => a.nombre.compareTo(b.nombre));
        
        if (_clientes.isEmpty) {
          _status = ClientesStatus.empty;
        } else {
          _status = ClientesStatus.loaded;
        }
      } else {
        _setError('Formato de respuesta inválido');
        _status = ClientesStatus.error;
      }
    } catch (e) {
      _setError('Error al cargar clientes: ${e.toString()}');
      _status = ClientesStatus.error;
    }

    _setLoading(false);
  }

  // Buscar clientes
  List<Cliente> searchClientes(String query) {
    if (query.isEmpty) return _clientes;
    
    final queryLower = query.toLowerCase();
    return _clientes.where((cliente) {
      return cliente.nombre.toLowerCase().contains(queryLower) ||
             cliente.username.toLowerCase().contains(queryLower) ||
             cliente.telefono.contains(query);
    }).toList();
  }

  // Obtener cliente por ID
  Cliente? getClienteById(String id) {
    try {
      return _clientes.firstWhere((cliente) => cliente.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener cliente por username
  Cliente? getClienteByUsername(String username) {
    try {
      return _clientes.firstWhere(
        (cliente) => cliente.username.toLowerCase() == username.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Refrescar lista
  Future<void> refresh() async {
    await loadClientes();
  }

  // Métodos privados
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
    _clientes.clear();
    _status = ClientesStatus.loading;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}