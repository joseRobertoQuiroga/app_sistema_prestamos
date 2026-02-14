import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../presentation/widgets/app_drawer.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/caja_provider.dart';

/// Pantalla de Movimientos Generales del sistema
class MovimientosGeneralesScreen extends ConsumerStatefulWidget {
  const MovimientosGeneralesScreen({super.key});

  @override
  ConsumerState<MovimientosGeneralesScreen> createState() => _MovimientosGeneralesScreenState();
}

class _MovimientosGeneralesScreenState extends ConsumerState<MovimientosGeneralesScreen> {
  DateTime _fechaInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fechaFin = DateTime.now();
  int? _cajaSeleccionada;
  String _tipoSeleccionado = 'TODOS'; // TODOS, INGRESO, EGRESO, TRANSFERENCIA

  @override
  Widget build(BuildContext context) {
    final movimientosAsync = ref.watch(movimientosGeneralesProvider);
    final cajasAsync = ref.watch(cajasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos Generales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Resumen de filtros activos
          _buildFiltrosResumen(),

          const Divider(height: 1),

          // Lista de movimientos
          Expanded(
            child: movimientosAsync.when(
              data: (movimientos) {
                // Aplicar filtros
                var movimientosFiltrados = movimientos.where((m) {
                  // Filtro por fecha
                  final enRango = m.fecha.isAfter(_fechaInicio.subtract(const Duration(days: 1))) &&
                      m.fecha.isBefore(_fechaFin.add(const Duration(days: 1)));
                  if (!enRango) return false;

                  // Filtro por caja
                  if (_cajaSeleccionada != null && m.cajaId != _cajaSeleccionada) {
                    return false;
                  }

                  // Filtro por tipo
                  if (_tipoSeleccionado != 'TODOS') {
                    // Para transferencias, buscar categoria TRANSFERENCIA
                    if (_tipoSeleccionado == 'TRANSFERENCIA') {
                      return m.categoria == 'TRANSFERENCIA';
                    } else {
                      return m.tipo == _tipoSeleccionado;
                    }
                  }

                  return true;
                }).toList();

                // Ordenar por fecha descendente
                movimientosFiltrados.sort((a, b) => b.fecha.compareTo(a.fecha));

                if (movimientosFiltrados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay movimientos con estos filtros',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpiar filtros'),
                          onPressed: () {
                            setState(() {
                              _fechaInicio = DateTime.now().subtract(const Duration(days: 30));
                              _fechaFin = DateTime.now();
                              _cajaSeleccionada = null;
                              _tipoSeleccionado = 'TODOS';
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }

                // Calcular totales
                final totalIngresos = movimientosFiltrados
                    .where((m) => m.tipo == 'INGRESO')
                    .fold<double>(0, (sum, m) => sum + m.monto);
                final totalEgresos = movimientosFiltrados
                    .where((m) => m.tipo == 'EGRESO')
                    .fold<double>(0, (sum, m) => sum + m.monto);

                return Column(
                  children: [
                    // Tarjeta de estadísticas
                    _buildEstadisticas(
                      totalIngresos: totalIngresos,
                      totalEgresos: totalEgresos,
                      cantidad: movimientosFiltrados.length,
                    ),

                    const Divider(height: 1),

                    // Lista
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: movimientosFiltrados.length,
                        itemBuilder: (context, index) {
                          final movimiento = movimientosFiltrados[index];
                          return cajasAsync.when(
                            data: (cajas) {
                              if (cajas.isEmpty) {
                                return _buildMovimientoCard(movimiento, 'Sin Caja');
                              }
                              try {
                                final caja = cajas.firstWhere(
                                  (c) => c.id == movimiento.cajaId,
                                );
                                return _buildMovimientoCard(movimiento, caja.nombre);
                              } catch (e) {
                                // Si no se encuentra, usar 'Sin Caja'
                                return _buildMovimientoCard(movimiento, 'Sin Caja');
                              }
                            },
                            loading: () => _buildMovimientoCard(movimiento, 'Cargando...'),
                            error: (_, __) => _buildMovimientoCard(movimiento, 'N/A'),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error al cargar movimientos: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosResumen() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${DateFormat('dd/MM/yy').format(_fechaInicio)} - ${DateFormat('dd/MM/yy').format(_fechaFin)}'
              '${_cajaSeleccionada != null ? ' • Caja específica' : ''}'
              ' • ${_tipoSeleccionado == 'TODOS' ? 'Todos' : _tipoSeleccionado}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () => _mostrarFiltros(context),
            child: const Text('Cambiar', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas({
    required double totalIngresos,
    required double totalEgresos,
    required int cantidad,
  }) {
    final saldo = totalIngresos - totalEgresos;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: _buildEstadisticaCard(
              'Ingresos',
              Formatters.formatCurrency(totalIngresos),
              Colors.green,
              Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildEstadisticaCard(
              'Egresos',
              Formatters.formatCurrency(totalEgresos),
              Colors.red,
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildEstadisticaCard(
              'Balance',
              Formatters.formatCurrency(saldo),
              saldo >= 0 ? Colors.blue : Colors.orange,
              Icons.account_balance,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticaCard(String label, String valor, Color color, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientoCard(dynamic movimiento, String nombreCaja) {
    final esIngreso = movimiento.tipo == 'INGRESO';
    final color = esIngreso ? Colors.green : Colors.red;
    final icono = esIngreso ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icono, color: color, size: 20),
        ),
        title: Text(
          movimiento.descripcion,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$nombreCaja • ${movimiento.categoria}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(movimiento.fecha),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              Formatters.formatCurrency(movimiento.monto),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
            if (movimiento.referencia != null)
              Text(
                movimiento.referencia!,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Future<void> _mostrarFiltros(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final cajasAsync = ref.watch(cajasProvider);

            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtros',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Rango de fechas
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Fecha inicio'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaInicio)),
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: _fechaInicio,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (fecha != null) {
                        setModalState(() => _fechaInicio = fecha);
                        setState(() => _fechaInicio = fecha);
                      }
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Fecha fin'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_fechaFin)),
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: _fechaFin,
                        firstDate: _fechaInicio,
                        lastDate: DateTime.now(),
                      );
                      if (fecha != null) {
                        setModalState(() => _fechaFin = fecha);
                        setState(() => _fechaFin = fecha);
                      }
                    },
                  ),

                  const Divider(),

                  // Tipo de movimiento
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Tipo de movimiento'),
                    subtitle: Text(_tipoSeleccionado),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Todos'),
                        selected: _tipoSeleccionado == 'TODOS',
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => _tipoSeleccionado = 'TODOS');
                            setState(() => _tipoSeleccionado = 'TODOS');
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Ingresos'),
                        selected: _tipoSeleccionado == 'INGRESO',
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => _tipoSeleccionado = 'INGRESO');
                            setState(() => _tipoSeleccionado = 'INGRESO');
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Egresos'),
                        selected: _tipoSeleccionado == 'EGRESO',
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => _tipoSeleccionado = 'EGRESO');
                            setState(() => _tipoSeleccionado = 'EGRESO');
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Transferencias'),
                        selected: _tipoSeleccionado == 'TRANSFERENCIA',
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => _tipoSeleccionado = 'TRANSFERENCIA');
                            setState(() => _tipoSeleccionado = 'TRANSFERENCIA');
                          }
                        },
                      ),
                    ],
                  ),

                  const Divider(),

                  // Caja
                  cajasAsync.when(
                    data: (cajas) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.account_balance_wallet),
                            title: const Text('Caja'),
                            subtitle: Text(_cajaSeleccionada == null
                                ? 'Todas las cajas'
                                : () {
                                    try {
                                      return cajas.firstWhere((c) => c.id == _cajaSeleccionada).nombre;
                                    } catch (_) {
                                      return 'Caja no encontrada';
                                    }
                                  }()),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('Todas'),
                                selected: _cajaSeleccionada == null,
                                onSelected: (selected) {
                                  if (selected) {
                                    setModalState(() => _cajaSeleccionada = null);
                                    setState(() => _cajaSeleccionada = null);
                                  }
                                },
                              ),
                              ...cajas.map((caja) {
                                return ChoiceChip(
                                  label: Text(caja.nombre),
                                  selected: _cajaSeleccionada == caja.id,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setModalState(() => _cajaSeleccionada = caja.id);
                                      setState(() => _cajaSeleccionada = caja.id);
                                    }
                                  },
                                );
                              }),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error al cargar cajas'),
                  ),

                  const SizedBox(height: 16),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _fechaInicio = DateTime.now().subtract(const Duration(days: 30));
                              _fechaFin = DateTime.now();
                              _cajaSeleccionada = null;
                              _tipoSeleccionado = 'TODOS';
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Limpiar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
