import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/users.dart';
import '../models/cliente.dart';

class AuthHelpers {
  // Verificar si el usuario actual puede hacer reservas por otros
  static bool canReserveForOthers(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdmin || authProvider.isEmpleado;
  }

  // Obtener el nombre del usuario/cliente actual
  static String? getCurrentUserName(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      return authProvider.currentUser!.nombre;
    } else if (authProvider.currentCliente != null) {
      return authProvider.currentCliente!.nombre;
    }
    
    return null;
  }

  // Obtener el ID del usuario/cliente actual
  static String? getCurrentUserId(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      return authProvider.currentUser!.id;
    } else if (authProvider.currentCliente != null) {
      return authProvider.currentCliente!.id;
    }
    
    return null;
  }

  // Obtener datos para crear reserva según el tipo de usuario
  static ReservaCreationData getReservaCreationData(
    BuildContext context, {
    String? selectedClienteName, // Para cuando un usuario selecciona un cliente
  }) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAdmin || authProvider.isEmpleado) {
      // Es un usuario (empleado/admin)
      return ReservaCreationData(
        usuarioNombre: authProvider.currentUser?.nombre,
        clienteNombre: selectedClienteName ?? authProvider.currentUser?.nombre ?? '',
        isReservingForOther: selectedClienteName != null,
      );
    } else {
      // Es un cliente
      return ReservaCreationData(
        usuarioNombre: null,
        clienteNombre: authProvider.currentCliente?.nombre ?? '',
        isReservingForOther: false,
      );
    }
  }

  // Verificar si el usuario actual es admin
  static bool isAdmin(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdmin;
  }

  // Verificar si el usuario actual es empleado
  static bool isEmpleado(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isEmpleado;
  }

  // Verificar si el usuario actual es cliente
  static bool isCliente(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentCliente != null && !authProvider.isAdmin && !authProvider.isEmpleado;
  }

  // Obtener el rol actual como string
  static String getCurrentRole(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAdmin) {
      return 'Administrador';
    } else if (authProvider.isEmpleado) {
      return 'Empleado';
    } else if (authProvider.currentCliente != null) {
      return 'Cliente';
    } else {
      return 'Desconocido';
    }
  }

  // Verificar si puede ver todas las reservas
  static bool canViewAllReservas(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdmin || authProvider.isEmpleado;
  }

  // Verificar si puede gestionar promociones
  static bool canManagePromociones(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdmin;
  }

  // Verificar si puede ver sugerencias
  static bool canViewSugerencias(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdmin;
  }

  // Verificar si puede gestionar usuarios/clientes
  static bool canManageUsers(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdmin;
  }
}

// Clase para datos de creación de reserva
class ReservaCreationData {
  final String? usuarioNombre;
  final String clienteNombre;
  final bool isReservingForOther;

  ReservaCreationData({
    this.usuarioNombre,
    required this.clienteNombre,
    required this.isReservingForOther,
  });
}