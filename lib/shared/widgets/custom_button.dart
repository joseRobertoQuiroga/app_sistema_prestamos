import 'package:flutter/material.dart';

/// Botón primario personalizado
class CustomButton extends StatelessWidget {
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

  const CustomButton({
    super.key,
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
    
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
      elevation: elevation ?? 2,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      minimumSize: isExpanded ? const Size(double.infinity, 48) : const Size(88, 48),
    ).merge(style);

    Widget buttonChild;

    if (isLoading) {
      buttonChild = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? theme.colorScheme.onPrimary,
          ),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: foregroundColor ?? theme.colorScheme.onPrimary,
            ),
          ),
        ],
      );
    } else {
      buttonChild = Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: foregroundColor ?? theme.colorScheme.onPrimary,
        ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: buttonChild,
    );
  }
}

/// Botón secundario (outlined)
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
    
    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: foregroundColor ?? theme.colorScheme.primary,
      side: BorderSide(
        color: borderColor ?? theme.colorScheme.primary,
        width: 1.5,
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      minimumSize: isExpanded ? const Size(double.infinity, 48) : const Size(88, 48),
    );

    Widget buttonChild;

    if (isLoading) {
      buttonChild = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? theme.colorScheme.primary,
          ),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: buttonChild,
    );
  }
}

/// Botón de texto
class TextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;

  const TextButton({
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
    
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: foregroundColor ?? theme.colorScheme.primary,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    Widget buttonChild;

    if (isLoading) {
      buttonChild = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? theme.colorScheme.primary,
          ),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: buttonChild,
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

    if (isOutlined) {
      return SecondaryButton(
        text: text,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        isExpanded: isExpanded,
        borderColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.error,
        padding: padding,
      );
    }

    return CustomButton(
      text: text,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isExpanded: isExpanded,
      backgroundColor: theme.colorScheme.error,
      foregroundColor: theme.colorScheme.onError,
      padding: padding,
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

/// Botón de chip/tag
class ChipButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;

  const ChipButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isSelected = false,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: 18) : null,
      selected: isSelected,
      onSelected: onPressed != null ? (_) => onPressed!() : null,
      backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
      selectedColor: selectedColor ?? theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : (textColor ?? theme.colorScheme.onSurface),
      ),
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

/// Botón de segmento (para grupos de botones)
class SegmentButton<T> extends StatelessWidget {
  final T value;
  final T? selectedValue;
  final String label;
  final IconData? icon;
  final ValueChanged<T>? onChanged;

  const SegmentButton({
    super.key,
    required this.value,
    this.selectedValue,
    required this.label,
    this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == selectedValue;

    return InkWell(
      onTap: onChanged != null ? () => onChanged!(value) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}