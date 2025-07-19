import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../config/colors.dart';
import '../../utils/constants.dart';

enum LoadingType { circular, dots, wave, pulse, fadingCircle, grid }

class LoadingWidget extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? color;
  final double size;
  final bool overlay;
  final Color? overlayColor;

  const LoadingWidget({
    Key? key,
    this.message,
    this.type = LoadingType.circular,
    this.color,
    this.size = 50.0,
    this.overlay = false,
    this.overlayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? AppColors.primary;
    
    Widget loadingContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingAnimation(loadingColor),
        if (message != null) ...[
          const SizedBox(height: UIConstants.defaultPadding),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (overlay) {
      return Container(
        color: overlayColor ?? Colors.black.withOpacity(0.3),
        child: Center(child: loadingContent),
      );
    }

    return Center(child: loadingContent);
  }

  Widget _buildLoadingAnimation(Color color) {
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 3,
          ),
        );
      
      case LoadingType.dots:
        return SpinKitThreeBounce(
          color: color,
          size: size * 0.6,
        );
      
      case LoadingType.wave:
        return SpinKitWave(
          color: color,
          size: size * 0.8,
        );
      
      case LoadingType.pulse:
        return SpinKitPulse(
          color: color,
          size: size,
        );
      
      case LoadingType.fadingCircle:
        return SpinKitFadingCircle(
          color: color,
          size: size,
        );
      
      case LoadingType.grid:
        return SpinKitFadingGrid(
          color: color,
          size: size,
        );
    }
  }
}

// Widget de loading específico para pantallas completas
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final LoadingType type;

  const FullScreenLoading({
    Key? key,
    this.message,
    this.type = LoadingType.circular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingWidget(
        message: message,
        type: type,
        size: 60,
      ),
    );
  }
}

// Widget de loading para cards o secciones específicas
class SectionLoading extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final double height;

  const SectionLoading({
    Key? key,
    this.message,
    this.type = LoadingType.dots,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      child: LoadingWidget(
        message: message,
        type: type,
        size: 40,
      ),
    );
  }
}

// Widget de loading superpuesto
class OverlayLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final LoadingType type;

  const OverlayLoading({
    Key? key,
    required this.child,
    required this.isLoading,
    this.message,
    this.type = LoadingType.circular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          LoadingWidget(
            message: message,
            type: type,
            overlay: true,
            size: 50,
          ),
      ],
    );
  }
}

// Widget de loading para listas
class ListLoading extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ListLoading({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      height: itemHeight,
      margin: const EdgeInsets.symmetric(
        horizontal: UIConstants.defaultPadding,
        vertical: UIConstants.smallPadding,
      ),
      padding: const EdgeInsets.all(UIConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          const SizedBox(width: UIConstants.defaultPadding),
          // Content placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: UIConstants.smallPadding),
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de loading para botones
class ButtonLoading extends StatelessWidget {
  final Color? color;
  final double size;

  const ButtonLoading({
    Key? key,
    this.color,
    this.size = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.textOnPrimary,
        ),
      ),
    );
  }
}

// Widget de loading para imágenes
class ImageLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ImageLoading({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.3),
        borderRadius: borderRadius ?? BorderRadius.circular(UIConstants.defaultRadius),
      ),
      child: const Center(
        child: LoadingWidget(
          type: LoadingType.fadingCircle,
          size: 30,
        ),
      ),
    );
  }
}

// Widget de error con botón de reintentar
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: UIConstants.defaultPadding),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget de estado vacío
class EmptyWidget extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;

  const EmptyWidget({
    Key? key,
    required this.message,
    this.actionText,
    this.onAction,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: UIConstants.defaultPadding),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: UIConstants.defaultPadding),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Utilidades para mostrar loading
class LoadingUtils {
  // Mostrar dialog de loading
  static void showLoadingDialog(
    BuildContext context, {
    String? message,
    LoadingType type = LoadingType.circular,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(UIConstants.largePadding),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(UIConstants.defaultRadius),
          ),
          child: LoadingWidget(
            message: message,
            type: type,
            size: 50,
          ),
        ),
      ),
    );
  }

  // Ocultar dialog de loading
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Ejecutar acción con loading
  static Future<T?> withLoading<T>(
    BuildContext context,
    Future<T> Function() action, {
    String? message,
    LoadingType type = LoadingType.circular,
  }) async {
    showLoadingDialog(context, message: message, type: type);
    
    try {
      final result = await action();
      hideLoadingDialog(context);
      return result;
    } catch (e) {
      hideLoadingDialog(context);
      rethrow;
    }
  }
}