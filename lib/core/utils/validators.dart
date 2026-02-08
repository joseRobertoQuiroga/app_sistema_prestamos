import '../config/constants/app_constants.dart';

/// Utilidades para validar campos de formularios
class Validators {
  /// Valida que un campo no esté vacío
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  /// Valida un email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    final emailRegex = RegExp(AppConstants.emailPattern);
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un email válido';
    }

    return null;
  }

  /// Valida un número de teléfono
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }

    // Remover caracteres no numéricos para validar
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length < AppConstants.minTelefonoLength ||
        cleaned.length > AppConstants.maxTelefonoLength) {
      return 'El teléfono debe tener entre ${AppConstants.minTelefonoLength} y ${AppConstants.maxTelefonoLength} dígitos';
    }

    final phoneRegex = RegExp(AppConstants.phonePattern);
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Ingrese un teléfono válido';
    }

    return null;
  }

  /// Valida que un teléfono sea opcional pero válido si se proporciona
  static String? phoneOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Es opcional
    }
    return phone(value);
  }

  /// Valida un nombre (persona, empresa, etc.)
  static String? name(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'El nombre'} es requerido';
    }

    if (value.trim().length < AppConstants.minNombreLength) {
      return '${fieldName ?? 'El nombre'} debe tener al menos ${AppConstants.minNombreLength} caracteres';
    }

    if (value.trim().length > AppConstants.maxNombreLength) {
      return '${fieldName ?? 'El nombre'} no puede exceder ${AppConstants.maxNombreLength} caracteres';
    }

    // Validar que solo contenga letras, espacios y algunos caracteres especiales
    final nameRegex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\.'-]+$");
    if (!nameRegex.hasMatch(value)) {
      return '${fieldName ?? 'El nombre'} contiene caracteres no válidos';
    }

    return null;
  }

  /// Valida una dirección
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La dirección es requerida';
    }

    if (value.trim().length < AppConstants.minDireccionLength) {
      return 'La dirección debe tener al menos ${AppConstants.minDireccionLength} caracteres';
    }

    if (value.trim().length > AppConstants.maxDireccionLength) {
      return 'La dirección no puede exceder ${AppConstants.maxDireccionLength} caracteres';
    }

    return null;
  }

  /// Valida que una dirección sea opcional pero válida si se proporciona
  static String? addressOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return address(value);
  }

  /// Valida un documento de identidad (CI)
  static String? document(String? value) {
    if (value == null || value.isEmpty) {
      return 'El documento es requerido';
    }

    // Remover caracteres no numéricos
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleaned.length < 5 || cleaned.length > 15) {
      return 'El documento debe tener entre 5 y 15 dígitos';
    }

    final numberRegex = RegExp(AppConstants.numberPattern);
    if (!numberRegex.hasMatch(cleaned)) {
      return 'El documento solo debe contener números';
    }

    return null;
  }

  /// Valida que un documento sea opcional pero válido si se proporciona
  static String? documentOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return document(value);
  }

  /// Valida un monto monetario
  static String? amount(String? value, {
    double? min,
    double? max,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'El monto'} es requerido';
    }

    // Remover separadores de miles y convertir coma decimal a punto
    final cleaned = value
        .replaceAll(RegExp(r'[^\d,.-]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final amount = double.tryParse(cleaned);

    if (amount == null) {
      return 'Ingrese un monto válido';
    }

    if (amount <= 0) {
      return '${fieldName ?? 'El monto'} debe ser mayor a 0';
    }

    final minAmount = min ?? AppConstants.minMontosPrestamo;
    final maxAmount = max ?? AppConstants.maxMontosPrestamo;

    if (amount < minAmount) {
      return '${fieldName ?? 'El monto'} debe ser al menos $minAmount';
    }

    if (amount > maxAmount) {
      return '${fieldName ?? 'El monto'} no puede exceder $maxAmount';
    }

    return null;
  }

  /// Valida una fecha
  static String? date(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'La fecha'} es requerida';
    }

    try {
      // Intentar parsear la fecha
      final parts = value.split('/');
      if (parts.length != 3) {
        return 'Formato de fecha inválido. Use dd/MM/yyyy';
      }

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final date = DateTime(year, month, day);

      // Validar que sea una fecha válida
      if (date.day != day || date.month != month || date.year != year) {
        return 'Fecha inválida';
      }

      return null;
    } catch (e) {
      return 'Formato de fecha inválido. Use dd/MM/yyyy';
    }
  }

  /// Valida que una fecha no sea futura
  static String? dateNotFuture(String? value, {String? fieldName}) {
    final basicValidation = date(value, fieldName: fieldName);
    if (basicValidation != null) return basicValidation;

    try {
      final parts = value!.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);

      if (date.isAfter(DateTime.now())) {
        return '${fieldName ?? 'La fecha'} no puede ser futura';
      }

      return null;
    } catch (e) {
      return 'Error al validar la fecha';
    }
  }

  /// Valida que una fecha no sea pasada
  static String? dateNotPast(String? value, {String? fieldName}) {
    final basicValidation = date(value, fieldName: fieldName);
    if (basicValidation != null) return basicValidation;

    try {
      final parts = value!.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final date = DateTime(year, month, day);

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      if (date.isBefore(todayDate)) {
        return '${fieldName ?? 'La fecha'} no puede ser pasada';
      }

      return null;
    } catch (e) {
      return 'Error al validar la fecha';
    }
  }

  /// Valida una tasa de interés
  static String? interestRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La tasa de interés es requerida';
    }

    final cleaned = value.replaceAll(',', '.');
    final rate = double.tryParse(cleaned);

    if (rate == null) {
      return 'Ingrese una tasa válida';
    }

    if (rate < AppConstants.minTasaInteres) {
      return 'La tasa debe ser al menos ${AppConstants.minTasaInteres}%';
    }

    if (rate > AppConstants.maxTasaInteres) {
      return 'La tasa no puede exceder ${AppConstants.maxTasaInteres}%';
    }

    return null;
  }

  /// Valida un plazo en meses
  static String? term(String? value) {
    if (value == null || value.isEmpty) {
      return 'El plazo es requerido';
    }

    final term = int.tryParse(value);

    if (term == null) {
      return 'Ingrese un plazo válido';
    }

    if (term < AppConstants.minPlazoMeses) {
      return 'El plazo debe ser al menos ${AppConstants.minPlazoMeses} mes';
    }

    if (term > AppConstants.maxPlazoMeses) {
      return 'El plazo no puede exceder ${AppConstants.maxPlazoMeses} meses';
    }

    return null;
  }

  /// Valida un número entero positivo
  static String? positiveInteger(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    final number = int.tryParse(value);

    if (number == null) {
      return 'Ingrese un número válido';
    }

    if (number <= 0) {
      return '${fieldName ?? 'El valor'} debe ser mayor a 0';
    }

    return null;
  }

  /// Valida un número decimal positivo
  static String? positiveDecimal(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    final cleaned = value.replaceAll(',', '.');
    final number = double.tryParse(cleaned);

    if (number == null) {
      return 'Ingrese un número válido';
    }

    if (number <= 0) {
      return '${fieldName ?? 'El valor'} debe ser mayor a 0';
    }

    return null;
  }

  /// Valida longitud mínima
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (value.length < min) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $min caracteres';
    }

    return null;
  }

  /// Valida longitud máxima
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null) return null;

    if (value.length > max) {
      return '${fieldName ?? 'Este campo'} no puede exceder $max caracteres';
    }

    return null;
  }

  /// Valida que dos valores sean iguales (útil para confirmar contraseñas)
  static String? match(String? value, String? matchValue, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (value != matchValue) {
      return '${fieldName ?? 'Los valores'} no coinciden';
    }

    return null;
  }

  /// Combina múltiples validadores
  static String? combine(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }

  /// Valida un porcentaje (0-100)
  static String? percentage(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'El porcentaje'} es requerido';
    }

    final cleaned = value.replaceAll(',', '.');
    final percentage = double.tryParse(cleaned);

    if (percentage == null) {
      return 'Ingrese un porcentaje válido';
    }

    if (percentage < 0 || percentage > 100) {
      return '${fieldName ?? 'El porcentaje'} debe estar entre 0 y 100';
    }

    return null;
  }

  /// Valida solo letras
  static String? onlyLetters(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    final lettersRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!lettersRegex.hasMatch(value)) {
      return '${fieldName ?? 'Este campo'} solo debe contener letras';
    }

    return null;
  }

  /// Valida solo números
  static String? onlyNumbers(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    final numbersRegex = RegExp(AppConstants.numberPattern);
    if (!numbersRegex.hasMatch(value)) {
      return '${fieldName ?? 'Este campo'} solo debe contener números';
    }

    return null;
  }
}