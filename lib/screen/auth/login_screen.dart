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

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WallyAppBars.section(
        title: 'Iniciar Sesión',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: OverlayLoading(
          isLoading: _isLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.largePadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: UIConstants.largePadding * 2),
                  _buildLoginForm(),
                  const SizedBox(height: UIConstants.largePadding),
                  _buildLoginButton(),
                  const SizedBox(height: UIConstants.defaultPadding),
                  _buildForgotPassword(),
                  const SizedBox(height: UIConstants.largePadding),
                  _buildDivider(),
                  const SizedBox(height: UIConstants.largePadding),
                  _buildRegisterSection(),
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
        // Logo
        Container(
          padding: const EdgeInsets.all(UIConstants.largePadding),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.sports_soccer,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: UIConstants.largePadding),
        
        // Título
        Text(
          '¡Bienvenido de vuelta!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UIConstants.smallPadding),
        
        // Subtítulo
        Text(
          'Inicia sesión para reservar tu cancha',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Campo de usuario
        WallyTextFields.username(
          controller: _usernameController,
          autofocus: true,
          onChanged: (_) => _clearErrorIfExists(),
        ),
        const SizedBox(height: UIConstants.defaultPadding),
        
        // Campo de contraseña
        WallyTextFields.password(
          controller: _passwordController,
          onChanged: (_) => _clearErrorIfExists(),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return WallyButtons.login(
      onPressed: _isLoading ? null : _handleLogin,
      isLoading: _isLoading,
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: _handleForgotPassword,
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
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
    );
  }

  Widget _buildRegisterSection() {
    return Column(
      children: [
        Text(
          '¿No tienes una cuenta?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: UIConstants.smallPadding),
        WallyButtons.register(onPressed: _navigateToRegister)
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.loginUser(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        Helpers.showSuccessSnackBar(context, 'Inicio de sesión exitoso');
        _navigateToHome();
      } else {
        Helpers.showErrorSnackBar(
          context, 
          authProvider.errorMessage ?? 'Error al iniciar sesión'
        );
      }
    } catch (e) {
      Helpers.showErrorSnackBar(context, 'Error inesperado. Inténtalo nuevamente.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar Contraseña'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Para recuperar tu contraseña, contacta con el administrador:',
            ),
            SizedBox(height: UIConstants.defaultPadding),
            SelectableText(
              'admin@wallyreservas.com',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, '/register');
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }
}