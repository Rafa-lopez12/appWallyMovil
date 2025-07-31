import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_buttom.dart';
import '../../utils/helpers.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: AnimationDurations.slow,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AnimationDurations.normal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.defaultPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: UIConstants.largePadding),
                  _buildContent(),
                  const SizedBox(height: UIConstants.largePadding),
                  _buildActions(),
                  const SizedBox(height: UIConstants.defaultPadding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo animado
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: AnimationDurations.slow,
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(UIConstants.largePadding * 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textOnPrimary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    size: 80,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: UIConstants.largePadding),
          
          // Título principal
          Text(
            AppConfig.appName,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: AppColors.primaryDark.withOpacity(0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Reserva tu cancha favorita!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            Text(
              'Encuentra y reserva canchas de fútbol de manera fácil y rápida. '
              '¡Tu próximo partido está a solo un clic!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textOnPrimary.withOpacity(0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.largePadding),
            
            // Características destacadas
            _buildFeatures(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'icon': Icons.access_time,
        'title': 'Reserva 24/7',
        'description': 'Disponible siempre',
      },

    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: features.map((feature) {
        return Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(UIConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: AppColors.textOnPrimary,
                  size: UIConstants.largeIconSize,
                ),
              ),
              const SizedBox(height: UIConstants.smallPadding),
              Text(
                feature['title'] as String,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                feature['description'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textOnPrimary.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Botón principal - Iniciar Sesión
            Container(
              width: double.infinity,
              height: UIConstants.buttonHeight + 8,
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary,
                borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
                boxShadow: AppColors.buttonShadow,
              ),
              child: ElevatedButton.icon(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textOnPrimary,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
                  ),
                ),
                icon: const Icon(Icons.login, size: 20),
                label: Text(
                  'Iniciar Sesión',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            
            // Botón secundario - Registrarse
            Container(
              width: double.infinity,
              height: UIConstants.buttonHeight + 8,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.textOnPrimary.withOpacity(0.5),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
              ),
              child: OutlinedButton.icon(
                onPressed: _navigateToRegister,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textOnPrimary,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
                  ),
                ),
                icon: const Icon(Icons.person_add, size: 20),
                label: Text(
                  'Registrarse',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: UIConstants.largePadding),
            
            // Enlace para invitados
            const SizedBox(height: UIConstants.defaultPadding),
            
            // Información de versión
            Text(
              'Versión ${AppConfig.version}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textOnPrimary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de navegación
  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void _showGuestOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(UIConstants.largePadding),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(UIConstants.largeRadius),
            topRight: Radius.circular(UIConstants.largeRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: UIConstants.largePadding),
            
            // Título
            Text(
              'Explorar como invitado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            
            // Descripción
            Text(
              'Como invitado puedes:\n• Ver canchas disponibles\n• Consultar horarios\n• Conocer promociones\n\nPara hacer reservas necesitas crear una cuenta.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: UIConstants.largePadding),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: UIConstants.defaultPadding),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _navigateAsGuest,
                    child: const Text('Continuar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateAsGuest() {
    Navigator.pop(context); // Cerrar modal
    Navigator.pushReplacementNamed(context, '/home');
  }
}