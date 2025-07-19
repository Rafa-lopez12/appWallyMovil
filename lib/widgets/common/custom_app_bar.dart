import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/colors.dart';
import '../../utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.bottom,
    this.systemOverlayStyle,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: actions,
      leading: _buildLeading(context),
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.textOnPrimary,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: bottom,
      systemOverlayStyle: systemOverlayStyle ?? SystemUiOverlayStyle.light,
      titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: foregroundColor ?? AppColors.textOnPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    
    if (showBackButton && Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }
    
    return null;
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}

// AppBar específicas para diferentes secciones
class WallyAppBars {
  // AppBar principal (Home)
  static PreferredSizeWidget home({
    required BuildContext context,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sports_soccer,
            color: AppColors.textOnPrimary,
            size: UIConstants.iconSize,
          ),
          const SizedBox(width: UIConstants.smallPadding),
          Text(
            AppConfig.appName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: actions ?? [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Implementar notificaciones
          },
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () {
            // TODO: Navegar a perfil
          },
        ),
      ],
      showBackButton: false,
    );
  }

  // AppBar para secciones internas
  static PreferredSizeWidget section({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      title: title,
      actions: actions,
      onBackPressed: onBackPressed,
    );
  }

  // AppBar para formularios
  static PreferredSizeWidget form({
    required String title,
    VoidCallback? onSave,
    VoidCallback? onCancel,
    bool showSave = false,
  }) {
    List<Widget> actions = [];
    
    if (showSave && onSave != null) {
      actions.add(
        TextButton(
          onPressed: onSave,
          child: const Text(
            'Guardar',
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return CustomAppBar(
      title: title,
      actions: actions.isNotEmpty ? actions : null,
      onBackPressed: onCancel,
    );
  }

  // AppBar para detalles
  static PreferredSizeWidget detail({
    required String title,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onShare,
  }) {
    List<Widget> actions = [];

    if (onShare != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: onShare,
        ),
      );
    }

    if (onEdit != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
        ),
      );
    }

    if (onDelete != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      );
    }

    return CustomAppBar(
      title: title,
      actions: actions.isNotEmpty ? actions : null,
    );
  }

  // AppBar con búsqueda
  static PreferredSizeWidget search({
    required String title,
    TextEditingController? searchController,
    void Function(String)? onSearchChanged,
    VoidCallback? onSearchSubmitted,
    String? searchHint,
  }) {
    return CustomAppBar(
      titleWidget: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        onSubmitted: onSearchSubmitted != null ? (_) => onSearchSubmitted() : null,
        style: const TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: searchHint ?? 'Buscar...',
          hintStyle: TextStyle(
            color: AppColors.textOnPrimary.withOpacity(0.7),
            fontSize: 16,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textOnPrimary.withOpacity(0.7),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            searchController?.clear();
            onSearchChanged?.call('');
          },
        ),
      ],
    );
  }

  // AppBar transparente (para pantallas con imagen de fondo)
  static PreferredSizeWidget transparent({
    String? title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      title: title,
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
      onBackPressed: onBackPressed,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  // AppBar con gradiente
  static PreferredSizeWidget gradient({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    Gradient? gradient,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.primaryGradient,
        ),
        child: CustomAppBar(
          title: title,
          actions: actions,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onBackPressed: onBackPressed,
        ),
      ),
    );
  }

  // AppBar con pestañas
  static PreferredSizeWidget withTabs({
    required String title,
    required List<Tab> tabs,
    TabController? tabController,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      title: title,
      actions: actions,
      bottom: TabBar(
        controller: tabController,
        tabs: tabs,
        indicatorColor: AppColors.textOnPrimary,
        labelColor: AppColors.textOnPrimary,
        unselectedLabelColor: AppColors.textOnPrimary.withOpacity(0.7),
        indicatorWeight: 3,
      ),
    );
  }
}