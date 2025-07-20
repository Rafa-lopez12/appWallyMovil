import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();
  late http.Client _client;

  // Inicializar el servicio
  void initialize() {
    _client = http.Client();
  }

  // Obtener headers base
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _storage.getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Construir URL completa
  String _buildUrl(String endpoint) {
    return '${AppConstants.baseUrl}$endpoint';
  }

  // Manejar respuestas HTTP
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      case 400:
        throw ApiException('Solicitud inválida: ${response.body}');
      case 401:
        throw ApiException('No autorizado. Inicia sesión nuevamente.');
      case 403:
        throw ApiException('Acceso denegado');
      case 404:
        throw ApiException('Recurso no encontrado');
      case 500:
        throw ApiException('Error interno del servidor');
      default:
        throw ApiException('Error desconocido: ${response.statusCode}');
    }
  }

  // Manejar errores de conexión
  Future<T> _handleRequest<T>(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(AppConstants.timeoutDuration);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(ErrorMessages.noInternet);
    } on HttpException {
      throw ApiException(ErrorMessages.serverError);
    } on FormatException {
      throw ApiException('Error en el formato de datos');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(ErrorMessages.unknownError);
    }
  }

  // ============ MÉTODOS HTTP GENÉRICOS ============

  // GET request
  Future<dynamic> get(String endpoint, {bool includeAuth = true}) async {
    return _handleRequest(() async {
      final headers = await _getHeaders(includeAuth: includeAuth);
      return _client.get(
        Uri.parse(_buildUrl(endpoint)),
        headers: headers,
      );
    });
  }

  // POST request
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    return _handleRequest(() async {
      final headers = await _getHeaders(includeAuth: includeAuth);
      return _client.post(
        Uri.parse(_buildUrl(endpoint)),
        headers: headers,
        body: json.encode(data),
      );
    });
  }

  // PUT request
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    return _handleRequest(() async {
      final headers = await _getHeaders(includeAuth: includeAuth);
      return _client.put(
        Uri.parse(_buildUrl(endpoint)),
        headers: headers,
        body: json.encode(data),
      );
    });
  }

  // PATCH request
  Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    return _handleRequest(() async {
      final headers = await _getHeaders(includeAuth: includeAuth);
      return _client.patch(
        Uri.parse(_buildUrl(endpoint)),
        headers: headers,
        body: json.encode(data),
      );
    });
  }

  // DELETE request
  Future<dynamic> delete(String endpoint, {bool includeAuth = true}) async {
    return _handleRequest(() async {
      final headers = await _getHeaders(includeAuth: includeAuth);
      return _client.delete(
        Uri.parse(_buildUrl(endpoint)),
        headers: headers,
      );
    });
  }

  // ============ MÉTODOS ESPECÍFICOS PARA WALLY ============

  // Auth endpoints
  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    return await post(ApiEndpoints.login, credentials, includeAuth: false);
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await post(ApiEndpoints.register, userData, includeAuth: false);
  }

  Future<Map<String, dynamic>> checkAuthStatus() async {
    return await get(ApiEndpoints.checkStatus);
  }

  // Cliente endpoints
  Future<Map<String, dynamic>> registerCliente(Map<String, dynamic> clienteData) async {
    return await post(ApiEndpoints.clienteRegister, clienteData, includeAuth: false);
  }

  Future<List<dynamic>> getClientes() async {
    return await get(ApiEndpoints.clientes);
  }

  Future<Map<String, dynamic>> getCliente(String id) async {
    return await get('${ApiEndpoints.clientes}/$id');
  }

  Future<Map<String, dynamic>> updateCliente(String id, Map<String, dynamic> data) async {
    return await patch('${ApiEndpoints.clientes}/$id', data);
  }

  Future<void> deleteCliente(String id) async {
    await delete('${ApiEndpoints.clientes}/$id');
  }

  // Cancha endpoints
  Future<List<dynamic>> getCanchas() async {
    return await get(ApiEndpoints.canchas);
  }

  // Reserva endpoints
  Future<List<dynamic>> getReservas() async {
    return await get(ApiEndpoints.reservas);
  }

  Future<Map<String, dynamic>> getReserva(int id) async {
    return await get('${ApiEndpoints.reservas}/$id');
  }

  Future<Map<String, dynamic>> createReserva(Map<String, dynamic> reservaData) async {
    return await post(ApiEndpoints.reservas, reservaData);
  }

  Future<Map<String, dynamic>> updateReserva(int id, Map<String, dynamic> data) async {
    return await patch('${ApiEndpoints.reservas}/$id', data);
  }

  Future<void> deleteReserva(int id) async {
    await delete('${ApiEndpoints.reservas}/$id');
  }

  // Promocion endpoints
  Future<List<dynamic>> getPromociones() async {
    return await get(ApiEndpoints.promociones);
  }

  Future<Map<String, dynamic>> createPromocion(Map<String, dynamic> promocionData) async {
    return await post(ApiEndpoints.promociones, promocionData);
  }

  Future<Map<String, dynamic>> updatePromocion(int id, Map<String, dynamic> data) async {
    return await patch('${ApiEndpoints.promociones}/$id', data);
  }

  // Sugerencia endpoints
  Future<List<dynamic>> getSugerencias() async {
    return await get(ApiEndpoints.sugerencias);
  }

  Future<Map<String, dynamic>> createSugerencia(Map<String, dynamic> sugerenciaData) async {
    return await post(ApiEndpoints.sugerencias, sugerenciaData);
  }

  Future<Map<String, dynamic>> updateSugerencia(int id, Map<String, dynamic> data) async {
    return await patch('${ApiEndpoints.sugerencias}/$id', data);
  }

  Future<void> deleteSugerencia(int id) async {
    await delete('${ApiEndpoints.sugerencias}/$id');
  }

  // Bitacora endpoints (solo para admins)
  Future<List<dynamic>> getBitacora() async {
    return await get(ApiEndpoints.bitacora);
  }


  Future<Map<String, dynamic>> getDailyStats(String date) async {
  return await get('/reserva/stats/daily/$date');
}

// Estadísticas mensuales (solo usuarios)
Future<Map<String, dynamic>> getMonthlyStats(int year, int month) async {
  return await get('/reserva/stats/monthly/$year/$month');
}

// Estadísticas de cliente específico
Future<Map<String, dynamic>> getClientStats(String clienteId) async {
  return await get('/reserva/stats/client/$clienteId');
}

// Reservas de cliente específico
Future<List<dynamic>> getClientReservas(String clienteId) async {
  return await get('/reserva/client/$clienteId/reservas');
}

// Mis estadísticas (para clientes)
Future<Map<String, dynamic>> getMyStats() async {
  return await get('/reserva/my-stats');
}

// Mis reservas (para clientes)
Future<List<dynamic>> getMyReservas() async {
  return await get('/reserva/my-reservas');
}

// ============ MÉTODOS PARA FIDELIZACIÓN ============

// Verificar descuento de fidelización
Future<Map<String, dynamic>> checkLoyaltyDiscount(String clienteId) async {
  return await get('/reserva/loyalty/check/$clienteId');
}

// ============ MÉTODOS PARA CAMBIO DE CONTRASEÑA ============

// Cambiar contraseña de cliente específico (para usuarios)
Future<Map<String, dynamic>> changeClientPassword(
  String clienteId, 
  String currentPassword, 
  String newPassword
) async {
  return await patch('/cliente/$clienteId/change-password', {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  });
}

// Cambiar mi contraseña (para clientes)
Future<Map<String, dynamic>> changeMyPassword(
  String currentPassword, 
  String newPassword
) async {
  return await patch('/cliente/change-my-password', {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  });
}

  // Limpiar recursos
  void dispose() {
    _client.close();
  }
}

// Excepción personalizada para errores de API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    return 'ApiException: $message';
  }
}

// Resultado de respuesta HTTP
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResponse.success(this.data)
      : error = null,
        success = true;

  ApiResponse.error(this.error)
      : data = null,
        success = false;
}