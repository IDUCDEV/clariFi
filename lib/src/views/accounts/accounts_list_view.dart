import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/models/account.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:clarifi_app/src/views/accounts/create_account_view.dart';

/// Vista que muestra la lista de cuentas del usuario
/// Implementa parte de la HU-03.1: visualización de cuentas creadas
/// 
/// Características:
/// - Lista de cuentas ordenadas por fecha de creación
/// - Indicador de cuenta predeterminada
/// - Estado vacío cuando no hay cuentas
/// - Pull-to-refresh para recargar
/// - Indicador de carga
/// - Manejo de errores
/// - FAB para crear nueva cuenta
class AccountsListView extends StatefulWidget {
  const AccountsListView({super.key});

  @override
  State<AccountsListView> createState() => _AccountsListViewState();
}

class _AccountsListViewState extends State<AccountsListView> {
  @override
  void initState() {
    super.initState();
    // Cargar cuentas al iniciar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountViewModel>().loadAccounts();
    });
  }

  /// Maneja el pull-to-refresh
  Future<void> _handleRefresh() async {
    await context.read<AccountViewModel>().loadAccounts();
  }

  /// Muestra el modal para crear una nueva cuenta
  void _showCreateAccountModal() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateAccountView(),
    );

    // Si se creó exitosamente, recargar la lista
    if (result == true && mounted) {
      await context.read<AccountViewModel>().loadAccounts();
    }
  }

  /// Muestra un diálogo de confirmación para eliminar cuenta
  void _showDeleteConfirmation(AccountModel account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la cuenta "${account.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteAccount(account.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Elimina una cuenta
  Future<void> _deleteAccount(String accountId) async {
    final accountViewModel = context.read<AccountViewModel>();
    final success = await accountViewModel.deleteAccount(accountId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Cuenta eliminada exitosamente'
                : accountViewModel.errorMessage ?? 'Error al eliminar cuenta',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AccountViewModel>(
        builder: (context, viewModel, child) {
          // Estado de carga
          if (viewModel.isLoading && viewModel.accounts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Estado de error
          if (viewModel.hasError && viewModel.accounts.isEmpty) {
            return _buildErrorState(viewModel.errorMessage!);
          }

          // Estado vacío
          if (!viewModel.hasAccounts) {
            return _buildEmptyState();
          }

          // Lista de cuentas con AppBar personalizado en el body
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Mis Cuentas'),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                floating: true,
                snap: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final account = viewModel.accounts[index];
                      return _buildAccountCard(account);
                    },
                    childCount: viewModel.accounts.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAccountModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva cuenta',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// Construye el estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes cuentas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Crea tu primera cuenta para comenzar\na gestionar tus finanzas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreateAccountModal,
              icon: const Icon(Icons.add),
              label: const Text('Crear cuenta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el estado de error
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar cuentas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una tarjeta de cuenta
  Widget _buildAccountCard(AccountModel account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navegar a detalles de cuenta
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono según tipo de cuenta
                  _buildAccountIcon(account.type),
                  const SizedBox(width: 12),
                  
                  // Nombre y badge de predeterminada
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                account.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (account.isDefault == true) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Predeterminada',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatAccountType(account.type),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Menú de opciones
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(account);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Eliminar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Balance
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${account.currency} ${_formatBalance(account.balance)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el icono según el tipo de cuenta
  Widget _buildAccountIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'efectivo':
        icon = Icons.money;
        color = Colors.green;
        break;
      case 'cuenta de ahorros':
        icon = Icons.savings;
        color = Colors.blue;
        break;
      case 'cuenta corriente':
        icon = Icons.account_balance;
        color = Colors.purple;
        break;
      case 'tarjeta de crédito':
        icon = Icons.credit_card;
        color = Colors.orange;
        break;
      case 'inversión':
        icon = Icons.trending_up;
        color = Colors.teal;
        break;
      default:
        icon = Icons.account_balance_wallet;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  /// Formatea el tipo de cuenta
  String _formatAccountType(String type) {
    return type;
  }

  /// Formatea el balance con separadores de miles
  String _formatBalance(double balance) {
    return balance.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
