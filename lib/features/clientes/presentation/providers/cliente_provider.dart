import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/usecases/create_cliente.dart';
import '../../domain/usecases/get_clientes.dart';
import '../../domain/usecases/update_cliente.dart';
import '../../domain/usecases/delete_cliente.dart';
import '../../data/datasources/cliente_local_data_source.dart';
import '../../data/repositories/cliente_repository_impl.dart';
import '../../../../core/database/database.dart';

// Provider para la base de datos
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

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

// Estado de la lista de clientes
class ClientesState {
  final List<Cliente> clientes;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  ClientesState({
    this.clientes = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  ClientesState copyWith({
    List<Cliente>? clientes,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return ClientesState(
      clientes: clientes ?? this.clientes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
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

// Provider para obtener un cliente específico por ID
final clienteByIdProvider = FutureProvider.family<Cliente?, int>((ref, id) async {
  final useCase = ref.watch(getClienteByIdUseCaseProvider);
  final result = await useCase(id);
  
  return result.fold(
    (failure) => null,
    (cliente) => cliente,
  );
});