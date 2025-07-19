import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_buttom.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefonoController = TextEditingController();
  
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WallyAppBars.section(
        title: 'Crear Cuenta',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: OverlayLoading(
          isLoading: _isLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: UIConstants.largePadding),
                  _buildRegisterForm(),
                  const SizedBox(height: UIConstants.defaultPadding),
                  _buildTermsAndConditions(),
                  const SizedBox(height: UIConstants.largePadding),
                  _buildRegisterButton(),
                  const SizedBox(height: UIConstants.defaultPadding),
                  _buildLoginSection(),
                  const SizedBox(height: UIConstants.largePadding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icono
        Container(
          padding: const EdgeInsets.all(UIConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_add,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: UIConstants.defaultPadding),
        
        // Título
        Text(
          '¡Únete a Wally!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UIConstants.smallPadding),
        
        // Subtítulo
        Text(
          'Crea tu cuenta y comienza a reservar',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        // Nombre completo
        WallyTextFields.fullName(
          controller: _nombreController,
          autofocus: true,
          onChanged: (_) => _clearErrorIfExists(),
        ),
        const SizedBox(height: UIConstants.defaultPadding),
        
        // Usuario
        WallyTextFields.username(
          controller: _usernameController,
          onChanged: (_) => _clearErrorIfExists(),
        ),
        const SizedBox(height: UIConstants.defaultPadding),
        
        // Teléfono
        WallyTextFields.phone(
          controller: _telefonoController,
          onChanged: (_) => _clearErrorIfExists(),
        ),
        const SizedBox(height: UIConstants.defaultPadding),
        
        // Contraseña
        WallyTextFields.password(
          controller: _passwordController,
          onChanged: (_) => _clearErrorIfExists(),
        ),
        const SizedBox(height: UIConstants.defaultPadding),
        
        // Confirmar contraseña
        WallyTextFields.confirmPassword(
          controller: _confirmPasswordController,
          passwordController: _passwordController,
          onChanged: (_) => _clearErrorIfExists(),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Acepto los '),
                    TextSpan(
                      text: 'Términos y Condiciones',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      // TODO: Agregar recognizer para abrir términos
                    ),
                    const TextSpan(text: ' y la '),
                    TextSpan(
                      text: 'Política de Privacidad',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      // TODO: Agregar recognizer para abrir política
                    ),
                    const TextSpan(text: ' de Wally Reservas.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return WallyButtons.register(
      onPressed: (_acceptTerms && !_isLoading) ? _handleRegister : null,
      isLoading: _isLoading,
    );
  }

  Widget _buildLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: UIConstants.defaultPadding),
              child: Text(
                'O',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: UIConstants.defaultPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Ya tienes una cuenta? ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: _navigateToLogin,
              child: Text(
                'Inicia sesión',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Métodos de manejo
  void _clearErrorIfExists() {
    // Limpiar errores visuales si los hay
    if (_formKey.currentState?.validate() == false) {
      _formKey.currentState?.validate();
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      _showErrorMessage('Debes aceptar los términos y condiciones');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.registerUser(
        nombre: _nombreController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        telefono: _telefonoController.text.trim(),
      );

      if (success) {
        _showSuccessMessage('¡Cuenta creada exitosamente!');
        await Future.delayed(const Duration(milliseconds: 1500));
        _navigateToHome();
      } else {
        _showErrorMessage(authProvider.errorMessage ?? 'Error al crear la cuenta');
      }
    } catch (e) {
      _showErrorMessage('Error inesperado. Inténtalo nuevamente.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/home', 
      (route) => false,
    );
  }

  void _showSuccessMessage(String message) {
    Helpers.showSuccessSnackBar(context, message);
  }

  void _showErrorMessage(String message) {
    Helpers.showErrorSnackBar(context, message);
  }
}