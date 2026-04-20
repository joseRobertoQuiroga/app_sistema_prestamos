import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_prestamos/features/reportes/domain/entities/reportes_entities.dart';

void main() {
  group('ConfiguracionReporte - getRango', () {
    final ahora = DateTime.now();
    
    test('Debe calcular el rango correcto para Último Mes (Histórico)', () {
      const config = ConfiguracionReporte(
        tipo: TipoReporte.carteraCompleta,
        formato: FormatoReporte.pdf,
        periodo: PeriodoReporte.ultimoMes,
      );

      final rango = config.getRango();
      
      // Debe empezar hace un mes aproximadamente
      final unMesAtras = DateTime(ahora.year, ahora.month - 1, ahora.day);
      expect(rango.start.year, unMesAtras.year);
      expect(rango.start.month, unMesAtras.month);
      expect(rango.start.day, unMesAtras.day);
      expect(rango.end.isAfter(rango.start), true);
    });

    test('Debe calcular el rango correcto para Proyección de Cobros (Hacia adelante)', () {
      const config = ConfiguracionReporte(
        tipo: TipoReporte.proyeccionCobros,
        formato: FormatoReporte.pdf,
        periodo: PeriodoReporte.ultimoMes,
      );

      final rango = config.getRango();
      
      // Debe empezar hoy
      expect(rango.start.year, ahora.year);
      expect(rango.start.month, ahora.month);
      expect(rango.start.day, ahora.day);
      
      // Debe terminar en un mes
      final enUnMes = DateTime(ahora.year, ahora.month + 1, ahora.day);
      expect(rango.end.year, enUnMes.year);
      expect(rango.end.month, enUnMes.month);
      expect(rango.end.day, enUnMes.day);
    });

    test('Debe usar fechas personalizadas si el período es Personalizado', () {
      final inicio = DateTime(2025, 1, 1);
      final fin = DateTime(2025, 1, 31);
      
      final config = ConfiguracionReporte(
        tipo: TipoReporte.carteraCompleta,
        formato: FormatoReporte.pdf,
        periodo: PeriodoReporte.personalizado,
        fechaInicio: inicio,
        fechaFin: fin,
      );

      final rango = config.getRango();
      
      expect(rango.start, inicio);
      expect(rango.end, fin);
    });
  });
}
