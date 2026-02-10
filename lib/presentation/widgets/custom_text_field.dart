import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// Campo de texto profesional con bordes refinados y estados de focus elegantes
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final dynamic prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final String? initialValue;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
    this.inputFormatters,
    this.autofocus = false,
    this.initialValue,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            prefixIcon: prefixIcon != null
                ? (prefixIcon is IconData
                    ? Icon(prefixIcon as IconData, size: 22, color: isDark ? AppTheme.primaryDark : AppTheme.primaryBrand)
                    : prefixIcon as Widget)
                : null,
            suffixIcon: suffixIcon,
            prefixText: prefixText,
            suffixText: suffixText,
            filled: true,
            fillColor: isDark 
                ? theme.cardColor.withOpacity(0.5) 
                : Colors.white,
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
              ),
            ),
          ),
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onTap: onTap,
          onFieldSubmitted: onFieldSubmitted,
          focusNode: focusNode,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
          textCapitalization: textCapitalization,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

/// Campo de texto para montos con formato de moneda
class CurrencyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final String currencySymbol;

  const CurrencyTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.currencySymbol = 'Bs.',
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          currencySymbol,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
    );
  }
}

/// Campo de texto para porcentajes
class PercentageTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const PercentageTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      suffixIcon: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          '%',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
    );
  }
}

/// Campo de texto para fechas con selector
class DateTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(DateTime?)? onDateSelected;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;

  const DateTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.validator,
    this.onDateSelected,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.initialDate,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );

    if (picked != null && controller != null) {
      final formattedDate =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      controller!.text = formattedDate;
      onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hintText: hintText ?? 'dd/MM/yyyy',
      validator: validator,
      enabled: enabled,
      readOnly: true,
      onTap: enabled ? () => _selectDate(context) : null,
      suffixIcon: const Icon(Icons.calendar_month_rounded),
    );
  }
}

/// Campo de texto para búsqueda
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function()? onClear;
  final bool autofocus;

  const SearchTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText ?? 'Buscar...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller?.text.isNotEmpty ?? false
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                },
              )
            : null,
        filled: true,
        fillColor: isDark ? theme.cardColor : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      onChanged: onChanged,
      autofocus: autofocus,
      style: theme.textTheme.bodyLarge,
    );
  }
}
