import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../../../clientes/domain/entities/cliente.dart';
import '../../domain/entities/reportes_entities.dart';

/// Servicio para importar datos desde Excel
class ImportacionService {
  
  /// Importa clientes desde un archivo Excel
  Future<ResultadoImportacion> importarClientes(
    String rutaArchivo,
    Future<bool> Function(String ci) verificarCiExiste,
    Future<int> Function(Cliente) guardarCliente,
  ) async {
    final inicio = DateTime.now();
    final errores = <ErrorImportacion>[];
    int exitosos = 0;
    int fallidos = 0;

    try {
      final bytes = File(rutaArchivo).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      
      // Obtener la primera hoja
      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]!.rows;

      if (rows.isEmpty) {
        return ResultadoImportacion(
          totalRegistros: 0,
          registrosExitosos: 0,
          registrosConError: 0,
          errores: [
            const ErrorImportacion(
              fila: 0,
              campo: 'general',
              mensaje: 'El archivo está vacío',
            ),
          ],
          fechaProceso: inicio,
        );
      }

      // Mapeo de columnas según CLIENTES_PRUEBA.xlsx:
      // A: Nombres, B: Apellidos, C: Tipo Documento, D: Número Documento
      // E: Teléfono, F: Email, G: Dirección, H: Referencia, I: Observaciones
      
      // Saltar encabezado (fila 0)
      for (var i = 1; i < rows.length; i++) {
        final fila = rows[i];
        final numeroFila = i + 1;

        try {
          // Extraer datos
          final nombres = _getCellValue(fila, 0);
          final apellidos = _getCellValue(fila, 1);
          final tipoDoc = _getCellValue(fila, 2);
          final ci = _getCellValue(fila, 3);
          final telefono = _getCellValue(fila, 4);
          final email = _getCellValue(fila, 5);
          final direccion = _getCellValue(fila, 6);
          final referencia = _getCellValue(fila, 7);
          final observaciones = _getCellValue(fila, 8);

          // Validaciones
          final erroresFila = <ErrorImportacion>[];

          if (nombres.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Nombres',
              mensaje: 'Los nombres son obligatorios',
            ));
          } else if (nombres.length < 2) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Nombres',
              mensaje: 'Los nombres deben tener al menos 2 caracteres',
              valorProblematico: nombres,
            ));
          }

          if (apellidos.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Apellidos',
              mensaje: 'Los apellidos son obligatorios',
            ));
          }

          if (ci.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Número Documento',
              mensaje: 'El número de documento es obligatorio',
            ));
          } else {
            final existe = await verificarCiExiste(ci);
            if (existe) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'Número Documento',
                mensaje: 'El documento $ci ya existe en el sistema',
                valorProblematico: ci,
              ));
            }
          }

          if (email.isNotEmpty && !_esEmailValido(email)) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Email',
              mensaje: 'El formato del email no es válido',
              valorProblematico: email,
            ));
          }

          if (telefono.isNotEmpty && !_esTelefonoValido(telefono)) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Teléfono',
              mensaje: 'El teléfono solo debe contener números',
              valorProblematico: telefono,
            ));
          }

          if (direccion.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Dirección',
              mensaje: 'La dirección es obligatoria',
            ));
          }

          if (erroresFila.isNotEmpty) {
            errores.addAll(erroresFila);
            fallidos++;
            continue;
          }

          // Crear cliente
          final cliente = Cliente(
            nombre: '$nombres $apellidos',
            ci: ci,
            telefono: telefono.isEmpty ? null : telefono,
            email: email.isEmpty ? null : email,
            direccion: direccion,
            ciudad: null,
            departamento: null,
            referencia: referencia.isEmpty ? null : referencia,
            fechaRegistro: DateTime.now(),
            activo: true,
            notas: observaciones.isEmpty ? null : observaciones,
          );

          await guardarCliente(cliente);
          exitosos++;

        } catch (e) {
          errores.add(ErrorImportacion(
            fila: numeroFila,
            campo: 'general',
            mensaje: 'Error al procesar la fila: $e',
          ));
          fallidos++;
        }
      }

    } catch (e) {
      return ResultadoImportacion(
        totalRegistros: 0,
        registrosExitosos: 0,
        registrosConError: 1,
        errores: [
          ErrorImportacion(
            fila: 0,
            campo: 'archivo',
            mensaje: 'Error al leer el archivo: $e',
          ),
        ],
        fechaProceso: inicio,
      );
    }

    return ResultadoImportacion(
      totalRegistros: exitosos + fallidos,
      registrosExitosos: exitosos,
      registrosConError: fallidos,
      errores: errores,
      fechaProceso: inicio,
    );
  }

  /// Importa préstamos desde un archivo Excel
  Future<ResultadoImportacion> importarPrestamos(
    String rutaArchivo,
    Future<int?> Function(String ci) obtenerClientePorCi,
    Future<int?> Function(String nombreCaja) obtenerCajaPorNombre,
    Future<int> Function(PrestamoImportacion) guardarPrestamo,
  ) async {
    final inicio = DateTime.now();
    final errores = <ErrorImportacion>[];
    int exitosos = 0;
    int fallidos = 0;

    try {
      final bytes = File(rutaArchivo).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      
      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]!.rows;

      if (rows.isEmpty) {
        return ResultadoImportacion(
          totalRegistros: 0,
          registrosExitosos: 0,
          registrosConError: 0,
          errores: [
            const ErrorImportacion(
              fila: 0,
              campo: 'general',
              mensaje: 'El archivo está vacío',
            ),
          ],
          fechaProceso: inicio,
        );
      }

      // Mapeo de columnas según PRESTAMOS_PRUEBA.xlsx:
      // A: Número Documento Cliente, B: Nombre Caja, C: Monto Original
      // D: Tasa Interés (%), E: Tipo Interés, F: Plazo Meses
      // G: Fecha Inicio, H: Observaciones
      
      // Saltar encabezado (fila 0) y fila de instrucciones (fila 1)
      for (var i = 2; i < rows.length; i++) {
        final fila = rows[i];
        final numeroFila = i + 1;

        try {
          // Extraer datos
          final ciCliente = _getCellValue(fila, 0);
          final nombreCaja = _getCellValue(fila, 1);
          final montoStr = _getCellValue(fila, 2);
          final tasaStr = _getCellValue(fila, 3);
          final tipoInteres = _getCellValue(fila, 4).toUpperCase();
          final plazoStr = _getCellValue(fila, 5);
          final fechaInicioStr = _getCellValue(fila, 6);
          final observaciones = _getCellValue(fila, 7);

          // Validaciones
          final erroresFila = <ErrorImportacion>[];

          // Validar cliente
          int? clienteId;
          if (ciCliente.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Número Documento Cliente',
              mensaje: 'El documento del cliente es obligatorio',
            ));
          } else {
            clienteId = await obtenerClientePorCi(ciCliente);
            if (clienteId == null) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'Número Documento Cliente',
                mensaje: 'Cliente con documento $ciCliente no existe. Importe clientes primero.',
                valorProblematico: ciCliente,
              ));
            }
          }

          // Validar caja
          int? cajaId;
          if (nombreCaja.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Nombre Caja',
              mensaje: 'El nombre de la caja es obligatorio',
            ));
          } else {
            cajaId = await obtenerCajaPorNombre(nombreCaja);
            if (cajaId == null) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'Nombre Caja',
                mensaje: 'La caja "$nombreCaja" no existe en el sistema',
                valorProblematico: nombreCaja,
              ));
            }
          }

          // Validar monto
          double? monto;
          if (montoStr.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Monto Original',
              mensaje: 'El monto es obligatorio',
            ));
          } else {
            monto = double.tryParse(montoStr);
            if (monto == null || monto <= 0) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'Monto Original',
                mensaje: 'El monto debe ser un número positivo',
                valorProblematico: montoStr,
              ));
            }
          }

          // Validar tasa
          double? tasa;
          if (tasaStr.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Tasa Interés',
              mensaje: 'La tasa de interés es obligatoria',
            ));
          } else {
            tasa = double.tryParse(tasaStr);
            if (tasa == null || tasa < 0 || tasa > 200) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'Tasa Interés',
                mensaje: 'La tasa debe estar entre 0 y 200% anual',
                valorProblematico: tasaStr,
              ));
            }
          }

          // Validar plazo
          int? plazo;
          if (plazoStr.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Plazo Meses',
              mensaje: 'El plazo es obligatorio',
            ));
          } else {
            plazo = int.tryParse(plazoStr);
            if (plazo == null || plazo < 1 || plazo > 120) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'Plazo Meses',
                mensaje: 'El plazo debe estar entre 1 y 120 meses',
                valorProblematico: plazoStr,
              ));
            }
          }

          // Validar tipo de interés
          if (tipoInteres != 'SIMPLE' && tipoInteres != 'COMPUESTO' && tipoInteres != 'WILSON') {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Tipo Interés',
              mensaje: 'El tipo debe ser SIMPLE, COMPUESTO o WILSON',
              valorProblematico: tipoInteres,
            ));
          }

          // Validar fecha
          DateTime? fechaInicio;
          if (fechaInicioStr.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Fecha Inicio',
              mensaje: 'La fecha de inicio es obligatoria',
            ));
          } else {
            fechaInicio = _parsearFecha(fechaInicioStr);
            if (fechaInicio == null) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'Fecha Inicio',
                mensaje: 'Formato de fecha inválido. Use DD/MM/YYYY',
                valorProblematico: fechaInicioStr,
              ));
            }
          }

          // Si hay errores, no guardar
          if (erroresFila.isNotEmpty) {
            errores.addAll(erroresFila);
            fallidos++;
            continue;
          }

          // Crear préstamo para importación
          final prestamo = PrestamoImportacion(
            clienteId: clienteId!,
            cajaId: cajaId!,
            montoOriginal: monto!,
            tasaInteres: tasa!,
            tipoInteres: tipoInteres,
            plazoMeses: plazo!,
            fechaInicio: fechaInicio!,
            observaciones: observaciones.isEmpty ? null : observaciones,
          );

          await guardarPrestamo(prestamo);
          exitosos++;

        } catch (e) {
          errores.add(ErrorImportacion(
            fila: numeroFila,
            campo: 'general',
            mensaje: 'Error al procesar la fila: $e',
          ));
          fallidos++;
        }
      }

    } catch (e) {
      return ResultadoImportacion(
        totalRegistros: 0,
        registrosExitosos: 0,
        registrosConError: 1,
        errores: [
          ErrorImportacion(
            fila: 0,
            campo: 'archivo',
            mensaje: 'Error al leer el archivo: $e',
          ),
        ],
        fechaProceso: inicio,
      );
    }

    return ResultadoImportacion(
      totalRegistros: exitosos + fallidos,
      registrosExitosos: exitosos,
      registrosConError: fallidos,
      errores: errores,
      fechaProceso: inicio,
    );
  }

  /// Importa un préstamo Wilson con su historial de pagos desde un Excel de dos hojas
  Future<ResultadoImportacionWilson> importarWilsonCompleto(
    String rutaArchivo,
    Future<int?> Function(String ci) obtenerClientePorCi,
    Future<int?> Function(String nombreCaja) obtenerCajaPorNombre,
  ) async {
    final inicio = DateTime.now();
    final errores = <ErrorImportacion>[];

    try {
      final bytes = File(rutaArchivo).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      if (!excel.tables.containsKey('DATOS PRESTAMO')) {
        throw Exception('No se encontró la hoja "DATOS PRESTAMO"');
      }

      final loanSheet = excel.tables['DATOS PRESTAMO']!;
      final historySheet = excel.tables['HISTORIAL PAGOS'];

      if (loanSheet.rows.length < 2) {
        throw Exception('La hoja de datos del préstamo está vacía');
      }

      // 1. Procesar datos del préstamo (asumimos una sola fila de datos por archivo por ahora, o procesamos el primero)
      final row = loanSheet.rows[1];
      final ci = _getCellValue(row, 0);
      final caja = _getCellValue(row, 1);
      final monto = double.tryParse(_getCellValue(row, 2));
      final tasa = double.tryParse(_getCellValue(row, 3));
      final plazo = int.tryParse(_getCellValue(row, 4));
      final fecha = _parsearFecha(_getCellValue(row, 5));
      final observaciones = _getCellValue(row, 6);

      // Validaciones básicas
      if (ci.isEmpty || caja.isEmpty || monto == null || tasa == null || plazo == null || fecha == null) {
        throw Exception('Datos del préstamo incompletos o inválidos en la fila 2');
      }

      final clienteId = await obtenerClientePorCi(ci);
      if (clienteId == null) throw Exception('El cliente con CI $ci no existe');

      final cajaId = await obtenerCajaPorNombre(caja);
      if (cajaId == null) throw Exception('La caja "$caja" no existe');

      final prestamoDesc = PrestamoImportacion(
        clienteId: clienteId,
        cajaId: cajaId,
        montoOriginal: monto,
        tasaInteres: tasa,
        tipoInteres: 'WILSON',
        plazoMeses: plazo,
        fechaInicio: fecha,
        observaciones: observaciones,
      );

      // 2. Procesar historial de pagos
      final pagos = <PagoImportacion>[];
      if (historySheet != null && historySheet.rows.length > 1) {
        for (var i = 1; i < historySheet.rows.length; i++) {
          final pRow = historySheet.rows[i];
          final pMonto = double.tryParse(_getCellValue(pRow, 1));
          final pFecha = _parsearFecha(_getCellValue(pRow, 2));
          final pMetodo = _getCellValue(pRow, 3);
          final pEsAbono = _getCellValue(pRow, 4).toUpperCase() == 'SÍ';
          final pObs = _getCellValue(pRow, 5);

          if (pMonto != null && pFecha != null) {
            pagos.add(PagoImportacion(
              monto: pMonto,
              fecha: pFecha,
              metodo: pMetodo.isEmpty ? 'EFECTIVO' : pMetodo,
              esAbonoCapital: pEsAbono,
              observaciones: pObs,
            ));
          } else if (_getCellValue(pRow, 1).isNotEmpty) {
            errores.add(ErrorImportacion(
              fila: i + 1,
              campo: 'Historial Pagos',
              mensaje: 'Monto o fecha inválidos',
              valorProblematico: 'Monto: ${_getCellValue(pRow, 1)}, Fecha: ${_getCellValue(pRow, 2)}',
            ));
          }
        }
      }

      // Ordenar pagos por fecha para asegurar aplicación correcta
      pagos.sort((a, b) => a.fecha.compareTo(b.fecha));

      return ResultadoImportacionWilson(
        prestamo: prestamoDesc,
        pagos: pagos,
        errores: errores,
        fechaProceso: inicio,
      );

    } catch (e) {
      return ResultadoImportacionWilson(
        prestamo: null,
        pagos: [],
        errores: [ErrorImportacion(fila: 0, campo: 'general', mensaje: e.toString())],
        fechaProceso: inicio,
      );
    }
  }

  // =========================================================================
  // MÉTODOS AUXILIARES
  // =========================================================================
  
  String _getCellValue(List<Data?> row, int index) {
    if (index >= row.length || row[index] == null) return '';
    final value = row[index]!.value;
    if (value == null) return '';
    return value.toString().trim();
  }

  bool _esEmailValido(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  bool _esTelefonoValido(String telefono) {
    final cleaned = telefono.replaceAll(RegExp(r'[\s-]'), '');
    final regex = RegExp(r'^\d{7,15}$');
    return regex.hasMatch(cleaned);
  }

  DateTime? _parsearFecha(String fecha) {
    try {
      // Formato esperado: DD/MM/YYYY
      final parts = fecha.split('/');
      if (parts.length != 3) return null;

      final dia = int.parse(parts[0]);
      final mes = int.parse(parts[1]);
      final anio = int.parse(parts[2]);

      return DateTime(anio, mes, dia);
    } catch (e) {
      return null;
    }
  }
}

// =========================================================================
// CLASE AUXILIAR PARA IMPORTACIÓN DE PRÉSTAMOS
// =========================================================================

/// Datos de préstamo extraídos del Excel para crear el préstamo completo
class PrestamoImportacion {
  final int clienteId;
  final int cajaId;
  final double montoOriginal;
  final double tasaInteres;
  final String tipoInteres;
  final int plazoMeses;
  final DateTime fechaInicio;
  final String? observaciones;

  PrestamoImportacion({
    required this.clienteId,
    required this.cajaId,
    required this.montoOriginal,
    required this.tasaInteres,
    required this.tipoInteres,
    required this.plazoMeses,
    required this.fechaInicio,
    this.observaciones,
  });
}

/// Resultado de parsing para Wilson Completo
class ResultadoImportacionWilson {
  final PrestamoImportacion? prestamo;
  final List<PagoImportacion> pagos;
  final List<ErrorImportacion> errores;
  final DateTime fechaProceso;

  ResultadoImportacionWilson({
    this.prestamo,
    required this.pagos,
    required this.errores,
    required this.fechaProceso,
  });
}

/// Datos de pago individual para importación
class PagoImportacion {
  final double monto;
  final DateTime fecha;
  final String metodo;
  final bool esAbonoCapital;
  final String? observaciones;

  PagoImportacion({
    required this.monto,
    required this.fecha,
    required this.metodo,
    required this.esAbonoCapital,
    this.observaciones,
  });
}