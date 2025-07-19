// API Configuration
class AppConstants {
  static const String baseUrl = 'http://localhost:4000'; // Tu backend NestJS
  static const String apiVersion = '/api/v1';
  static const Duration timeoutDuration = Duration(seconds: 30);
}

// API Endpoints
class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String checkStatus = '/auth/check-status';
  static const String logout = '/auth/logout';
  
  // Cliente endpoints
  static const String clientes = '/cliente';
  static const String clienteRegister = '/cliente/register';
  
  // Cancha endpoints
  static const String canchas = '/cancha';
  
  // Reserva endpoints
  static const String reservas = '/reserva';
  
  // Promocion endpoints
  static const String promociones = '/promocion';
  
  // Sugerencia endpoints
  static const String sugerencias = '/sugerencia';
  
  // Bitacora endpoints (para admins)
  static const String bitacora = '/bitacora';
}

// Storage Keys
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userInfo = 'user_info';
  static const String isFirstTime = 'is_first_time';
  static const String selectedLanguage = 'selected_language';
  static const String themeMode = 'theme_mode';
  static const String lastReservas = 'last_reservas';
}

// App Configuration
class AppConfig {
  static const String appName = 'Wally Reservas';
  static const String version = '1.0.0';
  static const int maxReservasPorDia = 3;
  static const int horasAnticipacionReserva = 2;
  static const int diasMaximosReserva = 30;
}

// Validation Constants
class Validation {
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minNombreLength = 2;
  static const int maxNombreLength = 50;
  static const int phoneLength = 8; // Ajusta según tu país
}

// Time Constants
class TimeConstants {
  static const int reservaMinutes = 60; // Duración mínima de reserva
  static const int maxReservaDuration = 180; // Duración máxima en minutos
  static const List<String> availableHours = [
    '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00', '21:00', '22:00'
  ];
}

// UI Constants
class UIConstants {
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 20.0;
  static const double cardElevation = 4.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 32.0;
}

// Estados de Cancha
class CanchaEstados {
  static const int disponible = 1;
  static const int ocupada = 0;
  static const int mantenimiento = 2;
}

// Estados de Promocion
class PromocionEstados {
  static const int activa = 1;
  static const int inactiva = 0;
  static const int expirada = 2;
}

// Roles de Usuario (basado en tu backend)
class UserRoles {
  static const String cliente = 'cliente';
  static const String administrador = 'administrador';
  static const String administradorGeneral = 'administrador_general';
  static const String empleado = 'empleado';
}

// Mensajes de Error Comunes
class ErrorMessages {
  static const String noInternet = 'No hay conexión a internet';
  static const String serverError = 'Error del servidor. Inténtalo más tarde';
  static const String timeoutError = 'Tiempo de espera agotado';
  static const String unknownError = 'Error desconocido';
  static const String invalidCredentials = 'Credenciales inválidas';
  static const String userNotFound = 'Usuario no encontrado';
  static const String reservaNotAvailable = 'Horario no disponible';
  static const String canchaNotAvailable = 'Cancha no disponible';
}

// Mensajes de Éxito
class SuccessMessages {
  static const String loginSuccess = 'Inicio de sesión exitoso';
  static const String registerSuccess = 'Registro exitoso';
  static const String reservaCreated = 'Reserva creada exitosamente';
  static const String reservaUpdated = 'Reserva actualizada exitosamente';
  static const String reservaCancelled = 'Reserva cancelada exitosamente';
  static const String sugerenciaCreated = 'Sugerencia enviada exitosamente';
}


// Formato de Fechas
class DateFormats {
  static const String displayDate = 'dd/MM/yyyy';
  static const String displayDateTime = 'dd/MM/yyyy HH:mm';
  static const String apiDate = 'yyyy-MM-dd';
  static const String apiDateTime = 'yyyy-MM-ddTHH:mm:ss';
  static const String timeOnly = 'HH:mm';
  static const String dayMonth = 'dd/MM';
}

// Configuración de Animaciones
class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(seconds: 2);
}