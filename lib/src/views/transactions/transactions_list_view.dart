import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'transaction_item_view.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'new_transaction_view.dart';
import 'package:go_router/go_router.dart';
import 'transfer_view.dart';
import 'edit_transaction_view.dart'; // 👈 Nueva importación

class TransactionsListView extends StatefulWidget {
  const TransactionsListView({super.key});

  @override
  State<TransactionsListView> createState() => _TransactionsListViewState();
}

class _TransactionsListViewState extends State<TransactionsListView> {
  String? selectedType;
  String? selectedCategoryId;
  String? selectedAccountId;
  String? selectedAccountName;
  DateTimeRange? selectedDateRange;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final vm = context.read<TransactionViewModel>();
      await vm.loadTransactions();
      await vm.loadCategories(selectedType ?? 'expense');
    });

    // 🔹 Detectar scroll al final para scroll infinito
    _scrollController.addListener(() {
      final vm = context.read<TransactionViewModel>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !vm.isLoadingMore &&
          !vm.isLoading) {
        vm.loadMoreTransactions();
      }
    });
  }

  void _clearAllFilters(TransactionViewModel vm) {
    _searchController.clear();
    vm.clearFilters();
    setState(() {
      selectedType = null;
      selectedCategoryId = null;
      selectedAccountId = null;
      selectedAccountName = null;
      selectedDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Transacciones',
          style: TextStyle(color: AppColors.onSecondary),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off, color: AppColors.primary),
            tooltip: 'Restablecer filtros',
            onPressed: () => _clearAllFilters(vm),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
        color: AppColors.mediumPurple.withOpacity(0.7), // 👈 color del borde
        width: 1.5,
      ), 
                 boxShadow: [
        BoxShadow(
           color: AppColors.mediumPurple.withOpacity(0.1),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (query) => vm.setSearchQuery(query),
                style: TextStyle(
        color: AppColors.mediumPurple.withOpacity(0.9), // 👈 color del texto
      ),
                decoration: InputDecoration(
                  hintText: 'Buscar transacciones...',
        hintStyle: TextStyle(
          color: AppColors.mediumPurple.withOpacity(0.7), // 👈 color del hint
        ),
                  prefixIcon: Icon(
          Icons.search,
          color: AppColors.mediumPurple.withOpacity(0.7), // 👈 color del ícono
        ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            vm.setSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // 🔹 Filtros horizontales
          SizedBox(
  height: 50,
  child: ListView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    children: [
      _buildStyledFilterChip(
        label: selectedType == null
            ? 'Tipo'
            : selectedType == 'income'
                ? 'Ingreso'
                : 'Gasto',
        icon: Icons.swap_vert_circle,
        onTap: () async {
          final type = await _showTypeSelector();
          if (type != null) {
            setState(() {
              selectedType = type;
              selectedCategoryId = null;
            });
            await vm.loadCategories(type);
            vm.applyFilters(
              type: type,
              categoryId: selectedCategoryId,
              accountId: selectedAccountId,
              dateRange: selectedDateRange,
            );
          }
        },
      ),
      _buildStyledFilterChip(
        label: selectedCategoryId == null
            ? 'Categoría'
            : vm.categories
                .firstWhere(
                  (c) => c.id == selectedCategoryId,
                  orElse: () => vm.categories.first,
                )
                .name,
        icon: Icons.category_rounded,
        onTap: () async {
          final category = await _showCategorySelector(vm);
          if (category != null) {
            setState(() => selectedCategoryId = category);
            vm.applyFilters(
              type: selectedType,
              categoryId: category,
              accountId: selectedAccountId,
              dateRange: selectedDateRange,
            );
          }
        },
      ),
      _buildStyledFilterChip(
        label: selectedAccountId ?? 'Cuenta',
        icon: Icons.account_balance_wallet_outlined,
        onTap: () async {
          final account = await _showAccountSelector();
          if (account != null) {
            setState(() => selectedAccountId = account);
            vm.applyFilters(
              type: selectedType,
              categoryId: selectedCategoryId,
              accountId: account,

              dateRange: selectedDateRange,
            );
          }
        },
      ),
      _buildStyledFilterChip(
        label: selectedDateRange == null
            ? 'Fecha'
            : '${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}',
        icon: Icons.date_range,
        onTap: () async {
          final range = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            builder: (context, child) => Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                ),
              ),
              child: child!,
            ),
          );
          if (range != null) {
            setState(() => selectedDateRange = range);
            vm.applyFilters(
              type: selectedType,
              categoryId: selectedCategoryId,
              accountId: selectedAccountId,
              dateRange: range,
            );
          }
        },
      ),
    ],
  ),
),

          // 🔹 Lista de transacciones (scroll infinito + refresh)
        Expanded(
  child: vm.isLoading && vm.transactions.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : vm.errorMessage != null
          ? Center(child: Text(vm.errorMessage!))
          : vm.transactions.isEmpty
              ? const Center(
                  child: Text(
                    'No hay transacciones que mostrar.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await vm.loadTransactions();
                    setState(() {});
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.transactions.length +
                        (vm.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < vm.transactions.length) {
                        final item = vm.transactions[index];
                        return TransactionItem(
                          title: [
                            if (item.note != null && item.note!.isNotEmpty)
                              item.note!,
                            if (item.categoryName != null &&
                                item.categoryName!.isNotEmpty)
                              item.categoryName!,
                          ].join(' / '),
                          account:
                              item.accountName ?? 'Cuenta desconocida',
                          date: item.date,
                          amount: item.amount,
                          type: item.type,
                          onTap: () async {
                            final updated = await context.push(
                              '/transactions/edit/${item.id}',
                            );
                            if (updated == true) await vm.loadTransactions();
                          },
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                  ),
                ),
),


        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ============================================================
  // Widgets auxiliares
  // ============================================================

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Chip(
          avatar: Icon(icon, size: 18, color: AppColors.primary),
          label: Text(label),
          backgroundColor: color ?? Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black12),
          ),
        ),
      ),
    );
  }

  Future<String?> _showTypeSelector() async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _buildBottomSelector(
        title: 'Seleccionar tipo',
        items: const [
          {'value': 'income', 'label': 'Ingreso'},
          {'value': 'expense', 'label': 'Gasto'},
        ],
      ),
    );
  }

  Future<String?> _showCategorySelector(TransactionViewModel vm) async {
    final items = vm.categories
        .map((c) => {'value': c.id, 'label': c.name})
        .toList();
    return await showModalBottomSheet<String>(
      context: context,
      builder: (context) =>
          _buildBottomSelector(title: 'Seleccionar categoría', items: items),
    );
  }

  Future<String?> _showAccountSelector() async {
  final vmAccounts = Provider.of<AccountViewModel>(context, listen: false);
  await vmAccounts.loadAccounts(); // 👈 asegúrate de tener esta función en tu ViewModel

  return await showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      if (vmAccounts.isLoading) {
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecciona una cuenta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...vmAccounts.accounts.map((account) {
                return ListTile(
                  title: Text(account.name),
                  onTap: () => Navigator.pop(context, account.name),
                );
              }).toList(),
            ],
          ),
        );
      }
    },
  );
}


  Widget _buildBottomSelector({
    required String title,
    required List<Map<String, String>> items,
  }) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          ...items.map(
            (item) => ListTile(
              title: Text(item['label']!),
              onTap: () => Navigator.pop(context, item['value']),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 40,
                  child: Divider(thickness: 4, color: Colors.black12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Agregar nuevo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildOption(
                context,
                Icons.arrow_downward,
                'Nuevo gasto',
                'expense',
              ),
              _buildOption(
                context,
                Icons.arrow_upward,
                'Nuevo ingreso',
                'income',
              ),
              _buildOption(
                context,
                Icons.swap_horiz,
                'Transferencia',
                'transfer',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String text,
    String type,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (type == 'transfer') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransferScreen()),
          );
        } else if (type == 'income') {
          context.push('/transactions/add/income');
        } else {
          context.push('/transactions/add/expense');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.lightPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
  // --- NUEVO BUILDER ---
Widget _buildStyledFilterChip({
  required String label,
  required IconData icon,
  required VoidCallback onTap,
}) {
  const mediumPurple = Color(0xFF9370DB);

  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mediumPurple.withOpacity(0.1), // Fondo suave
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: mediumPurple),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: mediumPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
