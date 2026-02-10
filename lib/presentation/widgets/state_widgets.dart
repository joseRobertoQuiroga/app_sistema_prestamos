import 'package:flutter/material.dart';

/// Widget para mostrar estado de carga
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 48,
            height: size ?? 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para mostrar estado de error
class ErrorState extends StatelessWidget {
  final String message;
  final String? details;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const ErrorState({
    super.key,
    required this.message,
    this.details,
    this.icon,
    this.onRetry,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? 'Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar estado vacío
class EmptyWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionButtonText;
  final IconData? actionIcon;

  const EmptyWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionButtonText,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon ?? Icons.add),
                label: Text(actionButtonText ?? 'Agregar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar información
class InfoWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const InfoWidget({
    super.key,
    required this.message,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.info_outline,
            color: iconColor ?? theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar advertencia
class WarningWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const WarningWidget({
    super.key,
    required this.message,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.warning_amber,
            color: Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar éxito
class SuccessWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const SuccessWidget({
    super.key,
    required this.message,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.check_circle_outline,
            color: Colors.green.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget adaptativo que muestra diferentes estados según una condición
class StateWidget<T> extends StatelessWidget {
  final AsyncSnapshot<T> snapshot;
  final Widget Function(T data) builder;
  final String? loadingMessage;
  final String? emptyMessage;
  final String? emptySubtitle;
  final VoidCallback? onEmptyAction;
  final String? emptyActionText;
  final String Function(Object error)? errorMessageBuilder;
  final VoidCallback? onRetry;

  const StateWidget({
    super.key,
    required this.snapshot,
    required this.builder,
    this.loadingMessage,
    this.emptyMessage,
    this.emptySubtitle,
    this.onEmptyAction,
    this.emptyActionText,
    this.errorMessageBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return LoadingWidget(message: loadingMessage);
    }

    if (snapshot.hasError) {
      final errorMessage = errorMessageBuilder != null
          ? errorMessageBuilder!(snapshot.error!)
          : 'Ocurrió un error: ${snapshot.error}';
      
      return ErrorState(
        message: errorMessage,
        onRetry: onRetry,
      );
    }

    if (!snapshot.hasData || (snapshot.data is List && (snapshot.data as List).isEmpty)) {
      return EmptyWidget(
        message: emptyMessage ?? 'No hay datos disponibles',
        subtitle: emptySubtitle,
        onAction: onEmptyAction,
        actionButtonText: emptyActionText,
      );
    }

    return builder(snapshot.data as T);
  }
}

/// Widget para mostrar un mensaje de no resultados en búsqueda
class NoResultsWidget extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClear;

  const NoResultsWidget({
    super.key,
    this.searchQuery,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (searchQuery != null) ...[
              const SizedBox(height: 8),
              Text(
                'para "$searchQuery"',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onClear != null) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar búsqueda'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para skeleton loading (placeholder mientras carga)
class SkeletonLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                theme.colorScheme.surfaceContainerHighest,
                theme.colorScheme.surfaceContainerHigh,
                theme.colorScheme.surfaceContainerHighest,
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
            ),
          ),
        );
      },
    );
  }
}