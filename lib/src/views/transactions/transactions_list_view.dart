import 'package:clarifi_app/src/colors/colors.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'transaction_item_view.dart';
import 'new_transaction_view.dart';
import 'transfer_view.dart';

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

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final vm = context.read<TransactionViewModel>();
      await vm.loadTransactions();
      await vm.loadCategories(selectedType ?? 'expense');
    });
  }

  void _clearAllFilters(TransactionViewModel vm) {
    vm.clearFilters();
    vm.loadTransactions();
    vm.loadCategories('expense');
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
          // 🔹 FILTROS EN SCROLL HORIZONTAL
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.grey.shade100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: selectedType == null
                        ? 'Tipo'
                        : selectedType == 'income'
                            ? 'Ingreso'
                            : 'Gasto',
                    icon: Icons.swap_vert_circle,
                    color: selectedType == null
                        ? Colors.grey.shade300
                        : AppColors.primary.withOpacity(0.2),
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
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: selectedCategoryId == null
                        ? 'Categoría'
                        : vm.categories
                                .firstWhere(
                                    (c) => c.id == selectedCategoryId,
                                    orElse: () => vm.categories.first)
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
                  const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // 🔹 LISTA DE TRANSACCIONES
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.errorMessage != null
                    ? Center(child: Text(vm.errorMessage!))
                    : vm.transactions.isEmpty
                        ? const Center(child: Text('No hay transacciones aún'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: vm.transactions.length,
                            itemBuilder: (context, index) {
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
                                onTap: () {},
                              );
                            },
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

  // 🔸 CHIP DE FILTRO ESTILIZADO
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
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
    );
  }

  // 🔸 SELECTORES MODALES
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
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
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

  // 🔸 MODAL PARA NUEVAS TRANSACCIONES
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
                    color: Colors.black87),
              ),
              const SizedBox(height: 16),
              _buildOption(context, Icons.arrow_downward, 'Nuevo gasto', 'expense'),
              _buildOption(context, Icons.arrow_upward, 'Nuevo ingreso', 'income'),
              _buildOption(context, Icons.swap_horiz, 'Transferencia', 'transfer'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(
      BuildContext context, IconData icon, String text, String type) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (type == 'transfer') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransferScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewTransactionView(type: type),
            ),
          );
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
