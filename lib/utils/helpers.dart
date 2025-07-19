import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class Helpers {
  // ============ FORMATEO DE FECHAS ============

  // Formatear fecha para mostrar (dd/MM/yyyy)
  static String formatDate(DateTime date) {
    return DateFormat(DateFormats.displayDate).format(date);
  }

  // Formatear fecha y hora para mostrar (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(DateFormats.displayDateTime).format(dateTime);
  }

  // Formatear solo hora (HH:mm)
  static String formatTime(DateTime dateTime) {
    return DateFormat(DateFormats.timeOnly).format(dateTime);
  }

  // Formatear fecha para API (yyyy-MM-dd)
  static String formatDateForApi(DateTime date) {
    return DateFormat(DateFormats.apiDate).format(date);
  }

  // Formatear fecha y hora para API (yyyy-MM-ddTHH:mm:ss)
  static String formatDateTimeForApi(DateTime dateTime) {
    return DateFormat(DateFormats.apiDateTime).format(dateTime);
  }

  // Obtener fecha relativa (hoy, ayer, mañana, etc.)
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hoy';
    } else if (targetDate == yesterday) {
      return 'Ayer';
    } else if (targetDate == tomorrow) {
      return 'Mañana';
    } else {
      return formatDate(date);
    }
  }

  // ============ FORMATEO DE NÚMEROS ============

  // Formatear precio/dinero
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: 'Bs. ',
      decimalDigits: 2,
    ).format(amount);
  }

  // Formatear porcentaje
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  // Formatear número con separadores de miles
  static String formatNumber(int number) {
    return NumberFormat.decimalPattern().format(number);
  }

  // ============ VALIDACIONES DE TIEMPO ============

  // Verificar si una fecha es hoy
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  // Verificar si una fecha es mañana
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }

  // Verificar si una hora está en horario laboral
  static bool isBusinessHour(DateTime dateTime) {
    final hour = dateTime.hour;
    return hour >= 8 && hour <= 22; // 8 AM a 10 PM
  }

  // Obtener diferencia de tiempo legible
  static String getTimeDifference(DateTime from, DateTime to) {
    final difference = to.difference(from);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'Menos de un minuto';
    }
  }

  // ============ UTILIDADES DE COLOR ============

  // Obtener color según estado de cancha
  static Color getCanchaColor(int estado) {
    switch (estado) {
      case CanchaEstados.disponible:
        return Colors.green;
      case CanchaEstados.ocupada:
        return Colors.red;
      case CanchaEstados.mantenimiento:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Obtener color según estado de promoción
  static Color getPromocionColor(int estado) {
    switch (estado) {
      case PromocionEstados.activa:
        return Colors.green;
      case PromocionEstados.inactiva:
        return Colors.grey;
      case PromocionEstados.expirada:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ============ UTILIDADES DE TEXTO ============

  // Capitalizar primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Truncar texto con puntos suspensivos
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Obtener iniciales de un nombre
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    } else {
      return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
    }
  }

  // ============ UTILIDADES DE UI ============

  // Mostrar SnackBar de éxito
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Mostrar SnackBar de error
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Mostrar SnackBar de información
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Mostrar dialog de confirmación
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  // ============ UTILIDADES DE DATOS ============

  // Generar ID único simple
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Calcular porcentaje
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  // Redondear a 2 decimales
  static double roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  // ============ UTILIDADES DE VALIDACIÓN ============

  // Verificar si es un horario válido para reservas
  static bool isValidReservaTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    
    // Solo permitir horas en punto o medias horas
    if (minute != 0 && minute != 30) return false;
    
    // Verificar horario de atención (8 AM a 10 PM)
    return hour >= 8 && hour <= 22;
  }

  // Verificar si una reserva se puede cancelar
  static bool canCancelReserva(DateTime fechaInicio) {
    final now = DateTime.now();
    final horasHastaReserva = fechaInicio.difference(now).inHours;
    
    // Se puede cancelar si faltan más de 2 horas
    return horasHastaReserva >= 2;
  }

  // ============ UTILIDADES DE NAVEGACIÓN ============

  // Navegar con animación personalizada
  static void navigateWithSlideTransition(
    BuildContext context,
    Widget destination,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  // ============ UTILIDADES DE DEBUGGING ============

  // Log personalizado para debugging
  static void debugLog(String message, [String? tag]) {
    debugPrint('[${tag ?? 'APP'}] $message');
  }

  // Imprimir información de un objeto de manera legible
  static void debugPrintObject(String name, Map<String, dynamic> object) {
    debugPrint('=== $name ===');
    object.forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('=============');
  }
}