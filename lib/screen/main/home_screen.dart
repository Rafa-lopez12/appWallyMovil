import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const FullScreenLoading(
        message: 'Cargando...',
        type: LoadingType.fadingCircle,
      );
    }

    return Scaffold(
      appBar: WallyAppBars.home(
        context: context,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _showNotifications,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text('Mi Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text('Configuración'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(UIConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: UIConstants.largePadding),
              _buildQuickActions(),
              const SizedBox(height: UIConstants.largePadding),
              _buildRecentReservations(),
              const SizedBox(height: UIConstants.largePadding),
              _buildPromotions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildWelcomeSection() {
    final user = _authService.currentUser;
    final cliente = _authService.currentCliente;
    final name = user?.nombre ?? cliente?.nombre ?? 'Usuario';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UIConstants.largePadding),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(UIConstants.largeRadius),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, $name!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: UIConstants.smallPadding),
          Text(
            'Encuentra y reserva tu cancha favorita',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: UIConstants.defaultPadding),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.sports_soccer,
            title: 'Reservas',
            value: '12',
            subtitle: 'Este mes',
          ),
        ),
        const SizedBox(width: UIConstants.defaultPadding),
        Expanded(
          child: _buildStatItem(
            icon: Icons.star,
            title: 'Puntos',
            value: '89',
            subtitle: 'Acumulados',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.textOnPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textOnPrimary, size: 20),
              const SizedBox(width: UIConstants.smallPadding),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.smallPadding),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textOnPrimary.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: UIConstants.defaultPadding),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_circle_outline,
                title: 'Nueva\nReserva',
                color: AppColors.primary,
                onTap: _navigateToNewReservation,
              ),
            ),
            const SizedBox(width: UIConstants.defaultPadding),
            Expanded(
              child: _buildActionCard(
                icon: Icons.list_alt,
                title: 'Mis\nReservas',
                color: AppColors.secondary,
                onTap: _navigateToReservations,
              ),
            ),
            const SizedBox(width: UIConstants.defaultPadding),
            Expanded(
              child: _buildActionCard(
                icon: Icons.location_on_outlined,
                title: 'Ver\nCanchas',
                color: AppColors.accent,
                onTap: _navigateToCanchas,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: UIConstants.largeIconSize),
            const SizedBox(height: UIConstants.smallPadding),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReservations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reservas Recientes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _navigateToReservations,
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.defaultPadding),
        _buildReservationsList(),
      ],
    );
  }

  Widget _buildReservationsList() {
    // Datos de ejemplo - en la app real estos vendrían de la API
    final reservations = [
      {
        'cancha': 'Cancha A',
        'fecha': '25/07/2025',
        'hora': '18:00 - 19:00',
        'estado': 'Confirmada',
      },
      {
        'cancha': 'Cancha B',
        'fecha': '22/07/2025',
        'hora': '20:00 - 21:00',
        'estado': 'Pendiente',
      },
    ];

    if (reservations.isEmpty) {
      return const EmptyWidget(
        message: 'No tienes reservas recientes',
        actionText: 'Hacer una reserva',
        icon: Icons.event_available,
      );
    }

    return Column(
      children: reservations.map((reservation) {
        return _buildReservationCard(reservation);
      }).toList(),
    );
  }

  Widget _buildReservationCard(Map<String, String> reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.defaultPadding),
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(UIConstants.smallPadding),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(UIConstants.smallRadius),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: UIConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation['cancha']!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${reservation['fecha']} • ${reservation['hora']}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.smallPadding,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: reservation['estado'] == 'Confirmada' 
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(UIConstants.smallRadius),
            ),
            child: Text(
              reservation['estado']!,
              style: TextStyle(
                color: reservation['estado'] == 'Confirmada' 
                    ? AppColors.success
                    : AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promociones Activas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: UIConstants.defaultPadding),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(UIConstants.largePadding),
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_offer,
                    color: AppColors.textOnPrimary,
                  ),
                  const SizedBox(width: UIConstants.smallPadding),
                  Text(
                    '20% de descuento',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.smallPadding),
              Text(
                'En reservas de fin de semana\nVálido hasta el 31 de Julio',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textOnPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, // Home está seleccionado
      onTap: _onBottomNavTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_soccer),
          label: 'Canchas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Reservas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToNewReservation,
      tooltip: 'Nueva Reserva',
      child: const Icon(Icons.add),
    );
  }

  // Métodos de navegación y acciones
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    // Aquí refrescarías los datos de la API
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Ya estamos en Home
        break;
      case 1:
        _navigateToCanchas();
        break;
      case 2:
        _navigateToReservations();
        break;
      case 3:
        _navigateToProfile();
        break;
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        _navigateToProfile();
        break;
      case 'settings':
        _navigateToSettings();
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showNotifications() {
    // TODO: Implementar notificaciones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notificaciones próximamente')),
    );
  }

  void _navigateToNewReservation() {
    Navigator.pushNamed(context, '/nueva-reserva');
  }

  void _navigateToReservations() {
    Navigator.pushNamed(context, '/reservas');
  }

  void _navigateToCanchas() {
    Navigator.pushNamed(context, '/canchas');
  }

  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _navigateToSettings() {
    // TODO: Implementar configuraciones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuraciones próximamente')),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/welcome');
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}