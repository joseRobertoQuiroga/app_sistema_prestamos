import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/database/database.dart' as db;

/// Servicio para generar archivos Excel
class ExcelService {
  final _dateFormat = DateFormat('dd/MM/yyyy');
  final _currencyFormat = NumberFormat.currency(symbol: 'Bs. ', decimalDigits: 2);

  // =========================================================================
  // EXPORTACIÓN DE DATOS
  // =========================================================================

  /// Exporta clientes a Excel
  Future<String> exportarClientes(List<Cliente> clientes) async {
    final excel = Excel.createExcel();
    final sheet = excel['Clientes'];

    // Encabezados
    final headers = [
      'ID',
      'Nombres',
      'Apellidos',
      'Tipo Documento',
      'Número Documento',
      'Teléfono',
      'Email',
      'Dirección',
      'Referencia',
      'Activo',
      'Fecha Registro',
    ];

    _addHeaders(sheet, headers);

    // Datos
    int rowIndex = 1;
    for (final cliente in clientes) {
      sheet.appendRow([
        IntCellValue(cliente.id ?? 0),
        TextCellValue(cliente.nombres),
        TextCellValue(cliente.apellidos),
        TextCellValue(cliente.tipoDocumento),
        TextCellValue(cliente.numeroDocumento),
        TextCellValue(cliente.telefono),
        TextCellValue(cliente.email ?? ''),
        TextCellValue(cliente.direccion),
        TextCellValue(cliente.referencia ?? ''),
        TextCellValue(cliente.activo ? 'SÍ' : 'NO'),
        TextCellValue(_dateFormat.format(cliente.fechaRegistro)),
      ]);
      rowIndex++;
    }

    // Autoajustar columnas
    _autoFitColumns(sheet, headers.length);

    return await _guardarArchivo(excel, 'Clientes');
  }

  /// Exporta préstamos a Excel
  Future<String> exportarPrestamos(List<Prestamo> prestamos) async {
    final excel = Excel.createExcel();
    final sheet = excel['Prestamos'];

    // Encabezados
    final headers = [
      'Código',
      'Cliente',
      'Caja',
      'Monto Original',
      'Monto Total',
      'Saldo Pendiente',
      'Tasa Interés (%)',
      'Tipo Interés',
      'Plazo (meses)',
      'Cuota Mensual',
      'Fecha Inicio',
      'Fecha Vencimiento',
      'Estado',
      'Fecha Registro',
    ];

    _addHeaders(sheet, headers);

    // Datos
    for (final prestamo in prestamos) {
      sheet.appendRow([
        TextCellValue(prestamo.codigo),
        TextCellValue(prestamo.nombreCliente ?? 'N/A'),
        TextCellValue(prestamo.nombreCaja ?? 'N/A'),
        DoubleCellValue(prestamo.montoOriginal),
        DoubleCellValue(prestamo.montoTotal),
        DoubleCellValue(prestamo.saldoPendiente),
        DoubleCellValue(prestamo.tasaInteres),
        TextCellValue(prestamo.tipoInteres),
        IntCellValue(prestamo.plazoMeses),
        DoubleCellValue(prestamo.cuotaMensual),
        TextCellValue(_dateFormat.format(prestamo.fechaInicio)),
        TextCellValue(_dateFormat.format(prestamo.fechaVencimiento)),
        TextCellValue(prestamo.estado),
        TextCellValue(_dateFormat.format(prestamo.fechaRegistro)),
      ]);
    }

    _autoFitColumns(sheet, headers.length);

    return await _guardarArchivo(excel, 'Prestamos');
  }

  /// Exporta pagos a Excel
  Future<String> exportarPagos(List<Pago> pagos) async {
    final excel = Excel.createExcel();
    final sheet = excel['Pagos'];

    // Encabezados
    final headers = [
      'Código',
      'Préstamo',
      'Cliente',
      'Caja',
      'Monto Pago',
      'Monto Capital',
      'Monto Interés',
      'Monto Mora',
      'Fecha Pago',
      'Método Pago',
      'Observaciones',
      'Fecha Registro',
    ];

    _addHeaders(sheet, headers);

    // Datos
    for (final pago in pagos) {
      sheet.appendRow([
        TextCellValue(pago.codigo),
        TextCellValue(pago.codigoPrestamo ?? 'N/A'),
        TextCellValue(pago.nombreCliente ?? 'N/A'),
        TextCellValue(pago.nombreCaja ?? 'N/A'),
        DoubleCellValue(pago.montoPago),
        DoubleCellValue(pago.montoCapital),
        DoubleCellValue(pago.montoInteres),
        DoubleCellValue(pago.montoMora),
        TextCellValue(_dateFormat.format(pago.fechaPago)),
        TextCellValue(pago.metodoPago),
        TextCellValue(pago.observaciones ?? ''),
        TextCellValue(_dateFormat.format(pago.fechaRegistro)),
      ]);
    }

    _autoFitColumns(sheet, headers.length);

    return await _guardarArchivo(excel, 'Pagos');
  }

  /// Exporta movimientos a Excel
  Future<String> exportarMovimientos(List<Movimiento> movimientos) async {
    final excel = Excel.createExcel();
    final sheet = excel['Movimientos'];

    // Encabezados
    final headers = [
      'Código',
      'Caja',
      'Tipo',
      'Categoría',
      'Monto',
      'Saldo Anterior',
      'Saldo Nuevo',
      'Descripción',
      'Fecha',
      'Fecha Registro',
    ];

    _addHeaders(sheet, headers);

    // Datos
    for (final mov in movimientos) {
      sheet.appendRow([
        TextCellValue(mov.codigo),
        TextCellValue(mov.nombreCaja ?? 'N/A'),
        TextCellValue(mov.tipo),
        TextCellValue(mov.categoria),
        DoubleCellValue(mov.monto),
        DoubleCellValue(mov.saldoAnterior),
        DoubleCellValue(mov.saldoNuevo),
        TextCellValue(mov.descripcion),
        TextCellValue(_dateFormat.format(mov.fecha)),
        TextCellValue(_dateFormat.format(mov.fechaRegistro)),
      ]);
    }

    _autoFitColumns(sheet, headers.length);

    return await _guardarArchivo(excel, 'Movimientos');
  }

  /// Exporta estado de cuenta de cliente
  Future<String> exportarEstadoCuentaCliente(List<dynamic> datos) async {
    final excel = Excel.createExcel();
    final sheet = excel['EstadoCuenta'];

    // Encabezados
    final headers = [
      'Fecha',
      'Concepto',
      'Monto',
      'Saldo',
      'TipoTransaccion',
    ];

    _addHeaders(sheet, headers);

    // Datos
    for (final item in datos) {
      // Adaptar según la estructura final que definamos
      sheet.appendRow([
        TextCellValue(_dateFormat.format(item.fecha)),
        TextCellValue(item.concepto),
        DoubleCellValue(item.monto),
        DoubleCellValue(item.saldo),
        TextCellValue(item.tipo),
      ]);
    }

    _autoFitColumns(sheet, headers.length);
    return await _guardarArchivo(excel, 'EstadoCuenta');
  }

  /// Exporta proyección de cobros
  Future<String> exportarProyeccionCobros(List<dynamic> cuotas) async {
    final excel = Excel.createExcel();
    final sheet = excel['ProyeccionCobros'];

    final headers = [
      'Fecha Vencimiento',
      'Cliente',
      'Préstamo',
      'Cuota #',
      'Monto Cuota',
      'Interés Mora (Est.)',
      'Total a Cobrar',
    ];

    _addHeaders(sheet, headers);

    for (final c in cuotas) {
      sheet.appendRow([
        TextCellValue(_dateFormat.format(c.fechaVencimiento)),
        TextCellValue(c.nombreCliente),
        TextCellValue(c.codigoPrestamo),
        IntCellValue(c.numeroCuota),
        DoubleCellValue(c.montoCuota),
        DoubleCellValue(c.moraEstimada),
        DoubleCellValue(c.totalCobrar),
      ]);
    }

    _autoFitColumns(sheet, headers.length);
    return await _guardarArchivo(excel, 'ProyeccionCobros');
  }

  /// Exporta préstamos cancelados
  Future<String> exportarPrestamosCancelados(List<Prestamo> prestamos) async {
    // Reutilizamos la lógica de préstamos pero con archivo diferente
    final excel = Excel.createExcel();
    final sheet = excel['PrestamosCancelados'];

    final headers = [
      'Código',
      'Cliente',
      'Monto Original',
      'Monto Pagado',
      'Ganancia',
      'Fecha Inicio',
      'Fecha Fin',
      'Estado',
    ];

    _addHeaders(sheet, headers);

    for (final p in prestamos) {
      sheet.appendRow([
        TextCellValue(p.codigo),
        TextCellValue(p.nombreCliente ?? 'N/A'),
        DoubleCellValue(p.montoOriginal),
        DoubleCellValue(p.montoTotal), // Usamos esto como pagado total aprox
        DoubleCellValue(p.montoTotal - p.montoOriginal), // Ganancia aprox
        TextCellValue(_dateFormat.format(p.fechaInicio)),
        TextCellValue(_dateFormat.format(p.fechaVencimiento)), // Fecha fin real
        TextCellValue(p.estado),
      ]);
    }

    _autoFitColumns(sheet, headers.length);
    return await _guardarArchivo(excel, 'PrestamosCancelados');
  }

  /// Exporta rendimiento de cartera
  Future<String> exportarRendimientoCartera(Map<String, double> datos) async {
    final excel = Excel.createExcel();
    final sheet = excel['Rendimiento'];

    final headers = ['Concepto', 'Monto'];
    _addHeaders(sheet, headers);

    datos.forEach((key, value) {
      sheet.appendRow([
        TextCellValue(key),
        DoubleCellValue(value),
      ]);
    });

    _autoFitColumns(sheet, 2);
    return await _guardarArchivo(excel, 'RendimientoCartera');
  }

  // =========================================================================
  // GENERACIÓN DE PLANTILLAS
  // =========================================================================

  /// Genera plantilla de clientes para importación
  Future<String> generarPlantillaClientes() async {
    final excel = Excel.createExcel();
    if (excel.sheets.containsKey('Sheet1')) {
      excel.rename('Sheet1', 'Clientes');
    }
    final sheet = excel['Clientes'];

    // Encabezados (sin ID, se genera automáticamente)
    final headers = [
      'Nombres *',
      'Apellidos *',
      'Tipo Documento *',
      'Número Documento *',
      'Teléfono *',
      'Email',
      'Dirección *',
      'Referencia',
      'Observaciones',
    ];

    _addHeaders(sheet, headers);

    // Fila de ejemplo
    sheet.appendRow([
      TextCellValue('Juan Carlos'),
      TextCellValue('Pérez López'),
      TextCellValue('CI'),
      TextCellValue('1234567'),
      TextCellValue('77123456'),
      TextCellValue('juan.perez@email.com'),
      TextCellValue('Av. Principal #123'),
      TextCellValue('Casa blanca con portón negro'),
      TextCellValue('Cliente preferencial'),
    ]);

    // Fila de instrucciones
    sheet.appendRow([
      TextCellValue('Nombre del cliente'),
      TextCellValue('Apellidos del cliente'),
      TextCellValue('CI, RUC, DNI, etc'),
      TextCellValue('Número sin guiones'),
      TextCellValue('Solo números'),
      TextCellValue('Formato email válido'),
      TextCellValue('Dirección completa'),
      TextCellValue('Punto de referencia'),
      TextCellValue('Notas adicionales'),
    ]);

    _autoFitColumns(sheet, headers.length);

    return await _guardarArchivo(excel, 'Plantilla_Clientes');
  }

  /// Genera plantilla de préstamos para importación
  Future<String> generarPlantillaPrestamos() async {
    final excel = Excel.createExcel();
    if (excel.sheets.containsKey('Sheet1')) {
      excel.rename('Sheet1', 'Prestamos');
    }
    final sheet = excel['Prestamos'];

    // Encabezados
    final headers = [
      'Número Documento Cliente *',
      'Nombre Caja *',
      'Monto Original *',
      'Tasa Interés (%) *',
      'Tipo Interés *',
      'Plazo Meses *',
      'Fecha Inicio *',
      'Observaciones',
    ];

    _addHeaders(sheet, headers);

    // Fila de ejemplo
    sheet.appendRow([
      TextCellValue('1234567'),
      TextCellValue('Caja Principal'),
      DoubleCellValue(10000.00),
      DoubleCellValue(20.0),
      TextCellValue('SIMPLE'),
      IntCellValue(12),
      TextCellValue('01/01/2024'),
      TextCellValue('Préstamo aprobado'),
    ]);

    // Fila de instrucciones
    sheet.appendRow([
      TextCellValue('CI del cliente (debe existir)'),
      TextCellValue('Nombre de la caja (debe existir)'),
      TextCellValue('Monto en bolivianos'),
      TextCellValue('Porcentaje anual (ej: 20)'),
      TextCellValue('SIMPLE o COMPUESTO'),
      TextCellValue('Número de meses (1-120)'),
      TextCellValue('DD/MM/YYYY'),
      TextCellValue('Notas adicionales'),
    ]);

    _autoFitColumns(sheet, headers.length);

    return await _guardarArchivo(excel, 'Plantilla_Prestamos');
  }

  // =========================================================================
  // MÉTODOS DE AYUDA
  // =========================================================================

  /// Agrega encabezados con formato
  void _addHeaders(Sheet sheet, List<String> headers) {
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#1976D2'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
      );
    }
  }

  /// Autoajusta el ancho de las columnas
  void _autoFitColumns(Sheet sheet, int columnCount) {
    for (int i = 0; i < columnCount; i++) {
      sheet.setColumnWidth(i, 20);
    }
  }

  /// Guarda el archivo Excel y retorna la ruta
  Future<String> _guardarArchivo(Excel excel, String nombreBase) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final fileName = '${nombreBase}_$timestamp.xlsx';
    final filePath = '${directory.path}/$fileName';

    final fileBytes = excel.encode();
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!);

    return filePath;
  }
}

// =========================================================================
// CLASES DE AYUDA PARA MAPEO
// =========================================================================

/// Clase auxiliar para representar un cliente en exportación
class Cliente {
  final int? id;
  final String nombres;
  final String apellidos;
  final String tipoDocumento;
  final String numeroDocumento;
  final String telefono;
  final String? email;
  final String direccion;
  final String? referencia;
  final bool activo;
  final DateTime fechaRegistro;

  Cliente({
    this.id,
    required this.nombres,
    required this.apellidos,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.telefono,
    this.email,
    required this.direccion,
    this.referencia,
    required this.activo,
    required this.fechaRegistro,
  });

  factory Cliente.fromDrift(db.Cliente data) {
    return Cliente(
      id: data.id,
      nombres: data.nombres,
      apellidos: data.apellidos,
      tipoDocumento: data.tipoDocumento,
      numeroDocumento: data.numeroDocumento,
      telefono: data.telefono,
      email: data.email,
      direccion: data.direccion,
      referencia: data.referencia,
      activo: data.activo,
      fechaRegistro: data.fechaRegistro,
    );
  }
}

/// Clase auxiliar para representar un préstamo en exportación
class Prestamo {
  final String codigo;
  final String? nombreCliente;
  final String? nombreCaja;
  final double montoOriginal;
  final double montoTotal;
  final double saldoPendiente;
  final double tasaInteres;
  final String tipoInteres;
  final int plazoMeses;
  final double cuotaMensual;
  final DateTime fechaInicio;
  final DateTime fechaVencimiento;
  final String estado;
  final DateTime fechaRegistro;

  Prestamo({
    required this.codigo,
    this.nombreCliente,
    this.nombreCaja,
    required this.montoOriginal,
    required this.montoTotal,
    required this.saldoPendiente,
    required this.tasaInteres,
    required this.tipoInteres,
    required this.plazoMeses,
    required this.cuotaMensual,
    required this.fechaInicio,
    required this.fechaVencimiento,
    required this.estado,
    required this.fechaRegistro,
  });
}

/// Clase auxiliar para representar un pago en exportación
class Pago {
  final String codigo;
  final String? codigoPrestamo;
  final String? nombreCliente;
  final String? nombreCaja;
  final double montoPago;
  final double montoCapital;
  final double montoInteres;
  final double montoMora;
  final DateTime fechaPago;
  final String metodoPago;
  final String? observaciones;
  final DateTime fechaRegistro;

  Pago({
    required this.codigo,
    this.codigoPrestamo,
    this.nombreCliente,
    this.nombreCaja,
    required this.montoPago,
    required this.montoCapital,
    required this.montoInteres,
    required this.montoMora,
    required this.fechaPago,
    required this.metodoPago,
    this.observaciones,
    required this.fechaRegistro,
  });
}

/// Clase auxiliar para representar un movimiento en exportación
class Movimiento {
  final String codigo;
  final String? nombreCaja;
  final String tipo;
  final String categoria;
  final double monto;
  final double saldoAnterior;
  final double saldoNuevo;
  final String descripcion;
  final DateTime fecha;
  final DateTime fechaRegistro;

  Movimiento({
    required this.codigo,
    this.nombreCaja,
    required this.tipo,
    required this.categoria,
    required this.monto,
    required this.saldoAnterior,
    required this.saldoNuevo,
    required this.descripcion,
    required this.fecha,
    required this.fechaRegistro,
  });
}

class ItemEstadoCuenta {
  final DateTime fecha;
  final String concepto;
  final double monto;
  final double saldo;
  final String tipo;

  ItemEstadoCuenta({
    required this.fecha,
    required this.concepto,
    required this.monto,
    required this.saldo,
    required this.tipo,
  });
}

class ItemProyeccion {
  final DateTime fechaVencimiento;
  final String nombreCliente;
  final String codigoPrestamo;
  final int numeroCuota;
  final double montoCuota;
  final double moraEstimada;
  final double totalCobrar;

  ItemProyeccion({
    required this.fechaVencimiento,
    required this.nombreCliente,
    required this.codigoPrestamo,
    required this.numeroCuota,
    required this.montoCuota,
    required this.moraEstimada,
    required this.totalCobrar,
  });
}