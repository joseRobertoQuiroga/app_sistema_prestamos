import 'package:intl/intl.dart';
import '../config/constants/app_constants.dart';

/// Utilidades para formatear valores
class Formatters {
  // Formateadores de fecha
  static final DateFormat _dateFormatter = DateFormat(AppConstants.dateFormat);
  static final DateFormat _dateTimeFormatter = DateFormat(AppConstants.dateTimeFormat);
  
  // Formateador de moneda
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: AppConstants.currencyLocale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  // Formateador de números
  static final NumberFormat _numberFormatter = NumberFormat('#,##0.##', 'es_BO');
  
  // Formateador de porcentajes
  static final NumberFormat _percentFormatter = NumberFormat.percentPattern('es_BO');

  /// Formatea una fecha a string
  /// 
  /// Ejemplo: `2024-02-04` -> `04/02/2024`
  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return _dateFormatter.format(date);
  }

  /// Formatea una fecha y hora a string
  /// 
  /// Ejemplo: `2024-02-04 14:30` -> `04/02/2024 14:30`
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return _dateTimeFormatter.format(dateTime);
  }

  /// Parsea un string a fecha
  /// 
  /// Ejemplo: `04/02/2024` -> `DateTime(2024, 2, 4)`
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _dateFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Formatea un monto a moneda
  /// 
  /// Ejemplo: `1234.56` -> `Bs. 1.234,56`
  static String formatCurrency(double? amount) {
    if (amount == null) return '${AppConstants.currencySymbol} 0,00';
    return _currencyFormatter.format(amount);
  }

  /// Parsea un string de moneda a double
  /// 
  /// Ejemplo: `Bs. 1.234,56` -> `1234.56`
  static double? parseCurrency(String? currencyString) {
    if (currencyString == null || currencyString.isEmpty) return null;
    
    try {
      // Remover símbolo de moneda y espacios
      String cleaned = currencyString
          .replaceAll(AppConstants.currencySymbol, '')
          .replaceAll(' ', '')
          .replaceAll('.', '') // Remover separadores de miles
          .replaceAll(',', '.'); // Convertir separador decimal
      
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Formatea un número con separadores de miles
  /// 
  /// Ejemplo: `1234.56` -> `1.234,56`
  static String formatNumber(double? number, {int? decimalDigits}) {
    if (number == null) return '0';
    
    if (decimalDigits != null) {
      final formatter = NumberFormat('#,##0.${'0' * decimalDigits}', 'es_BO');
      return formatter.format(number);
    }
    
    return _numberFormatter.format(number);
  }

  /// Formatea un porcentaje
  /// 
  /// Ejemplo: `0.1234` -> `12,34%`
  static String formatPercent(double? value, {bool includeSymbol = true}) {
    if (value == null) return includeSymbol ? '0%' : '0';
    
    if (includeSymbol) {
      return _percentFormatter.format(value / 100);
    }
    
    return formatNumber(value, decimalDigits: 2);
  }

  /// Formatea un número de teléfono
  /// 
  /// Ejemplo: `70123456` -> `70-12-34-56` (Bolivia)
  static String formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '-';
    
    // Remover caracteres no numéricos
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Formatear según longitud
    if (cleaned.length == 8) {
      // Formato: XX-XX-XX-XX
      return '${cleaned.substring(0, 2)}-${cleaned.substring(2, 4)}-${cleaned.substring(4, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 7) {
      // Formato: XXX-XXXX
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3)}';
    }
    
    return cleaned;
  }

  /// Capitaliza la primera letra de un string
  /// 
  /// Ejemplo: `hola mundo` -> `Hola mundo`
  static String capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitaliza cada palabra de un string
  /// 
  /// Ejemplo: `hola mundo` -> `Hola Mundo`
  static String capitalizeWords(String? text) {
    if (text == null || text.isEmpty) return '';
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formatea un documento de identidad (CI)
  /// 
  /// Ejemplo: `12345678` -> `12.345.678`
  static String formatDocument(String? document) {
    if (document == null || document.isEmpty) return '-';
    
    // Remover caracteres no numéricos
    String cleaned = document.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Agregar puntos cada 3 dígitos desde la derecha
    if (cleaned.length <= 3) return cleaned;
    
    String formatted = '';
    int count = 0;
    
    for (int i = cleaned.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = '.$formatted';
      }
      formatted = cleaned[i] + formatted;
      count++;
    }
    
    return formatted;
  }

  /// Formatea un número ordinal
  /// 
  /// Ejemplo: `1` -> `1°`, `2` -> `2°`
  static String formatOrdinal(int? number) {
    if (number == null) return '-';
    return '$number°';
  }

  /// Formatea una duración en días a texto legible
  /// 
  /// Ejemplo: `45` -> `1 mes y 15 días`
  static String formatDuration(int? days) {
    if (days == null || days == 0) return '0 días';
    
    if (days < 30) {
      return '$days ${days == 1 ? 'día' : 'días'}';
    }
    
    int months = days ~/ 30;
    int remainingDays = days % 30;
    
    String result = '$months ${months == 1 ? 'mes' : 'meses'}';
    
    if (remainingDays > 0) {
      result += ' y $remainingDays ${remainingDays == 1 ? 'día' : 'días'}';
    }
    
    return result;
  }

  /// Formatea bytes a tamaño legible
  /// 
  /// Ejemplo: `1536` -> `1.5 KB`
  static String formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(size >= 10 ? 0 : 1)} ${suffixes[i]}';
  }

  /// Formatea un rango de fechas
  /// 
  /// Ejemplo: `01/02/2024 - 28/02/2024`
  static String formatDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return '-';
    if (start == null) return 'Hasta ${formatDate(end)}';
    if (end == null) return 'Desde ${formatDate(start)}';
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  /// Calcula y formatea días desde una fecha
  /// 
  /// Ejemplo: `Hace 5 días`
  static String formatDaysAgo(DateTime? date) {
    if (date == null) return '-';
    
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Ayer';
    if (difference < 7) return 'Hace $difference días';
    if (difference < 30) {
      final weeks = (difference / 7).floor();
      return 'Hace $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    }
    if (difference < 365) {
      final months = (difference / 30).floor();
      return 'Hace $months ${months == 1 ? 'mes' : 'meses'}';
    }
    
    final years = (difference / 365).floor();
    return 'Hace $years ${years == 1 ? 'año' : 'años'}';
  }

  /// Formatea estado de préstamo con color
  static String formatEstadoPrestamo(String? estado) {
    if (estado == null) return '-';
    
    switch (estado.toUpperCase()) {
      case 'ACTIVO':
        return 'Activo';
      case 'PAGADO':
        return 'Pagado';
      case 'VENCIDO':
        return 'Vencido';
      case 'CANCELADO':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  /// Trunca un texto largo
  /// 
  /// Ejemplo: `Este es un texto muy largo...` -> `Este es un te...`
  static String truncate(String? text, int maxLength, {String suffix = '...'}) {
    if (text == null || text.isEmpty) return '';
    if (text.length <= maxLength) return text;
    
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
}