import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/colors.dart';
import '../../utils/constants.dart';

enum TextFieldType { text, email, password, phone, number, multiline }

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final TextFieldType type;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final bool readOnly;
  final bool enabled;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final String? initialValue;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.type = TextFieldType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.maxLength,
    this.initialValue,
    this.contentPadding,
    this.borderRadius = UIConstants.defaultRadius,
    this.autofocus = false,
    this.textInputAction,
    this.focusNode,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: UIConstants.smallPadding / 2),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          initialValue: widget.initialValue,
          keyboardType: _getKeyboardType(),
          inputFormatters: _getInputFormatters(),
          textInputAction: widget.textInputAction ?? _getTextInputAction(),
          obscureText: widget.type == TextFieldType.password ? _obscureText : false,
          maxLines: _getMaxLines(),
          maxLength: widget.maxLength,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            filled: true,
            fillColor: widget.enabled ? AppColors.surface : AppColors.surfaceVariant,
            contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
              horizontal: UIConstants.defaultPadding,
              vertical: UIConstants.smallPadding + 4,
            ),
            prefixIcon: widget.prefixIcon != null 
                ? Icon(widget.prefixIcon, color: AppColors.textSecondary) 
                : null,
            suffixIcon: _buildSuffixIcon(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(color: AppColors.textDisabled),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == TextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.number:
        return TextInputType.number;
      case TextFieldType.multiline:
        return TextInputType.multiline;
      case TextFieldType.password:
      case TextFieldType.text:
      default:
        return TextInputType.text;
    }
  }

  TextInputAction _getTextInputAction() {
    switch (widget.type) {
      case TextFieldType.multiline:
        return TextInputAction.newline;
      default:
        return TextInputAction.next;
    }
  }

  int? _getMaxLines() {
    if (widget.maxLines != null) return widget.maxLines;
    
    switch (widget.type) {
      case TextFieldType.multiline:
        return 4;
      case TextFieldType.password:
        return 1;
      default:
        return 1;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.type) {
      case TextFieldType.phone:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(Validation.phoneLength),
        ];
      case TextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return null;
    }
  }
}

// Widget helpers para campos específicos comunes
class WallyTextFields {
  static Widget email({
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool autofocus = false,
  }) {
    return CustomTextField(
      label: 'Email',
      hint: 'Ingresa tu email',
      controller: controller,
      type: TextFieldType.email,
      prefixIcon: Icons.email_outlined,
      validator: validator ?? _defaultEmailValidator,
      onChanged: onChanged,
      autofocus: autofocus,
    );
  }

  static Widget username({
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool autofocus = false,
  }) {
    return CustomTextField(
      label: 'Usuario',
      hint: 'Ingresa tu nombre de usuario',
      controller: controller,
      type: TextFieldType.text,
      prefixIcon: Icons.person_outline,
      validator: validator ?? _defaultUsernameValidator,
      onChanged: onChanged,
      autofocus: autofocus,
    );
  }

  static Widget password({
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? label,
  }) {
    return CustomTextField(
      label: label ?? 'Contraseña',
      hint: 'Ingresa tu contraseña',
      controller: controller,
      type: TextFieldType.password,
      prefixIcon: Icons.lock_outline,
      validator: validator ?? _defaultPasswordValidator,
      onChanged: onChanged,
    );
  }

  static Widget confirmPassword({
    TextEditingController? controller,
    TextEditingController? passwordController,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return CustomTextField(
      label: 'Confirmar Contraseña',
      hint: 'Confirma tu contraseña',
      controller: controller,
      type: TextFieldType.password,
      prefixIcon: Icons.lock_outline,
      validator: validator ?? (value) => _defaultConfirmPasswordValidator(value, passwordController?.text),
      onChanged: onChanged,
    );
  }

  static Widget fullName({
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool autofocus = false,
  }) {
    return CustomTextField(
      label: 'Nombre Completo',
      hint: 'Ingresa tu nombre completo',
      controller: controller,
      type: TextFieldType.text,
      prefixIcon: Icons.person_outline,
      validator: validator ?? _defaultNameValidator,
      onChanged: onChanged,
      autofocus: autofocus,
    );
  }

  static Widget phone({
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return CustomTextField(
      label: 'Teléfono',
      hint: 'Ingresa tu número de teléfono',
      controller: controller,
      type: TextFieldType.phone,
      prefixIcon: Icons.phone_outlined,
      validator: validator ?? _defaultPhoneValidator,
      onChanged: onChanged,
    );
  }

  static Widget search({
    TextEditingController? controller,
    String? hint,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
  }) {
    return CustomTextField(
      hint: hint ?? 'Buscar...',
      controller: controller,
      type: TextFieldType.text,
      prefixIcon: Icons.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
    );
  }

  static Widget multiline({
    TextEditingController? controller,
    String? label,
    String? hint,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 4,
    int? maxLength,
  }) {
    return CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      type: TextFieldType.multiline,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
    );
  }

  // Validadores por defecto
  static String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    if (!RegExp(RegexPatterns.email).hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  static String? _defaultUsernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El usuario es requerido';
    }
    if (value.length < Validation.minUsernameLength) {
      return 'Mínimo ${Validation.minUsernameLength} caracteres';
    }
    if (value.length > Validation.maxUsernameLength) {
      return 'Máximo ${Validation.maxUsernameLength} caracteres';
    }
    if (!RegExp(RegexPatterns.username).hasMatch(value)) {
      return 'Solo letras, números y guiones bajos';
    }
    return null;
  }

  static String? _defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < Validation.minPasswordLength) {
      return 'Mínimo ${Validation.minPasswordLength} caracteres';
    }
    if (value.length > Validation.maxPasswordLength) {
      return 'Máximo ${Validation.maxPasswordLength} caracteres';
    }
    return null;
  }

  static String? _defaultConfirmPasswordValidator(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? _defaultNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.length < Validation.minNombreLength) {
      return 'Mínimo ${Validation.minNombreLength} caracteres';
    }
    if (value.length > Validation.maxNombreLength) {
      return 'Máximo ${Validation.maxNombreLength} caracteres';
    }
    if (!RegExp(RegexPatterns.onlyLetters).hasMatch(value)) {
      return 'Solo se permiten letras';
    }
    return null;
  }

  static String? _defaultPhoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    if (!RegExp(RegexPatterns.phone).hasMatch(value)) {
      return 'Ingresa un teléfono válido';
    }
    return null;
  }
}