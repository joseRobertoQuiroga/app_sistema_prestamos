class AppConstants {
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^[0-9]+$';
  static const String numberPattern = r'^[0-9]+$';
  
  static const int minTelefonoLength = 7;
  static const int maxTelefonoLength = 15;
  
  static const int minNombreLength = 3;
  static const int maxNombreLength = 100;
  
  static const int minDireccionLength = 5;
  static const int maxDireccionLength = 200;
  
  static const int minPlazoMeses = 1;
  static const int maxPlazoMeses = 120;
  
  static const double minMontosPrestamo = 50.0;
  static const double maxMontosPrestamo = 1000000.0;
  
  static const double minTasaInteres = 0.1;
  static const double maxTasaInteres = 100.0;
  
  // Formatos de fecha y moneda
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String currencyLocale = 'es_BO';
  static const String currencySymbol = 'Bs.';
}
