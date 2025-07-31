import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
  try {
    await AppProviders.initializeServices();
  } catch (e) {
    debugPrint('Error inicializando servicios: $e');
  }
  
  runApp(const WallyApp());
}

class WallyApp extends StatelessWidget {
  const WallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.getProviders(),
      child: MaterialApp(
        title: 'Wally Reservas',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('es', ''), // Spanish
        ],
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: AppRoutes.onUnknownRoute,
        initialRoute: AppRoutes.welcome,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return _AppInitializer(child: child!);
        },
      ),
    );
  }
}

class _AppInitializer extends StatefulWidget {
  final Widget child;

  const _AppInitializer({required this.child});

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        AppProviders.initializeProviders(context);
      } catch (e) {
        debugPrint('Error inicializando providers: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}