import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'transaction_item_view.dart';
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (query) => vm.setSearchQuery(query),
                decoration: InputDecoration(
                  hintText: 'Buscar por nota, categoría o cuenta...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
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
                _buildFilterChip(
                  label: selectedType == null
                      ? 'Tipo'
                      : selectedType == 'income'
                      ? 'Ingreso'
                      : 'Gasto',
                  icon: Icons.swap_vert_circle,
                  color: selectedType == null
                      ? Colors.grey.shade200
                      : AppColors.primary.withOpacity(0.15),
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
                _buildFilterChip(
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
                _buildFilterChip(
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
                _buildFilterChip(
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
                : RefreshIndicator(
                    onRefresh: vm.loadTransactions,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          vm.transactions.length + (vm.isLoadingMore ? 1 : 0),
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
                            account: item.accountName ?? 'Cuenta desconocida',
                            date: item.date,
                            amount: item.amount,
                            type: item.type,
                            // 👇 NUEVO: tap abre detalle/edición
                            onTap: () async {
                              final updated = context.push('/transactions/edit/${item.id}');
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
    return await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _buildBottomSelector(
        title: 'Seleccionar cuenta',
        items: const [
          {'value': '1', 'label': 'Cuenta principal'},
          {'value': '2', 'label': 'Tarjeta débito'},
        ],
      ),
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
}
