import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../utils/constants.dart';

enum ButtonType { primary, secondary, outline, text, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final TextStyle? textStyle;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = UIConstants.defaultRadius,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? UIConstants.buttonHeight,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return _buildElevatedButton(context);
      case ButtonType.secondary:
        return _buildSecondaryButton(context);
      case ButtonType.outline:
        return _buildOutlinedButton(context);
      case ButtonType.text:
        return _buildTextButton(context);
      case ButtonType.danger:
        return _buildDangerButton(context);
    }
  }

  Widget _buildElevatedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: UIConstants.cardElevation,
        shadowColor: AppColors.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultPadding,
          vertical: UIConstants.smallPadding,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: UIConstants.cardElevation,
        shadowColor: AppColors.secondary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultPadding,
          vertical: UIConstants.smallPadding,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: isLoading ? AppColors.textDisabled : AppColors.primary,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultPadding,
          vertical: UIConstants.smallPadding,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultPadding,
          vertical: UIConstants.smallPadding,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildDangerButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.textOnPrimary,
        elevation: UIConstants.cardElevation,
        shadowColor: AppColors.error.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: UIConstants.defaultPadding,
          vertical: UIConstants.smallPadding,
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: UIConstants.smallPadding),
          Text(
            text,
            style: textStyle ?? const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: textStyle ?? const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Widget helper para botones específicos comunes
class WallyButtons {
  static Widget login({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: 'Iniciar Sesión',
      onPressed: onPressed,
      type: ButtonType.primary,
      isLoading: isLoading,
      isFullWidth: true,
      icon: Icons.login,
    );
  }

  static Widget register({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: 'Registrarse',
      onPressed: onPressed,
      type: ButtonType.secondary,
      isLoading: isLoading,
      isFullWidth: true,
      icon: Icons.person_add,
    );
  }

  static Widget reservar({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: 'Reservar Cancha',
      onPressed: onPressed,
      type: ButtonType.primary,
      isLoading: isLoading,
      isFullWidth: true,
      icon: Icons.sports_soccer,
    );
  }

  static Widget cancelar({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: 'Cancelar',
      onPressed: onPressed,
      type: ButtonType.outline,
      isLoading: isLoading,
    );
  }

  static Widget confirmar({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: 'Confirmar',
      onPressed: onPressed,
      type: ButtonType.primary,
      isLoading: isLoading,
    );
  }

  static Widget eliminar({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: 'Eliminar',
      onPressed: onPressed,
      type: ButtonType.danger,
      isLoading: isLoading,
      icon: Icons.delete_outline,
    );
  }

  static Widget editar({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: 'Editar',
      onPressed: onPressed,
      type: ButtonType.outline,
      isLoading: isLoading,
      icon: Icons.edit_outlined,
    );
  }

  static Widget enviarSugerencia({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: 'Enviar Sugerencia',
      onPressed: onPressed,
      type: ButtonType.primary,
      isLoading: isLoading,
      isFullWidth: true,
      icon: Icons.send,
    );
  }
}