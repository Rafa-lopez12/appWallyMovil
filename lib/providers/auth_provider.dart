import 'package:flutter/material.dart';
import '../models/users.dart';
import '../models/cliente.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.unknown;
  User? _currentUser;
  Cliente? _currentCliente;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  Cliente? get currentCliente => _currentCliente;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _authService.isAdmin;
  bool get isEmpleado => _authService.isEmpleado;

  // Inicializar provider
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      await _authService.initialize();
      
      if (_authService.isAuthenticated) {
        _currentUser = _authService.currentUser;
        _currentCliente = _authService.currentCliente;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _setError('Error al inicializar autenticación');
    }
    
    _setLoading(false);
  }

  // Login de usuario
  Future<bool> loginUser(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.loginUser(username, password);
      
      if (result.success) {
        _currentUser = result.user;
        _currentCliente = result.cliente;
        _status = AuthStatus.authenticated;
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado durante el login');
      _setLoading(false);
      return false;
    }
  }

  // Registro de usuario
  Future<bool> registerUser({
    required String nombre,
    required String username,
    required String password,
    required String telefono,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.registerUser(
        nombre: nombre,
        username: username,
        password: password,
        telefono: telefono,
      );
      
      if (result.success) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado durante el registro');
      _setLoading(false);
      return false;
    }
  }

  // Registro de cliente
  Future<bool> registerCliente({
    required String nombre,
    required String username,
    required String password,
    required String telefono,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.registerCliente(
        nombre: nombre,
        username: username,
        password: password,
        telefono: telefono,
      );
      
      if (result.success) {
        _currentCliente = result.cliente;
        _status = AuthStatus.authenticated;
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado durante el registro de cliente');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _currentUser = null;
      _currentCliente = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      // Continuar con logout local aunque falle el remoto
      _currentUser = null;
      _currentCliente = null;
      _status = AuthStatus.unauthenticated;
    }
    
    _clearError();
    _setLoading(false);
  }

  // Actualizar información del usuario
  Future<bool> updateUserInfo(User updatedUser) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.updateUserInfo(updatedUser);
      
      if (result.success) {
        _currentUser = result.user;
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar información');
      _setLoading(false);
      return false;
    }
  }

  // Validar token
  Future<bool> validateToken() async {
    try {
      return await _authService.validateToken();
    } catch (e) {
      return false;
    }
  }

  // Refrescar token
  Future<void> refreshToken() async {
    try {
      final success = await _authService.refreshToken();
      if (success) {
        _currentUser = _authService.currentUser;
        _currentCliente = _authService.currentCliente;
        notifyListeners();
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
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
    _currentUser = null;
    _currentCliente = null;
    _status = AuthStatus.unknown;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}