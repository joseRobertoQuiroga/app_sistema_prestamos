import 'dart:io';
import 'package:excel/excel.dart';
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
          if (tipoInteres != 'SIMPLE' && tipoInteres != 'COMPUESTO') {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Tipo Interés',
              mensaje: 'El tipo debe ser SIMPLE o COMPUESTO',
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