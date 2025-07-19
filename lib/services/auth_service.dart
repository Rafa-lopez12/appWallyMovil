import 'package:appwally/models/users.dart';

import '../models/cliente.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Estado actual del usuario
  User? _currentUser;
  Cliente? _currentCliente;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  Cliente? get currentCliente => _currentCliente;
  bool get isAuthenticated => _isAuthenticated;

  // Verificar si el usuario es admin
  bool get isAdmin {
    if (_currentUser?.rol?.rol == null) return false;
    return _currentUser!.rol!.rol == 'administrador' || 
           _currentUser!.rol!.rol == 'administrador_general';
  }

  // Verificar si el usuario es empleado
  bool get isEmpleado {
    if (_currentUser?.rol?.rol == null) return false;
    return _currentUser!.rol!.rol == 'empleado';
  }

  // Inicializar el servicio
  Future<void> initialize() async {
    await _checkStoredAuth();
  }

  // Verificar autenticación almacenada
  Future<void> _checkStoredAuth() async {
    try {
      final token = await _storageService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        // Verificar token con el servidor
        final response = await _apiService.checkAuthStatus();
        
        if (response != null) {
          _currentUser = User.fromJson(response);
          _isAuthenticated = true;
          
          // Intentar cargar info de cliente si existe
          _currentCliente = await _storageService.getClienteInfo();
        }
      }
    } catch (e) {
      // Token inválido o error de conexión
      await logout();
    }
  }

  // ============ AUTENTICACIÓN DE USUARIOS ============

  // Login de usuario
  Future<AuthResult> loginUser(String username, String password) async {
    try {
      final loginRequest = LoginRequest(
        username: username,
        password: password,
      );

      final response = await _apiService.login(loginRequest.toJson());
      final loginResponse = LoginResponse.fromJson(response);

      // Guardar token
      await _storageService.saveAuthToken(loginResponse.token);

      // Crear usuario desde la respuesta
      _currentUser = User(
        id: loginResponse.id,
        nombre: loginResponse.nombre,
        username: loginResponse.username,
        telefono: '', // No viene en la respuesta de login
      );

      // Guardar información del usuario
      await _storageService.saveUserInfo(_currentUser!);

      _isAuthenticated = true;

      return AuthResult.success(
        user: _currentUser,
        message: 'Inicio de sesión exitoso',
      );

    } on ApiException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('Error inesperado durante el login');
    }
  }

  // Registro de usuario
  Future<AuthResult> registerUser({
    required String nombre,
    required String username,
    required String password,
    required String telefono,
  }) async {
    try {
      final registerRequest = RegisterRequest(
        nombre: nombre,
        username: username,
        password: password,
        telefono: telefono,
      );

      final response = await _apiService.register(registerRequest.toJson());
      final loginResponse = LoginResponse.fromJson(response);

      // Guardar token
      await _storageService.saveAuthToken(loginResponse.token);

      // Crear usuario desde la respuesta
      _currentUser = User(
        id: loginResponse.id,
        nombre: loginResponse.nombre,
        username: loginResponse.username,
        telefono: telefono,
      );

      // Guardar información del usuario
      await _storageService.saveUserInfo(_currentUser!);

      _isAuthenticated = true;

      return AuthResult.success(
        user: _currentUser,
        message: 'Registro exitoso',
      );

    } on ApiException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('Error inesperado durante el registro');
    }
  }

  // ============ AUTENTICACIÓN DE CLIENTES ============

  // Login de cliente (si tienes endpoint separado)
  Future<AuthResult> loginCliente(String username, String password) async {
    try {
      // Por ahora usa el mismo endpoint, pero puedes separarlo si es necesario
      final result = await loginUser(username, password);
      
      if (result.success && result.user != null) {
        // Crear objeto cliente desde el usuario
        _currentCliente = Cliente(
          id: result.user!.id,
          nombre: result.user!.nombre,
          username: result.user!.username,
          telefono: result.user!.telefono,
        );
        
        await _storageService.saveClienteInfo(_currentCliente!);
      }
      
      return result;

    } catch (e) {
      return AuthResult.error('Error inesperado durante el login de cliente');
    }
  }

  // Registro de cliente
  Future<AuthResult> registerCliente({
    required String nombre,
    required String username,
    required String password,
    required String telefono,
  }) async {
    try {
      final createClienteRequest = CreateClienteRequest(
        nombre: nombre,
        username: username,
        password: password,
        telefono: telefono,
      );

      final response = await _apiService.registerCliente(createClienteRequest.toJson());
      
      // El endpoint /cliente/register debería devolver un cliente con token
      // Si no, ajusta según tu backend
      final cliente = Cliente.fromJson(response);

      _currentCliente = cliente;
      await _storageService.saveClienteInfo(cliente);

      _isAuthenticated = true;

      return AuthResult.success(
        cliente: cliente,
        message: 'Registro de cliente exitoso',
      );

    } on ApiException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('Error inesperado durante el registro de cliente');
    }
  }

  // ============ GESTIÓN DE SESIÓN ============

  // Logout
  Future<void> logout() async {
    try {
      // Limpiar datos locales
      await _storageService.clearUserData();
      
      _currentUser = null;
      _currentCliente = null;
      _isAuthenticated = false;

    } catch (e) {
      // Error al limpiar, pero continuar con logout local
      _currentUser = null;
      _currentCliente = null;
      _isAuthenticated = false;
    }
  }

  // Actualizar información del usuario
  Future<AuthResult> updateUserInfo(User updatedUser) async {
    try {
      _currentUser = updatedUser;
      await _storageService.saveUserInfo(updatedUser);
      
      return AuthResult.success(
        user: updatedUser,
        message: 'Información actualizada correctamente',
      );
    } catch (e) {
      return AuthResult.error('Error al actualizar información del usuario');
    }
  }

  // Actualizar información del cliente
  Future<AuthResult> updateClienteInfo(Cliente updatedCliente) async {
    try {
      _currentCliente = updatedCliente;
      await _storageService.saveClienteInfo(updatedCliente);
      
      return AuthResult.success(
        cliente: updatedCliente,
        message: 'Información actualizada correctamente',
      );
    } catch (e) {
      return AuthResult.error('Error al actualizar información del cliente');
    }
  }

  // Refrescar token (si implementas refresh tokens)
  Future<bool> refreshToken() async {
    try {
      final response = await _apiService.checkAuthStatus();
      if (response != null) {
        _currentUser = User.fromJson(response);
        await _storageService.saveUserInfo(_currentUser!);
        return true;
      }
      return false;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Verificar si el token sigue siendo válido
  Future<bool> validateToken() async {
    try {
      await _apiService.checkAuthStatus();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Clase para resultados de autenticación
class AuthResult {
  final bool success;
  final String message;
  final User? user;
  final Cliente? cliente;

  AuthResult.success({
    this.user,
    this.cliente,
    required this.message,
  }) : success = true;

  AuthResult.error(this.message)
      : success = false,
        user = null,
        cliente = null;
}

// Estados de autenticación
enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
}