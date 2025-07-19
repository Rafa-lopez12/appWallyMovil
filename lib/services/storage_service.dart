import 'dart:convert';
import 'package:appwally/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../models/cliente.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Instancias de almacenamiento
  SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Inicializar el servicio
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Verificar si está inicializado
  void _checkInitialization() {
    if (_prefs == null) {
      throw Exception('StorageService no está inicializado. Llama a initialize() primero.');
    }
  }

  // ============ ALMACENAMIENTO SEGURO (Tokens, datos sensibles) ============

  // Guardar token de autenticación
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: StorageKeys.authToken, value: token);
  }

  // Obtener token de autenticación
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: StorageKeys.authToken);
  }

  // Eliminar token de autenticación
  Future<void> removeAuthToken() async {
    await _secureStorage.delete(key: StorageKeys.authToken);
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ============ ALMACENAMIENTO REGULAR (Preferencias, datos no sensibles) ============

  // Guardar información del usuario
  Future<void> saveUserInfo(User user) async {
    _checkInitialization();
    final userJson = json.encode(user.toJson());
    await _prefs!.setString(StorageKeys.userInfo, userJson);
  }

  // Obtener información del usuario
  Future<User?> getUserInfo() async {
    _checkInitialization();
    final userJson = _prefs!.getString(StorageKeys.userInfo);
    if (userJson != null) {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    }
    return null;
  }

  // Eliminar información del usuario
  Future<void> removeUserInfo() async {
    _checkInitialization();
    await _prefs!.remove(StorageKeys.userInfo);
  }

  // Guardar información del cliente
  Future<void> saveClienteInfo(Cliente cliente) async {
    _checkInitialization();
    final clienteJson = json.encode(cliente.toJson());
    await _prefs!.setString('cliente_info', clienteJson);
  }

  // Obtener información del cliente
  Future<Cliente?> getClienteInfo() async {
    _checkInitialization();
    final clienteJson = _prefs!.getString('cliente_info');
    if (clienteJson != null) {
      final clienteMap = json.decode(clienteJson) as Map<String, dynamic>;
      return Cliente.fromJson(clienteMap);
    }
    return null;
  }

  // Eliminar información del cliente
  Future<void> removeClienteInfo() async {
    _checkInitialization();
    await _prefs!.remove('cliente_info');
  }

  // ============ CONFIGURACIONES DE LA APP ============

  // Primera vez usando la app
  Future<void> setFirstTime(bool isFirstTime) async {
    _checkInitialization();
    await _prefs!.setBool(StorageKeys.isFirstTime, isFirstTime);
  }

  Future<bool> isFirstTime() async {
    _checkInitialization();
    return _prefs!.getBool(StorageKeys.isFirstTime) ?? true;
  }

  // Idioma seleccionado
  Future<void> setSelectedLanguage(String languageCode) async {
    _checkInitialization();
    await _prefs!.setString(StorageKeys.selectedLanguage, languageCode);
  }

  Future<String?> getSelectedLanguage() async {
    _checkInitialization();
    return _prefs!.getString(StorageKeys.selectedLanguage);
  }

  // Modo de tema
  Future<void> setThemeMode(String themeMode) async {
    _checkInitialization();
    await _prefs!.setString(StorageKeys.themeMode, themeMode);
  }

  Future<String?> getThemeMode() async {
    _checkInitialization();
    return _prefs!.getString(StorageKeys.themeMode);
  }

  // ============ CACHE DE DATOS ============

  // Guardar últimas reservas (cache)
  Future<void> saveLastReservas(List<Map<String, dynamic>> reservas) async {
    _checkInitialization();
    final reservasJson = json.encode(reservas);
    await _prefs!.setString(StorageKeys.lastReservas, reservasJson);
    
    // Guardar timestamp del cache
    await _prefs!.setInt('${StorageKeys.lastReservas}_timestamp', 
                        DateTime.now().millisecondsSinceEpoch);
  }

  // Obtener últimas reservas del cache
  Future<List<Map<String, dynamic>>?> getLastReservas({int maxAgeMinutes = 30}) async {
    _checkInitialization();
    
    // Verificar si el cache no está expirado
    final timestamp = _prefs!.getInt('${StorageKeys.lastReservas}_timestamp');
    if (timestamp != null) {
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAgeMs = maxAgeMinutes * 60 * 1000;
      
      if (cacheAge > maxAgeMs) {
        // Cache expirado, eliminarlo
        await _prefs!.remove(StorageKeys.lastReservas);
        await _prefs!.remove('${StorageKeys.lastReservas}_timestamp');
        return null;
      }
    }

    final reservasJson = _prefs!.getString(StorageKeys.lastReservas);
    if (reservasJson != null) {
      final reservasList = json.decode(reservasJson) as List;
      return reservasList.cast<Map<String, dynamic>>();
    }
    return null;
  }

  // Limpiar cache de reservas
  Future<void> clearReservasCache() async {
    _checkInitialization();
    await _prefs!.remove(StorageKeys.lastReservas);
    await _prefs!.remove('${StorageKeys.lastReservas}_timestamp');
  }

  // ============ UTILIDADES ============

  // Limpiar todos los datos del usuario (logout completo)
  Future<void> clearUserData() async {
    _checkInitialization();
    
    // Eliminar datos seguros
    await removeAuthToken();
    
    // Eliminar datos regulares
    await removeUserInfo();
    await removeClienteInfo();
    await clearReservasCache();
    
    // Mantener configuraciones de la app (idioma, tema, etc.)
  }

  // Limpiar todos los datos de la app
  Future<void> clearAllData() async {
    _checkInitialization();
    
    // Limpiar almacenamiento seguro
    await _secureStorage.deleteAll();
    
    // Limpiar shared preferences
    await _prefs!.clear();
  }

  // Obtener tamaño del cache en bytes (aproximado)
  Future<int> getCacheSize() async {
    _checkInitialization();
    int size = 0;
    
    final keys = _prefs!.getKeys();
    for (String key in keys) {
      final value = _prefs!.get(key);
      if (value is String) {
        size += value.length * 2; // Aproximado para UTF-16
      }
    }
    
    return size;
  }

  // Verificar si una clave existe
  Future<bool> hasKey(String key) async {
    _checkInitialization();
    return _prefs!.containsKey(key);
  }

  // Métodos de conveniencia para tipos específicos
  Future<void> saveString(String key, String value) async {
    _checkInitialization();
    await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    _checkInitialization();
    return _prefs!.getString(key);
  }

  Future<void> saveInt(String key, int value) async {
    _checkInitialization();
    await _prefs!.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    _checkInitialization();
    return _prefs!.getInt(key);
  }

  Future<void> saveBool(String key, bool value) async {
    _checkInitialization();
    await _prefs!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    _checkInitialization();
    return _prefs!.getBool(key);
  }

  Future<void> saveDouble(String key, double value) async {
    _checkInitialization();
    await _prefs!.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    _checkInitialization();
    return _prefs!.getDouble(key);
  }

  Future<void> removeKey(String key) async {
    _checkInitialization();
    await _prefs!.remove(key);
  }
}