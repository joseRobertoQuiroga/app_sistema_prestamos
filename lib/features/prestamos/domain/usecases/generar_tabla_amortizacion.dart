import 'dart:math';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prestamo.dart';
import '../entities/cuota.dart';

class GenerarTablaAmortizacion {
  Either<Failure, List<Cuota>> call({
    required int prestamoId,
    required double monto,
    required double tasaInteres,
    required TipoInteres tipoInteres,
    required int plazoMeses,
    required DateTime fechaInicio,
  }) {
    try {
      // Validaciones
      if (monto <= 0) {
        return Left(ValidationFailure('El monto debe ser mayor a 0'));
      }
      if (tasaInteres < 0 || tasaInteres > 100) {
        return Left(ValidationFailure('La tasa de interés debe estar entre 0 y 100'));
      }
      if (plazoMeses <= 0) {
        return Left(ValidationFailure('El plazo debe ser mayor a 0 meses'));
      }

      final cuotas = <Cuota>[];
      
      if (tipoInteres == TipoInteres.simple) {
        cuotas.addAll(_generarAmortizacionInteresSimple(
          prestamoId: prestamoId,
          monto: monto,
          tasaInteres: tasaInteres,
          plazoMeses: plazoMeses,
          fechaInicio: fechaInicio,
        ));
      } else {
        cuotas.addAll(_generarAmortizacionInteresCompuesto(
          prestamoId: prestamoId,
          monto: monto,
          tasaInteres: tasaInteres,
          plazoMeses: plazoMeses,
          fechaInicio: fechaInicio,
        ));
      }

      return Right(cuotas);
    } catch (e) {
      return Left(CalculationFailure('Error al generar tabla de amortización: ${e.toString()}'));
    }
  }

  // Generar tabla con interés simple
  List<Cuota> _generarAmortizacionInteresSimple({
    required int prestamoId,
    required double monto,
    required double tasaInteres,
    required int plazoMeses,
    required DateTime fechaInicio,
  }) {
    // Interés Simple: I = C * r * t
    // Donde: C = Capital, r = tasa mensual, t = tiempo
    final tasaMensual = tasaInteres / 100 / 12;
    final interesTotal = monto * tasaMensual * plazoMeses;
    final montoTotal = monto + interesTotal;
    final cuotaMensual = montoTotal / plazoMeses;

    final cuotas = <Cuota>[];
    double saldoPendiente = montoTotal;

    for (int i = 1; i <= plazoMeses; i++) {
      final fechaVencimiento = DateTime(
        fechaInicio.year,
        fechaInicio.month + i,
        fechaInicio.day,
      );

      // En interés simple, el capital se distribuye equitativamente
      final capital = monto / plazoMeses;
      final interes = interesTotal / plazoMeses;

      saldoPendiente -= cuotaMensual;
      if (saldoPendiente < 0.01) saldoPendiente = 0; // Evitar valores negativos pequeños

      cuotas.add(Cuota(
        prestamoId: prestamoId,
        numeroCuota: i,
        fechaVencimiento: fechaVencimiento,
        montoCuota: cuotaMensual,
        capital: capital,
        interes: interes,
        saldoPendiente: saldoPendiente,
        estado: EstadoCuota.pendiente,
        fechaRegistro: DateTime.now(),
      ));
    }

    return cuotas;
  }

  // Generar tabla con interés compuesto (Sistema Francés)
  List<Cuota> _generarAmortizacionInteresCompuesto({
    required int prestamoId,
    required double monto,
    required double tasaInteres,
    required int plazoMeses,
    required DateTime fechaInicio,
  }) {
    // Sistema Francés: Cuota fija
    // Fórmula: C = P * [r * (1 + r)^n] / [(1 + r)^n - 1]
    final tasaMensual = tasaInteres / 100 / 12;
    
    // Calcular cuota mensual fija
    final cuotaMensual = monto * 
        (tasaMensual * pow(1 + tasaMensual, plazoMeses)) / 
        (pow(1 + tasaMensual, plazoMeses) - 1);

    final cuotas = <Cuota>[];
    double saldoPendiente = monto;

    for (int i = 1; i <= plazoMeses; i++) {
      final fechaVencimiento = DateTime(
        fechaInicio.year,
        fechaInicio.month + i,
        fechaInicio.day,
      );

      // El interés se calcula sobre el saldo pendiente
      final interes = saldoPendiente * tasaMensual;
      final capital = cuotaMensual - interes;

      saldoPendiente -= capital;
      if (saldoPendiente < 0.01) saldoPendiente = 0;

      cuotas.add(Cuota(
        prestamoId: prestamoId,
        numeroCuota: i,
        fechaVencimiento: fechaVencimiento,
        montoCuota: cuotaMensual,
        capital: capital,
        interes: interes,
        saldoPendiente: saldoPendiente,
        estado: EstadoCuota.pendiente,
        fechaRegistro: DateTime.now(),
      ));
    }

    return cuotas;
  }

  // Calcular totales del préstamo
  static Map<String, double> calcularTotales({
    required double monto,
    required double tasaInteres,
    required TipoInteres tipoInteres,
    required int plazoMeses,
  }) {
    if (tipoInteres == TipoInteres.simple) {
      final tasaMensual = tasaInteres / 100 / 12;
      final interesTotal = monto * tasaMensual * plazoMeses;
      final montoTotal = monto + interesTotal;
      final cuotaMensual = montoTotal / plazoMeses;

      return {
        'montoTotal': montoTotal,
        'interesTotal': interesTotal,
        'cuotaMensual': cuotaMensual,
      };
    } else {
      // Interés compuesto
      final tasaMensual = tasaInteres / 100 / 12;
      final cuotaMensual = monto * 
          (tasaMensual * pow(1 + tasaMensual, plazoMeses)) / 
          (pow(1 + tasaMensual, plazoMeses) - 1);
      final montoTotal = cuotaMensual * plazoMeses;
      final interesTotal = montoTotal - monto;

      return {
        'montoTotal': montoTotal,
        'interesTotal': interesTotal,
        'cuotaMensual': cuotaMensual,
      };
    }
  }
}