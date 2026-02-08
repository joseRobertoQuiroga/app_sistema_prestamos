import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de texto personalizado con validaciones y estilos consistentes
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
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
    this.hint,
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

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        suffixText: suffixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.5),
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
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        filled: true,
        fillColor: enabled
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        counterText: maxLength != null ? null : '',
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
      style: theme.textTheme.bodyLarge?.copyWith(
        color: enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Campo de texto para montos con formato de moneda
class CurrencyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final String currencySymbol;

  const CurrencyTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
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
      hint: hint,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixText: '$currencySymbol ',
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
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const PercentageTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      suffixText: '%',
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
  final String? hint;
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
    this.hint,
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
      hint: hint ?? 'dd/MM/yyyy',
      validator: validator,
      enabled: enabled,
      readOnly: true,
      onTap: enabled ? () => _selectDate(context) : null,
      suffixIcon: const Icon(Icons.calendar_today),
    );
  }
}

/// Campo de texto para teléfonos
class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const PhoneTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
    );
  }
}

/// Campo de texto para documentos (CI)
class DocumentTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const DocumentTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hint,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: TextInputType.number,
      prefixIcon: const Icon(Icons.badge),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
    );
  }
}

/// Campo de texto para búsqueda
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function()? onClear;
  final bool autofocus;

  const SearchTextField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint ?? 'Buscar...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller?.text.isNotEmpty ?? false
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller?.clear();
                  onClear?.call();
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: onChanged,
      autofocus: autofocus,
      style: theme.textTheme.bodyLarge,
    );
  }
}