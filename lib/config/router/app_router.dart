import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/clientes/presentation/screens/clientes_list_screen.dart';
import '../../features/clientes/presentation/screens/cliente_form_screen.dart';
import '../../features/clientes/presentation/screens/cliente_detail_screen.dart';
import '../../features/prestamos/presentation/screens/prestamos_list_screen.dart';
import '../../features/prestamos/presentation/screens/prestamo_form_screen.dart';
import '../../features/prestamos/presentation/screens/prestamo_detail_screen.dart';
import '../../features/caja/presentation/screens/cajas_list_screen.dart';
import '../../features/caja/presentation/screens/caja_form_screen.dart';
import '../../features/caja/presentation/screens/caja_detail_screen.dart';
import '../../features/caja/presentation/screens/registrar_ingreso_screen.dart';
import '../../features/caja/presentation/screens/registrar_egreso_screen.dart';
import '../../features/caja/presentation/screens/transferencia_screen.dart';
import '../../features/pagos/presentation/screens/registrar_pago_screen.dart';
import '../../features/pagos/presentation/screens/pagos_list_screen.dart'; // ✅ NUEVO
import '../../features/reportes/presentation/screens/reportes_main_screen.dart';
import '../../features/ayuda/presentation/screens/ayuda_screen.dart';
import '../../presentation/widgets/app_drawer.dart';

class AppRouter {
  static const String dashboard = '/';
  static const String clientes = '/clientes';
  static const String clienteDetalle = '/clientes/:id';
  static const String clienteForm = '/clientes/form';
  static const String prestamos = '/prestamos';
  static const String prestamoDetalle = '/prestamos/:id';
  static const String prestamoForm = '/prestamos/form';
  static const String pagos = '/pagos';
  static const String pagoForm = '/pagos/form';
  static const String cajas = '/cajas';
  static const String cajaDetalle = '/cajas/:id';
  static const String cajaForm = '/cajas/form';
  static const String cajaIngreso = '/cajas/ingreso';
  static const String cajaEgreso = '/cajas/egreso';
  static const String transferencia = '/transferencias';
  static const String movimientos = '/movimientos';
  static const String reportes = '/reportes';
  static const String ayuda = '/ayuda';

  static final GoRouter router = GoRouter(
    initialLocation: dashboard,
    routes: [
      // Dashboard
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DashboardScreen(),
        ),
      ),

      // Clientes
      GoRoute(
        path: clientes,
        name: 'clientes',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ClientesListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'form',
            name: 'cliente-form',
            pageBuilder: (context, state) {
              final idParam = state.uri.queryParameters['id'];
              final id = idParam != null ? int.tryParse(idParam) : null;
              return MaterialPage(
                key: state.pageKey,
                child: ClienteFormScreen(clienteId: id),
              );
            },
          ),
          GoRoute(
            path: ':id',
            name: 'cliente-detalle',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id']!) ?? 0;
              return MaterialPage(
                key: state.pageKey,
                child: ClienteDetailScreen(clienteId: id),
              );
            },
          ),
        ],
      ),

      // Préstamos
      GoRoute(
        path: prestamos,
        name: 'prestamos',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PrestamosListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'form',
            name: 'prestamo-form',
            pageBuilder: (context, state) {
              final idParam = state.uri.queryParameters['id'];
              final id = idParam != null ? int.tryParse(idParam) : null;
              return MaterialPage(
                key: state.pageKey,
                child: PrestamoFormScreen(prestamoId: id),
              );
            },
          ),
          GoRoute(
            path: ':id',
            name: 'prestamo-detalle',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id']!) ?? 0;
              return MaterialPage(
                key: state.pageKey,
                child: PrestamoDetailScreen(prestamoId: id),
              );
            },
          ),
        ],
      ),

      // Pagos - ✅ ACTUALIZADO
      GoRoute(
        path: pagos,
        name: 'pagos',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PagosListScreen(), // ✅ Pantalla funcional
        ),
        routes: [
          GoRoute(
            path: 'form',
            name: 'pago-form',
            pageBuilder: (context, state) {
              final prestamoIdParam = state.uri.queryParameters['prestamoId'];
              final prestamoId = prestamoIdParam != null ? int.tryParse(prestamoIdParam) : null;
              final codigo = state.uri.queryParameters['prestamoCodigo'] ?? '';
              final saldoParam = state.uri.queryParameters['saldoPendiente'];
              final saldo = saldoParam != null ? double.tryParse(saldoParam) : 0.0;
              
              return MaterialPage(
                key: state.pageKey,
                child: RegistrarPagoScreen(
                  prestamoId: prestamoId ?? 0,
                  prestamocodigo: codigo,
                  saldoPendiente: saldo ?? 0.0,
                ),
              );
            },
          ),
        ],
      ),

      // Cajas
      GoRoute(
        path: cajas,
        name: 'cajas',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CajasListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'form',
            name: 'caja-form',
            pageBuilder: (context, state) {
              final idParam = state.uri.queryParameters['id'];
              final id = idParam != null ? int.tryParse(idParam) : null;
              return MaterialPage(
                key: state.pageKey,
                child: CajaFormScreen(cajaId: id),
              );
            },
          ),
          GoRoute(
            path: 'ingreso',
            name: 'registrar-ingreso',
            pageBuilder: (context, state) {
              final cajaIdParam = state.uri.queryParameters['cajaId'];
              final cajaId = cajaIdParam != null ? int.tryParse(cajaIdParam) : 0;
              return MaterialPage(
                key: state.pageKey,
                child: RegistrarIngresoScreen(cajaId: cajaId ?? 0),
              );
            },
          ),
          GoRoute(
            path: 'egreso',
            name: 'registrar-egreso',
            pageBuilder: (context, state) {
              final cajaIdParam = state.uri.queryParameters['cajaId'];
              final cajaId = cajaIdParam != null ? int.tryParse(cajaIdParam) : 0;
              return MaterialPage(
                key: state.pageKey,
                child: RegistrarEgresoScreen(cajaId: cajaId ?? 0),
              );
            },
          ),
          GoRoute(
            path: ':id',
            name: 'caja-detalle',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id']!) ?? 0;
              return MaterialPage(
                key: state.pageKey,
                child: CajaDetailScreen(cajaId: id),
              );
            },
          ),
        ],
      ),

      // Transferencias
      GoRoute(
        path: transferencia,
        name: 'transferencias',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const TransferenciaScreen(),
        ),
      ),

      // Movimientos
      GoRoute(
        path: movimientos,
        name: 'movimientos',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const PlaceholderWithDrawer(title: 'Movimientos Generales'),
        ),
      ),

      // Reportes
      GoRoute(
        path: reportes,
        name: 'reportes',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ReportesScreen(),
        ),
      ),

      // Ayuda
      GoRoute(
        path: ayuda,
        name: 'ayuda',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const AyudaScreen(),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Error')),
        drawer: const AppDrawer(),
        body: Center(
          child: Text('Página no encontrada: ${state.matchedLocation}'),
        ),
      ),
    ),
  );
}

// Widget auxiliar para pantallas pendientes
class PlaceholderWithDrawer extends StatelessWidget {
  final String title;

  const PlaceholderWithDrawer({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('En Construcción', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }
}