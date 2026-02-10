import 'dart:io';
import 'package:excel/excel.dart';
import '../../../clientes/domain/entities/cliente.dart';
import '../../../prestamos/domain/entities/prestamo.dart';
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

      // Saltar encabezado
      for (var i = 1; i < rows.length; i++) {
        final fila = rows[i];
        final numeroFila = i + 1;

        try {
          // Extraer datos
          final nombre = _getCellValue(fila, 0);
          final ci = _getCellValue(fila, 1);
          final telefono = _getCellValue(fila, 2);
          final email = _getCellValue(fila, 3);
          final direccion = _getCellValue(fila, 4);
          final ciudad = _getCellValue(fila, 5);
          final departamento = _getCellValue(fila, 6);
          final referencia = _getCellValue(fila, 7);
          final notas = _getCellValue(fila, 8);

          // Validaciones
          final erroresFila = <ErrorImportacion>[];

          // Nombre obligatorio
          if (nombre.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Nombre',
              mensaje: 'El nombre es obligatorio',
            ));
          } else if (nombre.length < 3) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Nombre',
              mensaje: 'El nombre debe tener al menos 3 caracteres',
              valorProblematico: nombre,
            ));
          }

          // CI obligatorio y único
          if (ci.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'CI',
              mensaje: 'El CI es obligatorio',
            ));
          } else {
            final existe = await verificarCiExiste(ci);
            if (existe) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'CI',
                mensaje: 'El CI ya existe en el sistema',
                valorProblematico: ci,
              ));
            }
          }

          // Email formato válido
          if (email.isNotEmpty && !_esEmailValido(email)) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Email',
              mensaje: 'El formato del email no es válido',
              valorProblematico: email,
            ));
          }

          // Teléfono solo números
          if (telefono.isNotEmpty && !_esTelefonoValido(telefono)) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Teléfono',
              mensaje: 'El teléfono solo debe contener números',
              valorProblematico: telefono,
            ));
          }

          // Si hay errores, no guardar
          if (erroresFila.isNotEmpty) {
            errores.addAll(erroresFila);
            fallidos++;
            continue;
          }

          // Crear cliente
          final cliente = Cliente(
            nombre: nombre,
            ci: ci,
            telefono: telefono.isEmpty ? null : telefono,
            email: email.isEmpty ? null : email,
            direccion: direccion.isEmpty ? null : direccion,
            ciudad: ciudad.isEmpty ? null : ciudad,
            departamento: departamento.isEmpty ? null : departamento,
            referencia: referencia.isEmpty ? null : referencia,
            fechaRegistro: DateTime.now(),
            activo: true,
            notas: notas.isEmpty ? null : notas,
          );

          // Guardar
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
    Future<int> Function(Prestamo) guardarPrestamo,
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

      // Saltar encabezado
      for (var i = 1; i < rows.length; i++) {
        final fila = rows[i];
        final numeroFila = i + 1;

        try {
          // Extraer datos
          final ciCliente = _getCellValue(fila, 0);
          final montoStr = _getCellValue(fila, 1);
          final tasaStr = _getCellValue(fila, 2);
          final plazoStr = _getCellValue(fila, 3);
          final tipoInteres = _getCellValue(fila, 4).toUpperCase();
          final fechaInicioStr = _getCellValue(fila, 5);
          final observaciones = _getCellValue(fila, 6);

          // Validaciones
          final erroresFila = <ErrorImportacion>[];

          // Verificar que el cliente existe
          if (ciCliente.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'CI Cliente',
              mensaje: 'El CI del cliente es obligatorio',
            ));
          } else {
            final clienteId = await obtenerClientePorCi(ciCliente);
            if (clienteId == null) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'CI Cliente',
                mensaje: 'El cliente con CI $ciCliente no existe en el sistema',
                valorProblematico: ciCliente,
              ));
            }
          }

          // Validar monto
          double? monto;
          if (montoStr.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Monto',
              mensaje: 'El monto es obligatorio',
            ));
          } else {
            monto = double.tryParse(montoStr);
            if (monto == null || monto <= 0) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'Monto',
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
            if (tasa == null || tasa < 0 || tasa > 100) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'Tasa Interés',
                mensaje: 'La tasa debe estar entre 0 y 100',
                valorProblematico: tasaStr,
              ));
            }
          }

          // Validar plazo
          int? plazo;
          if (plazoStr.isEmpty) {
            erroresFila.add(ErrorImportacion(
              fila: numeroFila,
              campo: 'Plazo',
              mensaje: 'El plazo es obligatorio',
            ));
          } else {
            plazo = int.tryParse(plazoStr);
            if (plazo == null || plazo < 1 || plazo > 120) {
              erroresFila.add(ErrorImportacion(
                fila: numeroFila,
                campo: 'Plazo',
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

          // Obtener ID del cliente
          final clienteId = await obtenerClientePorCi(ciCliente);
          
          // TODO: Crear préstamo completo con generación de código, 
          // cálculo de tabla de amortización, etc.
          // Por ahora solo estructura básica
          
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

  // Métodos auxiliares
  
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
    final regex = RegExp(r'^\d{7,15}$');
    return regex.hasMatch(telefono.replaceAll(RegExp(r'[\s-]'), ''));
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