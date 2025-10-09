import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/models/account.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:clarifi_app/src/views/accounts/create_account_view.dart';

/// Vista que muestra la lista de cuentas del usuario con diseño moderno
/// Incluye saldo total consolidado y lista de cuentas individuales
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

  /// Calcula el saldo total consolidado
  double _calculateTotalBalance(List<AccountModel> accounts) {
    return accounts.fold(0.0, (sum, account) => sum + account.balance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header con título y botón cerrar
            _buildHeader(),
            
            // Contenido principal
            Expanded(
              child: Consumer<AccountViewModel>(
                builder: (context, viewModel, child) {
                  // Estado de carga
                  if (viewModel.isLoading && viewModel.accounts.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7C3AED),
                      ),
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

                  // Lista de cuentas
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        
                        // Card de saldo total
                        _buildTotalBalanceCard(viewModel.accounts),
                        
                        const SizedBox(height: 24),
                        
                        // Título "Todas las cuentas"
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Todas las cuentas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Lista de cuentas
                        ...viewModel.accounts.map((account) => _buildAccountItem(account)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAccountModal,
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  /// Construye el header con botón cerrar y título centrado
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Título centrado
          const Text(
            'Cuentas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          // Botón cerrar alineado a la izquierda
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el card con el saldo total consolidado
  Widget _buildTotalBalanceCard(List<AccountModel> accounts) {
    final totalBalance = _calculateTotalBalance(accounts);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9D5FF), Color(0xFFDDD6FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Saldo total',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7C3AED),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_formatBalance(totalBalance)}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Consolidado en USD',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF7C3AED),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye cada item de cuenta
  Widget _buildAccountItem(AccountModel account) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Navegar a detalles de cuenta
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                // Icono de la cuenta
                _buildAccountIcon(account.type),
                
                const SizedBox(width: 16),
                
                // Nombre y tipo de cuenta
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (account.isDefault == true) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xFFFBBF24),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatAccountType(account.type),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Saldo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${_formatBalance(account.balance)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: account.balance >= 0 
                            ? Colors.black87 
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.currency,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
      case 'cash':
        icon = Icons.payments_outlined;
        color = const Color(0xFF10B981);
        break;
      case 'corriente':
      case 'checking':
        icon = Icons.account_balance_outlined;
        color = const Color(0xFF7C3AED);
        break;
      case 'ahorros':
      case 'savings':
        icon = Icons.savings_outlined;
        color = const Color(0xFF06B6D4);
        break;
      case 'tarjeta de crédito':
      case 'credit':
      case 'crédito':
        icon = Icons.credit_card;
        color = const Color(0xFFF59E0B);
        break;
      case 'inversión':
      case 'investment':
        icon = Icons.trending_up;
        color = const Color(0xFFEC4899);
        break;
      default:
        icon = Icons.account_balance_wallet_outlined;
        color = const Color(0xFF6B7280);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
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
                backgroundColor: const Color(0xFF7C3AED),
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
              onPressed: () {
                context.read<AccountViewModel>().loadAccounts();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
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

  /// Formatea el tipo de cuenta para mostrar
  String _formatAccountType(String type) {
    final Map<String, String> typeNames = {
      'efectivo': 'Efectivo',
      'cash': 'Efectivo',
      'corriente': 'Corriente',
      'checking': 'Corriente',
      'ahorros': 'Ahorros',
      'savings': 'Ahorros',
      'tarjeta de crédito': 'Crédito',
      'credit': 'Crédito',
      'crédito': 'Crédito',
      'inversión': 'Inversión',
      'investment': 'Inversión',
    };
    
    return typeNames[type.toLowerCase()] ?? type;
  }

  /// Formatea el balance con separadores de miles
  String _formatBalance(double balance) {
    // Convertir a valor absoluto para el formato
    final absBalance = balance.abs();
    final formatted = absBalance.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    
    // Agregar signo negativo si es necesario
    return balance < 0 ? '-$formatted' : formatted;
  }
}
