import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/auth_helpers.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_buttom.dart';
import '../../widgets/common/loading_widget.dart';
import '../../providers/canchas_provider.dart';
import '../../providers/promociones_provider.dart';
import '../../providers/reservas_provider.dart';
import '../../providers/clientes_provider.dart';
import '../../models/cancha.dart';
import '../../models/promocion.dart';
import '../../models/cliente.dart';

class NuevaReservaScreen extends StatefulWidget {
  const NuevaReservaScreen({Key? key}) : super(key: key);

  @override
  State<NuevaReservaScreen> createState() => _NuevaReservaScreenState();
}

class _NuevaReservaScreenState extends State<NuevaReservaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Datos del formulario
  Cancha? _selectedCancha;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  Promocion? _selectedPromocion;
  Cliente? _selectedCliente;
  
  // Estado
  bool _isLoading = true;
  bool _isCreatingReserva = false;
  double _basePrice = 100.0; // Precio base por hora
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait([
        Provider.of<CanchasProvider>(context, listen: false).loadCanchas(),
        Provider.of<PromocionesProvider>(context, listen: false).loadPromociones(),
        // Solo cargar clientes si es usuario (admin/empleado)
        if (AuthHelpers.canReserveForOthers(context))
          Provider.of<ClientesProvider>(context, listen: false).loadClientes(),
      ]);
    } catch (e) {
      Helpers.showErrorSnackBar(context, 'Error al cargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const FullScreenLoading(
        message: 'Cargando datos...',
        type: LoadingType.fadingCircle,
      );
    }

    return Scaffold(
      appBar: WallyAppBars.form(
        title: 'Nueva Reserva',
        showSave: true,
        onSave: _handleCreateReserva,
        onCancel: () => Navigator.pop(context),
      ),
      body: OverlayLoading(
        isLoading: _isCreatingReserva,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepIndicator(),
                      const SizedBox(height: UIConstants.largePadding),
                      _buildCanchaSelection(),
                      const SizedBox(height: UIConstants.largePadding),
                      _buildDateTimeSelection(),
                      const SizedBox(height: UIConstants.largePadding),
                      _buildPromocionSelection(),
                      if (AuthHelpers.canReserveForOthers(context)) ...[
                        const SizedBox(height: UIConstants.largePadding),
                        _buildClienteSelection(),
                      ],
                      const SizedBox(height: UIConstants.largePadding),
                      _buildPriceSummary(),
                      const SizedBox(height: UIConstants.largePadding * 2),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: UIConstants.smallPadding),
          Expanded(
            child: Text(
              'Completa todos los campos para crear tu reserva',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanchaSelection() {
    return _buildSection(
      title: '1. Selecciona una Cancha',
      icon: Icons.sports_soccer,
      child: Consumer<CanchasProvider>(
        builder: (context, canchasProvider, child) {
          final canchasDisponibles = canchasProvider.getCanchasDisponibles();
          
          if (canchasDisponibles.isEmpty) {
            return const EmptyWidget(
              message: 'No hay canchas disponibles',
              icon: Icons.sports_soccer_outlined,
            );
          }

          return Column(
            children: canchasDisponibles.map((cancha) {
              final isSelected = _selectedCancha?.id == cancha.id;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedCancha = cancha),
                child: Container(
                  margin: const EdgeInsets.only(bottom: UIConstants.smallPadding),
                  padding: const EdgeInsets.all(UIConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
                    borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? AppColors.cardShadow : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(UIConstants.smallPadding),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.canchaAvailable,
                          borderRadius: BorderRadius.circular(UIConstants.smallRadius),
                        ),
                        child: Icon(
                          Icons.sports_soccer,
                          color: AppColors.textOnPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: UIConstants.defaultPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cancha.cancha,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              cancha.estadoTexto,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.canchaAvailable,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return _buildSection(
      title: '2. Fecha y Horario',
      icon: Icons.calendar_today,
      child: Column(
        children: [
          // Selección de fecha
          _buildDatePicker(),
          const SizedBox(height: UIConstants.defaultPadding),
          // Selección de horarios
          Row(
            children: [
              Expanded(child: _buildTimePicker('Hora inicio', _selectedStartTime, (time) {
                setState(() => _selectedStartTime = time);
                _validateAndSetEndTime();
              })),
              const SizedBox(width: UIConstants.defaultPadding),
              Expanded(child: _buildTimePicker('Hora fin', _selectedEndTime, (time) {
                setState(() => _selectedEndTime = time);
              })),
            ],
          ),
          if (_selectedDate != null && _selectedStartTime != null && _selectedEndTime != null)
            _buildScheduleValidation(),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.textSecondary),
            const SizedBox(width: UIConstants.defaultPadding),
            Expanded(
              child: Text(
                _selectedDate != null 
                  ? Helpers.formatDate(_selectedDate!)
                  : 'Seleccionar fecha',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? selectedTime, Function(TimeOfDay) onTimeSelected) {
    return GestureDetector(
      onTap: () => _selectTime(onTimeSelected),
      child: Container(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: UIConstants.smallPadding),
                Expanded(
                  child: Text(
                    selectedTime != null 
                      ? selectedTime.format(context)
                      : '--:--',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: selectedTime != null ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleValidation() {
    if (!_isScheduleValid()) {
      return Container(
        margin: const EdgeInsets.only(top: UIConstants.defaultPadding),
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: UIConstants.smallPadding),
            Expanded(
              child: Text(
                _getScheduleErrorMessage(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: UIConstants.defaultPadding),
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: UIConstants.smallPadding),
          Expanded(
            child: Text(
              'Horario disponible • Duración: ${_getDurationText()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromocionSelection() {
    return _buildSection(
      title: '3. Promociones (Opcional)',
      icon: Icons.local_offer,
      child: Consumer<PromocionesProvider>(
        builder: (context, promocionesProvider, child) {
          final promocionesActivas = promocionesProvider.getPromocionesActivas();
          
          if (promocionesActivas.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(UIConstants.defaultPadding),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.textSecondary),
                  const SizedBox(width: UIConstants.smallPadding),
                  const Expanded(
                    child: Text('No hay promociones disponibles'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Opción "Sin promoción"
              _buildPromocionOption(null),
              const SizedBox(height: UIConstants.smallPadding),
              // Promociones disponibles
              ...promocionesActivas.map((promocion) => 
                _buildPromocionOption(promocion)
              ).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPromocionOption(Promocion? promocion) {
    final isSelected = (_selectedPromocion?.id == promocion?.id) || 
                     (_selectedPromocion == null && promocion == null);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPromocion = promocion),
      child: Container(
        margin: const EdgeInsets.only(bottom: UIConstants.smallPadding),
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(UIConstants.smallPadding),
              decoration: BoxDecoration(
                color: promocion != null ? AppColors.accent : AppColors.textSecondary,
                borderRadius: BorderRadius.circular(UIConstants.smallRadius),
              ),
              child: Icon(
                promocion != null ? Icons.local_offer : Icons.money_off,
                color: AppColors.textOnPrimary,
                size: 16,
              ),
            ),
            const SizedBox(width: UIConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promocion?.motivo ?? 'Sin promoción',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (promocion != null) ...[
                    Text(
                      promocion.descripcion,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (promocion != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.smallPadding,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(UIConstants.smallRadius),
                ),
                child: Text(
                  '${promocion.descuento.toInt()}% OFF',
                  style: const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: UIConstants.smallPadding),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.accent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClienteSelection() {
    return _buildSection(
      title: '4. Cliente',
      icon: Icons.person,
      child: Consumer<ClientesProvider>(
        builder: (context, clientesProvider, child) {
          final clientes = clientesProvider.clientes;
          
          if (clientes.isEmpty) {
            return const EmptyWidget(
              message: 'No hay clientes registrados',
              icon: Icons.person_outline,
            );
          }

          return DropdownButtonFormField<Cliente>(
            value: _selectedCliente,
            decoration: InputDecoration(
              hintText: 'Seleccionar cliente',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
              ),
            ),
            items: clientes.map((cliente) {
              return DropdownMenuItem<Cliente>(
                value: cliente,
                child: Text('${cliente.nombre} (@${cliente.username})'),
              );
            }).toList(),
            onChanged: (cliente) => setState(() => _selectedCliente = cliente),
            validator: (value) {
              if (AuthHelpers.canReserveForOthers(context) && value == null) {
                return 'Selecciona un cliente';
              }
              return null;
            },
          );
        },
      ),
    );
  }

  Widget _buildPriceSummary() {
    if (!_canCalculatePrice()) {
      return const SizedBox.shrink();
    }

    final duration = _getDurationInHours();
    final subtotal = _basePrice * duration;
    final descuento = _selectedPromocion?.calcularMontoDescuento(subtotal) ?? 0;
    final total = subtotal - descuento;

    return _buildSection(
      title: 'Resumen del Precio',
      icon: Icons.receipt,
      child: Container(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
        ),
        child: Column(
          children: [
            _buildPriceRow('Duración', _getDurationText(), ''),
            _buildPriceRow('Precio por hora', '', Helpers.formatCurrency(_basePrice)),
            _buildPriceRow('Subtotal', '', Helpers.formatCurrency(subtotal)),
            if (descuento > 0) ...[
              _buildPriceRow(
                'Descuento (${_selectedPromocion!.descuentoTexto})', 
                '', 
                '-${Helpers.formatCurrency(descuento)}',
                color: AppColors.success,
              ),
              const Divider(),
            ],
            _buildPriceRow(
              'Total', 
              '', 
              Helpers.formatCurrency(total),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String detail, String amount, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
          if (detail.isNotEmpty) ...[
            Text(
              detail,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: UIConstants.smallPadding),
          ],
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color ?? (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: WallyButtons.cancelar(
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: UIConstants.defaultPadding),
          Expanded(
            flex: 2,
            child: WallyButtons.reservar(
              onPressed: _canCreateReserva() ? _handleCreateReserva : null,
              isLoading: _isCreatingReserva,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: UIConstants.smallPadding),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.defaultPadding),
        child,
      ],
    );
  }

  // Métodos de validación y lógica
  bool _canCreateReserva() {
    return _selectedCancha != null &&
           _selectedDate != null &&
           _selectedStartTime != null &&
           _selectedEndTime != null &&
           _isScheduleValid() &&
           (!AuthHelpers.canReserveForOthers(context) || _selectedCliente != null);
  }

  bool _canCalculatePrice() {
    return _selectedStartTime != null && _selectedEndTime != null && _isScheduleValid();
  }

  bool _isScheduleValid() {
    if (_selectedDate == null || _selectedStartTime == null || _selectedEndTime == null) {
      return false;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );

    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedEndTime!.hour,
      _selectedEndTime!.minute,
    );

    // Validar que la fecha sea futura
    if (startDateTime.isBefore(DateTime.now().add(const Duration(hours: 2)))) {
      return false;
    }

    // Validar que hora fin sea después de hora inicio
    if (endDateTime.isBefore(startDateTime)) {
      return false;
    }

    // Validar duración mínima (1 hora)
    if (endDateTime.difference(startDateTime).inMinutes < 60) {
      return false;
    }

    // Validar duración máxima (3 horas)
    if (endDateTime.difference(startDateTime).inMinutes > 180) {
      return false;
    }

    // Validar horario de negocio (8 AM - 10 PM)
    if (_selectedStartTime!.hour < 8 || _selectedEndTime!.hour > 22) {
      return false;
    }

    return true;
  }

  String _getScheduleErrorMessage() {
    if (_selectedDate == null || _selectedStartTime == null || _selectedEndTime == null) {
      return 'Completa todos los campos';
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );

    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedEndTime!.hour,
      _selectedEndTime!.minute,
    );

    if (startDateTime.isBefore(DateTime.now().add(const Duration(hours: 2)))) {
      return 'Debe reservar con al menos 2 horas de anticipación';
    }

    if (endDateTime.isBefore(startDateTime)) {
      return 'La hora de fin debe ser posterior a la de inicio';
    }

    final duration = endDateTime.difference(startDateTime).inMinutes;
    if (duration < 60) {
      return 'La duración mínima es 1 hora';
    }

    if (duration > 180) {
      return 'La duración máxima es 3 horas';
    }

    if (_selectedStartTime!.hour < 8 || _selectedEndTime!.hour > 22) {
      return 'Horario de atención: 8:00 AM - 10:00 PM';
    }

    return 'Horario no válido';
  }

  double _getDurationInHours() {
    if (_selectedStartTime == null || _selectedEndTime == null) return 0;

    final startDateTime = DateTime(2024, 1, 1, _selectedStartTime!.hour, _selectedStartTime!.minute);
    final endDateTime = DateTime(2024, 1, 1, _selectedEndTime!.hour, _selectedEndTime!.minute);

    return endDateTime.difference(startDateTime).inMinutes / 60.0;
  }

  String _getDurationText() {
    final duration = _getDurationInHours();
    if (duration == duration.toInt()) {
      return '${duration.toInt()} hora${duration == 1 ? '' : 's'}';
    } else {
      return '${duration.toStringAsFixed(1)} horas';
    }
  }

  void _validateAndSetEndTime() {
    if (_selectedStartTime != null) {
      // Sugerir 1 hora después como hora de fin por defecto
      final suggestedEndTime = TimeOfDay(
        hour: (_selectedStartTime!.hour + 1) % 24,
        minute: _selectedStartTime!.minute,
      );
      
      if (_selectedEndTime == null) {
        setState(() => _selectedEndTime = suggestedEndTime);
      }
    }
  }

  // Métodos de selección
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now.add(const Duration(hours: 2));
    final lastDate = now.add(const Duration(days: 30));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime(Function(TimeOfDay) onTimeSelected) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      onTimeSelected(pickedTime);
    }
  }

  // Crear reserva
  Future<void> _handleCreateReserva() async {
    if (!_formKey.currentState!.validate() || !_canCreateReserva()) {
      return;
    }

    setState(() => _isCreatingReserva = true);

    try {
      final reservaData = AuthHelpers.getReservaCreationData(
        context,
        selectedClienteName: _selectedCliente?.nombre,
      );

      // Crear fechas completas
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedStartTime!.hour,
        _selectedStartTime!.minute,
      );

      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedEndTime!.hour,
        _selectedEndTime!.minute,
      );

      // Calcular precio final
      final duration = _getDurationInHours();
      final subtotal = _basePrice * duration;
      final descuento = _selectedPromocion?.calcularMontoDescuento(subtotal) ?? 0;
      final montoFinal = subtotal - descuento;

      // Verificar disponibilidad del horario
      final reservasProvider = Provider.of<ReservasProvider>(context, listen: false);
      final isAvailable = reservasProvider.isHorarioDisponible(
        canchaNombre: _selectedCancha!.cancha,
        fechaHoraInicio: startDateTime,
        fechaHoraFin: endDateTime,
      );

      if (!isAvailable) {
        Helpers.showErrorSnackBar(
          context, 
          'El horario seleccionado ya no está disponible'
        );
        setState(() => _isCreatingReserva = false);
        return;
      }

      // Crear la reserva
      final success = await reservasProvider.createReservaWithAuth(
        monto: montoFinal,
        fechaHoraInicio: startDateTime,
        fechaHoraFin: endDateTime,
        canchaNombre: _selectedCancha!.cancha,
        promocionId: _selectedPromocion?.id ?? 1, // ID por defecto si no hay promoción
        clienteNombre: reservaData.clienteNombre,
        usuarioNombre: reservaData.usuarioNombre,
      );

      if (success) {
        // Mostrar mensaje de éxito
        Helpers.showSuccessSnackBar(
          context, 
          '¡Reserva creada exitosamente!'
        );

        // Navegar de vuelta con resultado
        Navigator.pop(context, true);
      } else {
        Helpers.showErrorSnackBar(
          context, 
          reservasProvider.errorMessage ?? 'Error al crear la reserva'
        );
      }
    } catch (e) {
      Helpers.showErrorSnackBar(
        context, 
        'Error inesperado: ${e.toString()}'
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingReserva = false);
      }
    }
  }
}