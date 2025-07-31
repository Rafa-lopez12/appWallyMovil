import 'package:flutter/material.dart';
import '../screen/auth/welcome_screen.dart';
import '../screen/auth/login_screen.dart';
import '../screen/auth/register_screen.dart';
import '../screen/main/home_screen.dart';
import '../screen/reservas/nueva_reserva_screen.dart';
import '../screen/reservas/reservas_screen.dart';

class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String canchas = '/canchas';
  static const String reservas = '/reservas';
  static const String nuevaReserva = '/nueva-reserva';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes {
    return {
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
      reservas: (context) => const ReservasScreen(),
      nuevaReserva: (context) => const NuevaReservaScreen(),
      // TODO: Agregar más rutas cuando implementes las pantallas
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Para rutas dinámicas o con parámetros
    switch (settings.name) {
      default:
        return null;
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const WelcomeScreen(),
    );
  }
}