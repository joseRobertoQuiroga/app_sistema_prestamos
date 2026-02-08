import 'package:flutter/material.dart';
import '../../domain/entities/prestamo.dart';
import '../../domain/entities/cuota.dart';
import '../../../../config/theme/app_theme.dart';

/// Widget reutilizable para mostrar badges de estado
/// Soporta estados de Préstamo y Cuota
class EstadoBadge extends StatelessWidget {
  final String estado;
  final EstadoTipo tipo;
  final bool compact;
  final double fontSize;

  const EstadoBadge({
    super.key,
    required this.estado,
    this.tipo = EstadoTipo.prestamo,
    this.compact = false,
    this.fontSize = 12,
  });

  // Constructor para préstamos
  factory EstadoBadge.prestamo(
    EstadoPrestamo estado, {
    bool compact = false,
    double fontSize = 12,
  }) {
    return EstadoBadge(
      estado: estado.toStorageString(),
      tipo: EstadoTipo.prestamo,
      compact: compact,
      fontSize: fontSize,
    );
  }

  // Constructor para cuotas
  factory EstadoBadge.cuota(
    EstadoCuota estado, {
    bool compact = false,
    double fontSize = 12,
  }) {
    return EstadoBadge(
      estado: estado.toStorageString(),
      tipo: EstadoTipo.cuota,
      compact: compact,
      fontSize: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getEstadoConfig();

    if (compact) {
      return _buildCompactBadge(config);
    }

    return _buildFullBadge(config);
  }

  Widget _buildFullBadge(_EstadoConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: fontSize + 2, color: config.color),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBadge(_EstadoConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color, width: 1),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontSize: fontSize - 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  _EstadoConfig _getEstadoConfig() {
    if (tipo == EstadoTipo.prestamo) {
      return _getPrestamoConfig();
    } else {
      return _getCuotaConfig();
    }
  }

  _EstadoConfig _getPrestamoConfig() {
    switch (estado.toUpperCase()) {
      case 'ACTIVO':
        return _EstadoConfig(
          color: AppTheme.activoColor,
          label: 'Activo',
          icon: Icons.check_circle,
        );
      case 'PAGADO':
        return _EstadoConfig(
          color: AppTheme.pagadoColor,
          label: 'Pagado',
          icon: Icons.verified,
        );
      case 'MORA':
        return _EstadoConfig(
          color: AppTheme.moraColor,
          label: 'En Mora',
          icon: Icons.warning,
        );
      case 'CANCELADO':
        return _EstadoConfig(
          color: AppTheme.canceladoColor,
          label: 'Cancelado',
          icon: Icons.cancel,
        );
      default:
        return _EstadoConfig(
          color: Colors.grey,
          label: estado,
          icon: Icons.help,
        );
    }
  }

  _EstadoConfig _getCuotaConfig() {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return _EstadoConfig(
          color: AppTheme.warningColor,
          label: 'Pendiente',
          icon: Icons.schedule,
        );
      case 'PAGADA':
        return _EstadoConfig(
          color: AppTheme.successColor,
          label: 'Pagada',
          icon: Icons.check_circle,
        );
      case 'MORA':
        return _EstadoConfig(
          color: AppTheme.moraColor,
          label: 'Mora',
          icon: Icons.warning_amber,
        );
      case 'VENCIDA':
        return _EstadoConfig(
          color: AppTheme.errorColor,
          label: 'Vencida',
          icon: Icons.error,
        );
      default:
        return _EstadoConfig(
          color: Colors.grey,
          label: estado,
          icon: Icons.help,
        );
    }
  }
}

enum EstadoTipo {
  prestamo,
  cuota,
}

class _EstadoConfig {
  final Color color;
  final String label;
  final IconData icon;

  _EstadoConfig({
    required this.color,
    required this.label,
    required this.icon,
  });
}

/// Widget para mostrar múltiples badges en fila
class EstadoBadgeRow extends StatelessWidget {
  final List<Widget> badges;
  final MainAxisAlignment alignment;
  final double spacing;

  const EstadoBadgeRow({
    super.key,
    required this.badges,
    this.alignment = MainAxisAlignment.start,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: spacing,
      runSpacing: spacing,
      children: badges,
    );
  }
}

/// Extension para facilitar el uso
extension EstadoPrestamoExtension on EstadoPrestamo {
  Widget toBadge({bool compact = false, double fontSize = 12}) {
    return EstadoBadge.prestamo(
      this,
      compact: compact,
      fontSize: fontSize,
    );
  }
}

extension EstadoCuotaExtension on EstadoCuota {
  Widget toBadge({bool compact = false, double fontSize = 12}) {
    return EstadoBadge.cuota(
      this,
      compact: compact,
      fontSize: fontSize,
    );
  }
}