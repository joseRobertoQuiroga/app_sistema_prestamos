import 'package:flutter/material.dart';
import '../../../../presentation/widgets/app_drawer.dart';

/// Pantalla principal de Ayuda con instructivos y FAQ
class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ayuda y Soporte'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.book),
                text: 'Instructivos',
              ),
              Tab(
                icon: Icon(Icons.help_outline),
                text: 'Preguntas Frecuentes',
              ),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: const TabBarView(
          children: [
            _InstructivosTab(),
            _FAQTab(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB: INSTRUCTIVOS
// ============================================================================

class _InstructivosTab extends StatelessWidget {
  const _InstructivosTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSeccion(
          context,
          titulo: '1. Gestión de Clientes',
          icono: Icons.people,
          color: Colors.blue,
          pasos: [
            'Para agregar un cliente, presione el botón "+" en la pantalla de Clientes',
            'Complete todos los campos obligatorios: nombres, apellidos, tipo de documento (CI), número de documento, teléfono y dirección',
            'El número de CI debe ser único en el sistema',
            'Para editar un cliente, toque la tarjeta del cliente y luego el botón "Editar"',
            'Para eliminar un cliente, deslice la tarjeta hacia la izquierda o presione el botón de menú',
            '⚠️ IMPORTANTE: No se puede eliminar un cliente que tenga préstamos activos o en mora',
          ],
        ),
        const SizedBox(height: 16),
        
        _buildSeccion(
          context,
          titulo: '2. Crear Préstamos',
          icono: Icons.account_balance_wallet,
          color: Colors.green,
          pasos: [
            'Vaya a la pantalla de Préstamos y presione el botón "+"',
            'Seleccione el cliente al que le otorgará el préstamo',
            'Elija la caja desde la cual se desembolsará el dinero',
            'Ingrese el monto del préstamo',
            'Configure la tasa de interés (%) y el tipo (Simple o Compuesto)',
            'Seleccione el plazo en meses',
            'El sistema calculará automáticamente la cuota mensual',
            'Revise la tabla de amortización antes de confirmar',
            'Presione "Crear Préstamo" para finalizar',
          ],
        ),
        const SizedBox(height: 16),
        
        _buildSeccion(
          context,
          titulo: '3. Registrar Pagos',
          icono: Icons.payment,
          color: Colors.orange,
          pasos: [
            'Desde la pantalla de Préstamos, seleccione el préstamo al que registrará el pago',
            'Presione el botón "Registrar Pago"',
            'Ingrese el monto del pago',
            'Elija el método de pago (Efectivo, Transferencia, etc.)',
            'El sistema distribuirá automáticamente el pago entre capital, intereses y mora (si aplica)',
            'Confirme el pago',
            'Puede ver el historial de pagos en la pestaña "Pagos" del préstamo',
          ],
        ),
        const SizedBox(height: 16),
        
        _buildSeccion(
          context,
          titulo: '4. Importar Datos desde Excel',
          icono: Icons.upload_file,
          color: Colors.purple,
          pasos: [
            'Vaya a la pantalla de Reportes → pestaña "Importar"',
            'Descargue primero la plantilla de Excel apropiada (Clientes o Préstamos)',
            'Complete la plantilla con sus datos siguiendo el formato exacto',
            'Formato de fechas: DD/MM/YYYY (ejemplo: 15/03/2024)',
            'El número de CI debe ser único para cada cliente',
            'Para importar préstamos, los clientes deben estar previamente importados/registrados',
            'Las cajas mencionadas deben existir en el sistema',
            'Presione "Seleccionar Archivo" y elija su archivo Excel completado',
            'El sistema mostrará un resumen de éxitos y errores',
            'Si hay errores, presione "Ver Detalles" para ver qué corregir',
          ],
        ),
        const SizedBox(height: 16),
        
        _buildSeccion(
          context,
          titulo: '5. Generar Reportes',
          icono: Icons.assessment,
          color: Colors.indigo,
          pasos: [
            'Vaya a la pantalla de Reportes',
            'Seleccione el período: Hoy, Semana, Mes, Trimestre, Año, o Todo',
            'Elija el formato: PDF o Excel',
            'Seleccione el tipo de reporte que necesita:',
            '  • Cartera: Estado de todos los préstamos activos',
            '  • Mora: Préstamos con pagos vencidos',
            '  • Cajas: Movimientos de dinero en cada caja',
            '  • Pagos: Historial de todos los pagos recibidos',
            'Presione el botón del reporte deseado',
            '✅ Los archivos se guardan en la carpeta "Documentos" de Windows',
            '✅ Haga clic en "Abrir" en el mensaje de éxito para verlo inmediatamente',
            '⚠️ Necesita un lector de PDF para abrir reportes PDF',
          ],
        ),
        const SizedBox(height: 16),
        
        _buildSeccion(
          context,
          titulo: '6. Gestión de Cajas',
          icono: Icons.account_balance,
          color: Colors.teal,
          pasos: [
            'Las cajas representan dónde se guarda el dinero (efectivo, banco, billetera digital)',
            'Para crear una caja, vaya a Cajas → "+" ',
            'Ingrese nombre, tipo y saldo inicial',
            'Los préstamos se desembolsan desde una caja específica',
            'Los pagos ingresan a una caja específica',
            'Puede realizar transferencias entre cajas',
            'Consulte el historial de movimientos en cada caja',
          ],
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Consejo: Siempre revise los reportes periódicamente para mantener control sobre su cartera de préstamos',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeccion(
    BuildContext context, {
    required String titulo,
    required IconData icono,
    required Color color,
    required List<String> pasos,
  }) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: color),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: pasos.map((paso) {
                final esAdvertencia = paso.startsWith('⚠️');
                final esSubpaso = paso.startsWith('  •');
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: 8,
                    left: esSubpaso ? 16 : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!esSubpaso && !esAdvertencia)
                        const Icon(Icons.check_circle, size: 16, color: Colors.green)
                      else if (esAdvertencia)
                        const Icon(Icons.warning, size: 16, color: Colors.orange)
                      else
                        const Icon(Icons.arrow_right, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          paso,
                          style: TextStyle(
                            fontSize: 14,
                            color: esAdvertencia ? Colors.orange.shade900 : Colors.grey.shade700,
                            fontWeight: esAdvertencia ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB: PREGUNTAS FRECUENTES (FAQ)
// ============================================================================

class _FAQTab extends StatelessWidget {
  const _FAQTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFAQItem(
          pregunta: '¿Por qué no puedo eliminar un cliente?',
          respuesta: 'No se puede eliminar un cliente que tenga préstamos activos o en mora. '
              'Esto es para proteger la integridad de los datos. '
              'Primero debe cancelar o finalizar todos los préstamos del cliente antes de poder eliminarlo. '
              'Como alternativa, puede desactivar el cliente en lugar de eliminarlo.',
          icono: Icons.delete_forever,
          color: Colors.red,
        ),
        _buildFAQItem(
          pregunta: '¿Cómo importo datos desde Excel?',
          respuesta: '1. Descargue la plantilla desde Reportes → Importar\n'
              '2. Complete la plantilla sin modificar los encabezados\n'
              '3. Aseg úrese de que las fechas estén en formato DD/MM/YYYY\n'
              '4. Para préstamos, los clientes ya deben estar en el sistema\n'
              '5. Guarde el archivo y selecciónelo desde la aplicación\n'
              '6. Si hay errores, el sistema le mostrará los detalles para que pueda corregirlos',
          icono: Icons.help,
          color: Colors.blue,
        ),
        _buildFAQItem(
          pregunta: '¿Qué significa cada columna en el Excel de importación?',
          respuesta: 'CLIENTES:\n'
              '• Nombres/Apellidos: Nombre completo del cliente\n'
              '• Tipo Documento: CI, RUC, Pasaporte, etc.\n'
              '• Número Documento: Debe ser único (no puede repetirse)\n'
              '• Teléfono: Número de contacto\n'
              '• Email: Opcional\n'
              '• Dirección: Domicilio del cliente\n\n'
              'PRÉSTAMOS:\n'
              '• Código: Identificador único del préstamo\n'
              '• CI Cliente: El CI del cliente (debe existir previamente)\n'
              '• Nombre Caja: Caja desde donde se desembolsa\n'
              '• Monto: Cantidad prestada\n'
              '• Tasa Interés: Porcentaje (ejemplo: 5.5 para 5.5%)\n'
              '• Plazo Meses: Duración del préstamo\n'
              '• Fecha Inicio: Formato DD/MM/YYYY',
          icono: Icons.table_chart,
          color: Colors.purple,
        ),
        _buildFAQItem(
          pregunta: '¿Cómo se calculan los intereses?',
          respuesta: 'Hay dos tipos de interés:\n\n'
              'INTERÉS SIMPLE:\n'
              'Interés = Monto × Tasa × Tiempo\n'
              'Se calcula solo sobre el capital inicial\n\n'
              'INTERÉS COMPUESTO:\n'
              'Monto Final = Monto × (1 + Tasa)^Tiempo\n'
              'El interés se calcula sobre el capital más los intereses anteriores\n\n'
              'La cuota mensual se divide entre capital e intereses según el método de amortización.',
          icono: Icons.calculate,
          color: Colors.green,
        ),
        _buildFAQItem(
          pregunta: '¿Puedo recuperar datos eliminados?',
          respuesta: 'No. Una vez que elimina un registro (cliente, préstamo, pago), no se puede recuperar. '
              'Es importante tener cuidado al eliminar datos.\n\n'
              'RECOMENDACIÓN: En lugar de eliminar clientes, puede desactivarlos. '
              'Esto los oculta de la vista pero mantiene su historial intacto.\n\n'
              'Para proteger sus datos, es importante hacer respaldos periódicos de la base de datos.',
          icono: Icons.restore,
          color: Colors.orange,
        ),
        _buildFAQItem(
          pregunta: '¿Qué formato deben tener las fechas?',
          respuesta: 'Todas las fechas en la aplicación deben estar en formato DD/MM/YYYY\n\n'
              'Ejemplos correctos:\n'
              '• 15/03/2024\n'
              '• 01/12/2023\n'
              '• 25/06/2024\n\n'
              'Ejemplos incorrectos:\n'
              '• 2024-03-15 ❌\n'
              '• 3/15/2024 ❌\n'
              '• 15-03-2024 ❌',
          icono: Icons.calendar_today,
          color: Colors.indigo,
        ),
        _buildFAQItem(
          pregunta: '¿Puedo tener varios clientes con el mismo nombre?',
          respuesta: 'Sí, puede tener varios clientes con el mismo nombre. '
              'Sin embargo, cada cliente debe tener un número de documento (CI) único. '
              'El sistema usa el número de documento como identificador principal para evitar duplicados.',
          icono: Icons.person,
          color: Colors.teal,
        ),
        _buildFAQItem(
          pregunta: '¿Cómo reseteo la base de datos si cometí errores?',
          respuesta: '⚠️ ADVERTENCIA: Esto eliminará TODOS los datos permanentemente.\n\n'
              'Si necesita empezar desde cero:\n'
              '1. Exporte primero los datos que quiera conservar (Reportes → Exportar)\n'
              '2. Cierre completamente la aplicación\n'
              '3. Contacte al desarrollador para obtener instrucciones de reset\n\n'
              'ALTERNATIVA: Elimine manualmente los registros incorrectos uno por uno en lugar de resetear todo.',
          icono: Icons.warning,
          color: Colors.red,
        ),
        _buildFAQItem(
          pregunta: '¿Qué hago si encuentro un error o bug?',
          respuesta: 'Si encuentra un comportamiento inesperado o error:\n\n'
              '1. Anote exactamente qué estaba haciendo cuando ocurrió\n'
              '2. Tome una captura de pantalla si es posible\n'
              '3. Intente reproducir el error para confirmar\n'
              '4. Contacte al soporte técnico con los detalles\n\n'
              'Mientras tanto, puede intentar cerrar y reabrir la aplicación.',
          icono: Icons.bug_report,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildFAQItem({
    required String pregunta,
    required String respuesta,
    required IconData icono,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: color, size: 24),
        ),
        title: Text(
          pregunta,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              respuesta,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
