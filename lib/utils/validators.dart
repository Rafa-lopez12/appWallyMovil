import 'constants.dart';

class Validators {
  // Validar email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    
    return null;
  }

  // Validar nombre de usuario
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'El usuario es requerido';
    }
    
    if (value.length < Validation.minUsernameLength) {
      return 'Mínimo ${Validation.minUsernameLength} caracteres';
    }
    
    if (value.length > Validation.maxUsernameLength) {
      return 'Máximo ${Validation.maxUsernameLength} caracteres';
    }
    
    
    return null;
  }

  // Validar contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < Validation.minPasswordLength) {
      return 'Mínimo ${Validation.minPasswordLength} caracteres';
    }
    
    if (value.length > Validation.maxPasswordLength) {
      return 'Máximo ${Validation.maxPasswordLength} caracteres';
    }
    
    return null;
  }

  // Validar confirmación de contraseña
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  // Validar nombre
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.length < Validation.minNombreLength) {
      return 'Mínimo ${Validation.minNombreLength} caracteres';
    }
    
    if (value.length > Validation.maxNombreLength) {
      return 'Máximo ${Validation.maxNombreLength} caracteres';
    }
    
    
    return null;
  }

  // Validar teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    

    
    return null;
  }

  // Validar campo requerido genérico
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  // Validar longitud mínima
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    return null;
  }

  // Validar longitud máxima
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName no puede exceder $maxLength caracteres';
    }
    return null;
  }

  // Validar rango de longitud
  static String? validateLengthRange(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    
    if (value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    
    if (value.length > maxLength) {
      return '$fieldName no puede exceder $maxLength caracteres';
    }
    
    return null;
  }

  // Validar número positivo
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName debe ser un número válido';
    }
    
    if (number <= 0) {
      return '$fieldName debe ser mayor a cero';
    }
    
    return null;
  }

  // Validar fecha futura
  static String? validateFutureDate(DateTime? date, String fieldName) {
    if (date == null) {
      return '$fieldName es requerido';
    }
    
    if (date.isBefore(DateTime.now())) {
      return '$fieldName debe ser una fecha futura';
    }
    
    return null;
  }

  // Validar rango de fechas
  static String? validateDateRange(
    DateTime? startDate,
    DateTime? endDate,
    String startFieldName,
    String endFieldName,
  ) {
    if (startDate == null) {
      return '$startFieldName es requerido';
    }
    
    if (endDate == null) {
      return '$endFieldName es requerido';
    }
    
    if (endDate.isBefore(startDate)) {
      return '$endFieldName debe ser posterior a $startFieldName';
    }
    
    return null;
  }

  // Validar hora de reserva
  static String? validateReservaTime(DateTime? fechaHora) {
    if (fechaHora == null) {
      return 'La fecha y hora son requeridas';
    }
    
    final now = DateTime.now();
    final anticipacion = fechaHora.difference(now).inHours;
    
    if (anticipacion < AppConfig.horasAnticipacionReserva) {
      return 'Debe reservar con al menos ${AppConfig.horasAnticipacionReserva} horas de anticipación';
    }
    
    final diasAnticipacion = fechaHora.difference(now).inDays;
    if (diasAnticipacion > AppConfig.diasMaximosReserva) {
      return 'No puede reservar con más de ${AppConfig.diasMaximosReserva} días de anticipación';
    }
    
    return null;
  }

  // Validar duración de reserva
  static String? validateReservaDuration(DateTime? inicio, DateTime? fin) {
    if (inicio == null || fin == null) {
      return 'Las fechas de inicio y fin son requeridas';
    }
    
    final duracion = fin.difference(inicio).inMinutes;
    
    if (duracion < TimeConstants.reservaMinutes) {
      return 'La duración mínima es ${TimeConstants.reservaMinutes} minutos';
    }
    
    if (duracion > TimeConstants.maxReservaDuration) {
      return 'La duración máxima es ${TimeConstants.maxReservaDuration} minutos';
    }
    
    return null;
  }

  // Validar descripción de sugerencia
  static String? validateSugerencia(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La descripción no puede estar vacía';
    }
    
    if (value.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    
    if (value.length > 500) {
      return 'La descripción no puede exceder 500 caracteres';
    }
    
    return null;
  }

  // Combinar múltiples validadores
  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) return result;
    }
    return null;
  }
}