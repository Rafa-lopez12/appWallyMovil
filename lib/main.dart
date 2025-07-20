import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
  await AppProviders.initializeServices();
  
  runApp(const WallyApp());
}

class WallyApp extends StatelessWidget {
  const WallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.getProviders(),
      child: Consumer(
        builder: (context, _, __) {
          return MaterialApp(
            title: 'Wally Reservas',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            onUnknownRoute: AppRoutes.onUnknownRoute,
            initialRoute: AppRoutes.welcome,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return _AppInitializer(child: child!);
            },
          );
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
      AppProviders.initializeProviders(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
