import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/auth_helpers.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart' hide ErrorWidget;
import '../../widgets/common/loading_widget.dart' as widgets show ErrorWidget, EmptyWidget;
import '../../providers/reservas_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/reserva.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({Key? key}) : super(key: key);

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReservas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservas() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reservasProvider = Provider.of<ReservasProvider>(context, listen: false);
    
    try {
      if (AuthHelpers.canViewAllReservas(context)) {
        // Cargar todas las reservas si es admin/empleado
        await reservasProvider.loadReservas();
      } else if (authProvider.currentCliente != null) {
        // Cargar solo las reservas del cliente
        await reservasProvider.loadMisReservas(authProvider.currentCliente!.id);
      }
    } catch (e) {
      Helpers.showErrorSnackBar(context, 'Error al cargar reservas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WallyAppBars.withTabs(
        title: 'Mis Reservas',
        tabs: const [
          Tab(text: 'Todas', icon: Icon(Icons.list)),
          Tab(text: 'Activas', icon: Icon(Icons.play_circle_outline)),
          Tab(text: 'Historial', icon: Icon(Icons.history)),
        ],
        tabController: _tabController,
      ),
      body: Consumer<ReservasProvider>(
        builder: (context, reservasProvider, child) {
          if (reservasProvider.isLoading) {
            return const FullScreenLoading(
              message: 'Cargando reservas...',
              type: LoadingType.fadingCircle,
            );
          }

          if (reservasProvider.errorMessage != null) {
            return widgets.ErrorWidget(
              message: reservasProvider.errorMessage!,
              onRetry: _loadReservas,
            );
          }

          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReservasList(_getFilteredReservas(reservasProvider.reservas)),
                    _buildReservasList(_getActiveReservas(reservasProvider.reservas)),
                    _buildReservasList(_getHistorialReservas(reservasProvider.reservas)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNuevaReserva(),
        tooltip: 'Nueva Reserva',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Buscar por cancha o fecha...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.background,
        ),
      ),
    );
  }

  Widget _buildReservasList(List<Reserva> reservas) {
    if (reservas.isEmpty) {
      return widgets.EmptyWidget(
        message: _searchQuery.isNotEmpty 
            ? 'No se encontraron reservas'
            : 'No tienes reservas',
        actionText: 'Hacer una reserva',
        onAction: () => _navigateToNuevaReserva(),
        icon: Icons.event_available,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReservas,
      child: ListView.builder(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        itemCount: reservas.length,
        itemBuilder: (context, index) {
          final reserva = reservas[index];
          return _buildReservaCard(reserva);
        },
      ),
    );
  }

  Widget _buildReservaCard(Reserva reserva) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          width: 4,
          color: _getStatusColor(reserva),
        ),
      ),
      child: Column(
        children: [
          // Header con cancha y estado
          Container(
            padding: const EdgeInsets.all(UIConstants.defaultPadding),
            child: Row(
              children: [
                // Ícono de cancha
                Container(
                  padding: const EdgeInsets.all(UIConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reserva).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.smallRadius),
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    color: _getStatusColor(reserva),
                    size: 20,
                  ),
                ),
                const SizedBox(width: UIConstants.defaultPadding),
                
                // Info principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.cancha.cancha,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reserva.cliente.nombre,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.smallPadding,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reserva).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.smallRadius),
                  ),
                  child: Text(
                    reserva.estadoTexto,
                    style: TextStyle(
                      color: _getStatusColor(reserva),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          const Divider(height: 1),
          
          // Detalles de fecha y hora
          Container(
            padding: const EdgeInsets.all(UIConstants.defaultPadding),
            child: Row(
              children: [
                // Fecha
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: UIConstants.smallPadding),
                      Text(
                        reserva.fechaFormateada,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Hora
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: UIConstants.smallPadding),
                      Text(
                        reserva.rangoHoras,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Precio
                Text(
                  Helpers.formatCurrency(reserva.monto),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Acciones (solo si puede cancelar o está pendiente)
          if (_canShowActions(reserva)) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.defaultPadding,
                vertical: UIConstants.smallPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_canCancelReserva(reserva))
                    TextButton.icon(
                      onPressed: () => _showCancelDialog(reserva),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 16,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  if (_canEditReserva(reserva)) ...[
                    const SizedBox(width: UIConstants.smallPadding),
                    TextButton.icon(
                      onPressed: () => _editReserva(reserva),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: const Text('Editar'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Métodos de filtrado
  List<Reserva> _getFilteredReservas(List<Reserva> reservas) {
    if (_searchQuery.isEmpty) return reservas;
    
    return reservas.where((reserva) {
      final query = _searchQuery.toLowerCase();
      return reserva.cancha.cancha.toLowerCase().contains(query) ||
             reserva.fechaFormateada.contains(query) ||
             reserva.cliente.nombre.toLowerCase().contains(query);
    }).toList();
  }

  List<Reserva> _getActiveReservas(List<Reserva> reservas) {
    final filtered = _getFilteredReservas(reservas);
    return filtered.where((reserva) => 
      reserva.isPendiente || reserva.isEnProgreso
    ).toList();
  }

  List<Reserva> _getHistorialReservas(List<Reserva> reservas) {
    final filtered = _getFilteredReservas(reservas);
    return filtered.where((reserva) => reserva.isTerminada).toList();
  }

  // Métodos de utilidad
  Color _getStatusColor(Reserva reserva) {
    if (reserva.isTerminada) return AppColors.textSecondary;
    if (reserva.isEnProgreso) return AppColors.success;
    if (reserva.isPendiente) return AppColors.primary;
    return AppColors.textSecondary;
  }

  bool _canShowActions(Reserva reserva) {
    return _canCancelReserva(reserva) || _canEditReserva(reserva);
  }

  bool _canCancelReserva(Reserva reserva) {
    // Solo se puede cancelar si está pendiente y faltan más de 2 horas
    if (!reserva.isPendiente) return false;
    
    final horasHastaReserva = reserva.fechaHoraInicio.difference(DateTime.now()).inHours;
    return horasHastaReserva >= 2;
  }

  bool _canEditReserva(Reserva reserva) {
    // Solo admins/empleados pueden editar y solo si está pendiente
    return AuthHelpers.canViewAllReservas(context) && reserva.isPendiente;
  }

  // Métodos de acción
  void _showCancelDialog(Reserva reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro que deseas cancelar esta reserva?'),
            const SizedBox(height: UIConstants.defaultPadding),
            Container(
              padding: const EdgeInsets.all(UIConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.smallRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${reserva.cancha.cancha}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('${reserva.fechaFormateada} • ${reserva.rangoHoras}'),
                  Text('Monto: ${Helpers.formatCurrency(reserva.monto)}'),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            const Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelReserva(reserva);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelReserva(Reserva reserva) async {
    try {
      final reservasProvider = Provider.of<ReservasProvider>(context, listen: false);
      
      final success = await reservasProvider.cancelReserva(reserva.id);
      
      if (success) {
        Helpers.showSuccessSnackBar(context, 'Reserva cancelada exitosamente');
      } else {
        Helpers.showErrorSnackBar(
          context, 
          reservasProvider.errorMessage ?? 'Error al cancelar la reserva'
        );
      }
    } catch (e) {
      Helpers.showErrorSnackBar(context, 'Error inesperado: $e');
    }
  }

  void _editReserva(Reserva reserva) {
    // TODO: Implementar edición de reserva
    Helpers.showInfoSnackBar(context, 'Función de edición próximamente');
  }

  Future<void> _navigateToNuevaReserva() async {
    final result = await Navigator.pushNamed(context, '/nueva-reserva');
    
    if (result == true) {
      // Recargar reservas si se creó una nueva
      _loadReservas();
    }
  }
}