import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/usecases/create_cliente.dart';
import '../../domain/usecases/get_clientes.dart';
import '../../domain/usecases/update_cliente.dart';
import '../../domain/usecases/delete_cliente.dart';
import '../../data/datasources/cliente_local_data_source.dart';
import '../../data/repositories/cliente_repository_impl.dart';
import '../../../../core/database/database_provider.dart';
import '../../../prestamos/domain/entities/prestamo.dart';
import '../../../prestamos/presentation/providers/prestamo_provider.dart';


// Provider para el data source
final clienteLocalDataSourceProvider = Provider<ClienteLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return ClienteLocalDataSource(database);
});

// Provider para el repositorio
final clienteRepositoryProvider = Provider<ClienteRepositoryImpl>((ref) {
  final dataSource = ref.watch(clienteLocalDataSourceProvider);
  return ClienteRepositoryImpl(localDataSource: dataSource);
});

// Providers para los use cases
final getClientesUseCaseProvider = Provider<GetClientes>((ref) {
  final repository = ref.watch(clienteRepositoryProvider);
  return GetClientes(repository);
});

final getClienteByIdUseCaseProvider = Provider<GetClienteById>((ref) {
  final repository = ref.watch(clienteRepositoryProvider);
  return GetClienteById(repository);
});

final searchClientesUseCaseProvider = Provider<SearchClientes>((ref) {
  final repository = ref.watch(clienteRepositoryProvider);
  return SearchClientes(repository);
});

final getClientesActivosUseCaseProvider = Provider<GetClientesActivos>((ref) {
  final repository = ref.watch(clienteRepositoryProvider);
  return GetClientesActivos(repository);
});

final createClienteUseCaseProvider = Provider<CreateCliente>((ref) {
  final repository = ref.watch(clienteRepositoryProvider);
  return CreateCliente(repository);
});

final updateClienteUseCaseProvider = Provider<UpdateCliente>((ref) {
  final repository = ref.watch(clienteRepositoryProvider);
  return UpdateCliente(repository);
});

final deleteClienteUseCaseProvider = Provider<DeleteCliente>((ref) {
  final repository = ref.watch(clienteRepositoryProvider);
  return DeleteCliente(repository);
});

// ✅ NUEVO: Provider para obtener clientes activos como AsyncValue
final clientesActivosProvider = FutureProvider<List<Cliente>>((ref) async {
  final useCase = ref.watch(getClientesActivosUseCaseProvider);
  final result = await useCase();
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (clientes) => clientes,
  );
});

// Estado de la lista de clientes
class ClientesState {
  final List<Cliente> clientes;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final int currentPage;
  final int pageSize;

  ClientesState({
    this.clientes = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.currentPage = 1,
    this.pageSize = 15,
  });

  ClientesState copyWith({
    List<Cliente>? clientes,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? currentPage,
    int? pageSize,
  }) {
    return ClientesState(
      clientes: clientes ?? this.clientes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  int get totalPages => (clientes.length / pageSize).ceil();
}

// Provider para el estado de clientes
class ClientesNotifier extends StateNotifier<ClientesState> {
  final GetClientes _getClientes;
  final SearchClientes _searchClientes;
  final CreateCliente _createCliente;
  final UpdateCliente _updateCliente;
  final DeleteCliente _deleteCliente;

  ClientesNotifier(
    this._getClientes,
    this._searchClientes,
    this._createCliente,
    this._updateCliente,
    this._deleteCliente,
  ) : super(ClientesState()) {
    loadClientes();
  }

  /// Carga todos los clientes
  Future<void> loadClientes() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getClientes();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (clientes) => state = state.copyWith(
        clientes: clientes,
        isLoading: false,
        error: null,
      ),
    );
  }

  /// Busca clientes por query
  Future<void> searchClientes(String query) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      searchQuery: query,
    );

    final result = await _searchClientes(query);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (clientes) => state = state.copyWith(
        clientes: clientes,
        isLoading: false,
        error: null,
      ),
    );
  }

  /// Limpia la búsqueda y recarga todos los clientes
  Future<void> clearSearch() async {
    state = state.copyWith(searchQuery: '');
    await loadClientes();
  }

  /// Crea un nuevo cliente
  Future<bool> createCliente(Cliente cliente) async {
    final result = await _createCliente(cliente);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (createdCliente) {
        // Recargar la lista después de crear
        loadClientes();
        return true;
      },
    );
  }

  /// Actualiza un cliente existente
  Future<bool> updateCliente(Cliente cliente) async {
    final result = await _updateCliente(cliente);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedCliente) {
        // Recargar la lista después de actualizar
        loadClientes();
        return true;
      },
    );
  }

  /// Elimina un cliente
  Future<bool> deleteCliente(int id) async {
    final result = await _deleteCliente(id);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        // Recargar la lista después de eliminar
        loadClientes();
        return true;
      },
    );
  }

  /// Limpia el error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Cambia la página actual
  void setPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }
}

// Provider del notifier
final clientesProvider =
    StateNotifierProvider<ClientesNotifier, ClientesState>((ref) {
  return ClientesNotifier(
    ref.watch(getClientesUseCaseProvider),
    ref.watch(searchClientesUseCaseProvider),
    ref.watch(createClienteUseCaseProvider),
    ref.watch(updateClienteUseCaseProvider),
    ref.watch(deleteClienteUseCaseProvider),
  );
});

// ✅ NUEVO: Clase para el modelo de vista del dashboard
class ClienteDashboardModel {
  final Cliente cliente;
  final double saldoTotal;
  final String statusGlobal;

  ClienteDashboardModel({
    required this.cliente,
    required this.saldoTotal,
    required this.statusGlobal,
  });
}

// ✅ NUEVO: Provider para los datos del dashboard (con paginación)
final clientesDashboardProvider = Provider<AsyncValue<({List<ClienteDashboardModel> items, int totalItems, int totalPages, int currentPage})>>((ref) {
  final clientesState = ref.watch(clientesProvider);
  final prestamosAsync = ref.watch(prestamosListProvider);

  if (clientesState.isLoading) return const AsyncValue.loading();
  if (clientesState.error != null) return AsyncValue.error(clientesState.error!, StackTrace.current);

  return prestamosAsync.when(
    data: (prestamos) {
      // 1. Mapear todos los clientes a modelos de dashboard
      final allItems = clientesState.clientes.map((cliente) {
        final prestamosCliente = prestamos.where((p) => p.clienteId == cliente.id).toList();
        
        double saldoTotal = 0;
        bool tieneMora = false;
        
        for (final p in prestamosCliente) {
          saldoTotal += p.saldoPendiente;
          if (p.estado == EstadoPrestamo.mora) {
            tieneMora = true;
          }
        }

        String statusGlobal = 'Activo';
        if (!cliente.activo) {
          statusGlobal = 'Inactivo';
        } else if (tieneMora) {
          statusGlobal = 'Mora';
        }

        return ClienteDashboardModel(
          cliente: cliente,
          saldoTotal: saldoTotal,
          statusGlobal: statusGlobal,
        );
      }).toList();

      // 2. Aplicar paginación
      final totalItems = allItems.length;
      final totalPages = (totalItems / clientesState.pageSize).ceil();
      final currentPage = clientesState.currentPage > totalPages ? totalPages : clientesState.currentPage;
      
      final startIndex = (currentPage - 1) * clientesState.pageSize;
      final endIndex = startIndex + clientesState.pageSize;
      
      final paginatedItems = allItems.isEmpty 
          ? <ClienteDashboardModel>[] 
          : allItems.sublist(
              startIndex, 
              endIndex > totalItems ? totalItems : endIndex,
            );

      return AsyncValue.data((
        items: paginatedItems,
        totalItems: totalItems,
        totalPages: totalPages == 0 ? 1 : totalPages,
        currentPage: currentPage == 0 ? 1 : currentPage,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
});

// Provider para obtener un cliente específico por ID
final clienteByIdProvider = FutureProvider.family<Cliente?, int>((ref, id) async {
  final useCase = ref.watch(getClienteByIdUseCaseProvider);
  final result = await useCase(id);
  
  return result.fold(
    (failure) => null,
    (cliente) => cliente,
  );
});
