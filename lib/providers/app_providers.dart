import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'auth_provider.dart';
import 'canchas_provider.dart';
import 'reservas_provider.dart';
import 'promociones_provider.dart';
import 'sugerencias_provider.dart';

class AppProviders {
  // Configurar todos los providers de la aplicación
  static List<ChangeNotifierProvider> getProviders() {
    return [
      // Provider de autenticación
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(),
      ),
      
      // Provider de canchas
      ChangeNotifierProvider<CanchasProvider>(
        create: (_) => CanchasProvider(),
      ),
      
      // Provider de reservas
      ChangeNotifierProvider<ReservasProvider>(
        create: (_) => ReservasProvider(),
      ),
      
      // Provider de promociones
      ChangeNotifierProvider<PromocionesProvider>(
        create: (_) => PromocionesProvider(),
      ),
      
      // Provider de sugerencias
      ChangeNotifierProvider<SugerenciasProvider>(
        create: (_) => SugerenciasProvider(),
      ),
    ];
  }

  // Configurar providers con dependencias ProxyProvider
  static List<ChangeNotifierProxyProvider> getProxyProviders() {
    return [
      // Ejemplo de ProxyProvider si necesitas pasar datos entre providers
      // ChangeNotifierProxyProvider<AuthProvider, ReservasProvider>(
      //   create: (context) => ReservasProvider(),
      //   update: (context, auth, reservas) {
      //     if (reservas != null && auth.currentCliente != null) {
      //       reservas.loadMisReservas(auth.currentCliente!.id);
      //     }
      //     return reservas!;
      //   },
      // ),
    ];
  }

  // Inicializar todos los servicios
  static Future<void> initializeServices() async {
    // Inicializar servicios de almacenamiento
    await StorageService().initialize();
    
    // Inicializar servicio de API
    ApiService().initialize();
    
    // Inicializar servicio de autenticación
    await AuthService().initialize();
  }

  // Método para inicializar providers después de que la app esté lista
  static Future<void> initializeProviders(BuildContext context) async {
    try {
      // Inicializar AuthProvider primero
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      // Si está autenticado, cargar datos iniciales
      if (authProvider.isAuthenticated) {
        await _loadInitialData(context);
      }
    } catch (e) {
      debugPrint('Error al inicializar providers: $e');
    }
  }

  // Cargar datos iniciales cuando el usuario está autenticado
  static Future<void> _loadInitialData(BuildContext context) async {
    try {
      // Cargar datos en paralelo para mejor rendimiento
      await Future.wait([
        // Cargar canchas
        Provider.of<CanchasProvider>(context, listen: false).loadCanchas(),
        
        // Cargar promociones
        Provider.of<PromocionesProvider>(context, listen: false).loadPromociones(),
        
        // Cargar reservas (solo si es admin o empleado)
        _loadReservasIfAuthorized(context),
        
        // Cargar sugerencias (solo si es admin)
        _loadSugerenciasIfAuthorized(context),
      ]);
    } catch (e) {
      debugPrint('Error al cargar datos iniciales: $e');
    }
  }

  // Cargar reservas solo si tiene permisos
  static Future<void> _loadReservasIfAuthorized(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reservasProvider = Provider.of<ReservasProvider>(context, listen: false);
    
    if (authProvider.isAdmin || authProvider.isEmpleado) {
      // Si es admin o empleado, cargar todas las reservas
      await reservasProvider.loadReservas();
    } else if (authProvider.currentCliente != null) {
      // Si es cliente, cargar solo sus reservas
      await reservasProvider.loadMisReservas(authProvider.currentCliente!.id);
    }
  }

  // Cargar sugerencias solo si es admin
  static Future<void> _loadSugerenciasIfAuthorized(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sugerenciasProvider = Provider.of<SugerenciasProvider>(context, listen: false);
    
    if (authProvider.isAdmin) {
      await sugerenciasProvider.loadSugerencias();
    }
  }

  // Limpiar todos los providers al hacer logout
  static void clearAllProviders(BuildContext context) {
    Provider.of<CanchasProvider>(context, listen: false).clearState();
    Provider.of<ReservasProvider>(context, listen: false).clearState();
    Provider.of<PromocionesProvider>(context, listen: false).clearState();
    Provider.of<SugerenciasProvider>(context, listen: false).clearState();
    // AuthProvider se limpia por sí solo en el logout
  }

  // Refrescar datos de todos los providers
  static Future<void> refreshAllData(BuildContext context) async {
    try {
      await Future.wait([
        Provider.of<CanchasProvider>(context, listen: false).refresh(),
        Provider.of<ReservasProvider>(context, listen: false).refresh(),
        Provider.of<PromocionesProvider>(context, listen: false).refresh(),
        Provider.of<SugerenciasProvider>(context, listen: false).refresh(),
      ]);
    } catch (e) {
      debugPrint('Error al refrescar datos: $e');
    }
  }

  // Obtener estado general de carga de la aplicación
  static bool isAppLoading(BuildContext context) {
    return Provider.of<AuthProvider>(context).isLoading ||
           Provider.of<CanchasProvider>(context).isLoading ||
           Provider.of<ReservasProvider>(context).isLoading ||
           Provider.of<PromocionesProvider>(context).isLoading ||
           Provider.of<SugerenciasProvider>(context).isLoading;
  }

  // Verificar si hay errores en algún provider
  static List<String> getProviderErrors(BuildContext context) {
    List<String> errors = [];
    
    final authError = Provider.of<AuthProvider>(context).errorMessage;
    if (authError != null) errors.add('Auth: $authError');
    
    final canchasError = Provider.of<CanchasProvider>(context).errorMessage;
    if (canchasError != null) errors.add('Canchas: $canchasError');
    
    final reservasError = Provider.of<ReservasProvider>(context).errorMessage;
    if (reservasError != null) errors.add('Reservas: $reservasError');
    
    final promocionesError = Provider.of<PromocionesProvider>(context).errorMessage;
    if (promocionesError != null) errors.add('Promociones: $promocionesError');
    
    final sugerenciasError = Provider.of<SugerenciasProvider>(context).errorMessage;
    if (sugerenciasError != null) errors.add('Sugerencias: $sugerenciasError');
    
    return errors;
  }
}