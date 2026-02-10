import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum ButtonType { primary, secondary, outlined, text, danger }

/// Botón principal modernizado con soporte para gradientes y estados
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final ButtonType type;
  final ButtonStyle? style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.type = ButtonType.primary,
    this.style,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return _PrimaryButton(
          text: text,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
          isExpanded: isExpanded,
          style: style,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation,
          padding: padding,
          borderRadius: borderRadius,
        );
      case ButtonType.secondary:
      case ButtonType.outlined:
        return SecondaryButton(
          text: text,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
          isExpanded: isExpanded,
          foregroundColor: foregroundColor,
          padding: padding,
          borderRadius: borderRadius,
        );
      case ButtonType.text:
        return CustomTextButton(
          text: text,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
          foregroundColor: foregroundColor,
          padding: padding,
        );
      case ButtonType.danger:
        return DangerButton(
          text: text,
          onPressed: onPressed,
          icon: icon,
          isLoading: isLoading,
          isExpanded: isExpanded,
          padding: padding,
        );
    }
  }
}

/// Botón primario con gradiente profesional
class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final ButtonStyle? style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const _PrimaryButton({
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.style,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Si hay un color de fondo manual, usamos ElevatedButton estándar
    // Si no, usamos nuestro gradiente profesional
    if (backgroundColor != null) {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
          minimumSize: isExpanded ? const Size(double.infinity, 52) : const Size(88, 52),
        ).merge(style),
        child: _buildChild(context),
      );
    }

    return Container(
      width: isExpanded ? double.infinity : null,
      height: 52,
      decoration: BoxDecoration(
        gradient: onPressed != null ? AppTheme.primaryGradient : null,
        color: onPressed == null ? theme.disabledColor : null,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow: onPressed != null && !isDark
            ? [
                BoxShadow(
                  color: AppTheme.primaryBrand.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: foregroundColor ?? Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ).merge(style),
        child: _buildChild(context),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            color: foregroundColor ?? Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Botón secundario estilizado
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final Color? borderColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.borderColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? theme.colorScheme.primary,
        side: BorderSide(
          color: borderColor ?? theme.colorScheme.primary.withOpacity(0.5),
          width: 1.5,
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
        minimumSize: isExpanded ? const Size(double.infinity, 52) : const Size(88, 52),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}

/// Botón de texto simple
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.foregroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor ?? theme.colorScheme.primary,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Botón de peligro/destructivo
class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final bool isOutlined;
  final EdgeInsetsGeometry? padding;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.isOutlined = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : theme.colorScheme.error,
        foregroundColor: isOutlined ? theme.colorScheme.error : theme.colorScheme.onError,
        elevation: isOutlined ? 0 : 2,
        side: isOutlined ? BorderSide(color: theme.colorScheme.error) : null,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: isExpanded ? const Size(double.infinity, 52) : const Size(88, 52),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Botón flotante de acción (FAB)
class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool isExtended;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.isExtended = false,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip,
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        elevation: 4,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
      elevation: 4,
      child: Icon(icon),
    );
  }
}

/// Botón de icono
class IconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsetsGeometry? padding;

  const IconButtonWidget({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (backgroundColor != null) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          tooltip: tooltip,
          color: color ?? theme.colorScheme.onPrimaryContainer,
          iconSize: size ?? 24,
          padding: padding ?? const EdgeInsets.all(8),
        ),
      );
    }

    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
      color: color,
      iconSize: size ?? 24,
      padding: padding ?? const EdgeInsets.all(8),
    );
  }
}
