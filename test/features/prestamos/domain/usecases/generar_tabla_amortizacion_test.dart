import 'package:flutter_test/flutter_test.dart';
import 'package:sistema_prestamos/features/prestamos/domain/entities/prestamo.dart';
import 'package:sistema_prestamos/features/prestamos/domain/usecases/generar_tabla_amortizacion.dart';

void main() {
  late GenerarTablaAmortizacion usecase;

  setUp(() {
    usecase = GenerarTablaAmortizacion();
  });

  group('GenerarTablaAmortizacion - Cálculos de Totales', () {
    test('Interés Simple: 1000 al 12% anual por 12 meses', () {
      final result = GenerarTablaAmortizacion.calcularTotales(
        monto: 1000,
        tasaInteres: 12,
        tipoInteres: TipoInteres.simple,
        plazoMeses: 12,
      );

      // Interés = 1000 * (0.12 / 12) * 12 = 120
      expect(result['montoTotal'], closeTo(1120.0, 0.01));
      expect(result['interesTotal'], closeTo(120.0, 0.01));
      expect(result['cuotaMensual'], closeTo(93.33, 0.01));
    });

    test('Interés Compuesto (Francés): 1000 al 12% anual por 12 meses', () {
      final result = GenerarTablaAmortizacion.calcularTotales(
        monto: 1000,
        tasaInteres: 12,
        tipoInteres: TipoInteres.compuesto,
        plazoMeses: 12,
      );

      // Cuota = 1000 * [0.01 * (1.01)^12] / [(1.01)^12 - 1] ≈ 88.85
      expect(result['cuotaMensual'], closeTo(88.84, 0.01));
      expect(result['montoTotal'], closeTo(1066.18, 0.01));
    });

    test('Interés Wilson: 5000 al 5% mensual por 12 meses', () {
      final result = GenerarTablaAmortizacion.calcularTotales(
        monto: 5000,
        tasaInteres: 5,
        tipoInteres: TipoInteres.wilson,
        plazoMeses: 12,
      );

      // Interés Total = 5000 * 0.05 * 12 = 3000
      // Monto Total = 5000 + 3000 = 8000
      // Cuota Inicial = (5000/12) + (5000 * 0.05) = 416.66 + 250 = 666.66
      expect(result['interesTotal'], closeTo(3000.0, 0.01));
      expect(result['montoTotal'], closeTo(8000.0, 0.01));
      expect(result['cuotaMensual'], closeTo(666.66, 0.01));
    });
  });

  group('GenerarTablaAmortizacion - Tabla de Cuotas', () {
    test('Debe generar la cantidad correcta de cuotas para Interés Simple', () {
      final result = usecase(
        prestamoId: 1,
        monto: 1200,
        tasaInteres: 12,
        tipoInteres: TipoInteres.simple,
        plazoMeses: 6,
        fechaInicio: DateTime(2024, 1, 1),
      );

      result.fold(
        (failure) => fail('No debería fallar'),
        (cuotas) {
          expect(cuotas.length, 6);
          expect(cuotas.first.numeroCuota, 1);
          expect(cuotas.last.numeroCuota, 6);
          expect(cuotas.last.saldoPendiente, closeTo(0, 0.01));
        },
      );
    });
  });
}

