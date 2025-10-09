import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clarifi_app/src/models/account.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';
import 'package:clarifi_app/src/constants/app_constants.dart';
import 'package:clarifi_app/src/services/currency_conversion_service.dart';

/// Vista de detalles y edición de una cuenta
/// Muestra información completa de la cuenta y permite editarla
class AccountDetailView extends StatefulWidget {
  final AccountModel account;

  const AccountDetailView({
    super.key,
    required this.account,
  });

  @override
  State<AccountDetailView> createState() => _AccountDetailViewState();
}

class _AccountDetailViewState extends State<AccountDetailView> {
  final _formKey = GlobalKey<FormState>();
  final _currencyService = CurrencyConversionService();
  
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late String _selectedType;
  late String _selectedCurrency;
  late bool _isDefault;
  
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _balanceController = TextEditingController(text: widget.account.balance.toStringAsFixed(2));
    _selectedType = widget.account.type;
    _selectedCurrency = widget.account.currency;
    _isDefault = widget.account.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  /// Guarda los cambios de la cuenta
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final accountViewModel = context.read<AccountViewModel>();
      
      // Crear un nuevo AccountModel con los datos actualizados
      final updatedAccount = AccountModel(
        id: widget.account.id,
        userId: widget.account.userId,
        name: _nameController.text,
        type: _selectedType,
        currency: _selectedCurrency,
        balance: double.parse(_balanceController.text),
        isDefault: _isDefault,
        createdAt: widget.account.createdAt,
      );
      
      await accountViewModel.updateAccount(updatedAccount);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta actualizada exitosamente'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar cuenta: $e'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Elimina la cuenta con opción de transferir saldo
  Future<void> _deleteAccount() async {
    final accountViewModel = context.read<AccountViewModel>();
    
    // Obtener todas las cuentas excepto la actual
    final otherAccounts = accountViewModel.accounts
        .where((account) => account.id != widget.account.id)
        .toList();
    
    // Mostrar diálogo de eliminación
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _DeleteAccountDialog(
        accountName: widget.account.name,
        accountBalance: widget.account.balance,
        accountCurrency: widget.account.currency,
        otherAccounts: otherAccounts,
      ),
    );

    if (result == null || result['confirmed'] != true) return;

    try {
      final transferEnabled = result['transferEnabled'] as bool;
      final targetAccountId = result['targetAccountId'] as String?;
      
      bool success;
      
      if (transferEnabled && targetAccountId != null) {
        // Transferir saldo y eliminar
        success = await accountViewModel.transferBalanceAndDelete(
          fromAccountId: widget.account.id,
          toAccountId: targetAccountId,
        );
      } else {
        // Solo eliminar
        success = await accountViewModel.deleteAccount(widget.account.id);
      }
      
      if (success && mounted) {
        Navigator.pop(context, true); // Retornar true para indicar que se eliminó
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta eliminada exitosamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar cuenta: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Editar cuenta' : 'Detalles de cuenta',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF7C3AED)),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Editar',
            ),
        ],
      ),
      body: _isEditing ? _buildEditMode() : _buildDetailMode(),
    );
  }
  
  /// Modo edición (como en la foto)
  Widget _buildEditMode() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de cuenta
                  const Text(
                    'Nombre de cuenta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Mi cuenta bancaria',
                      filled: true,
                      fillColor: const Color(0xFFF5EEFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF984CE6), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tipo de cuenta
                  const Text(
                    'Tipo de cuenta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5EEFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF984CE6), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items: AppConstants.accountTypes.map((type) {
                      return DropdownMenuItem(
                        value: type.value,
                        child: Text(type.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedType = value);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Divisa
                  const Text(
                    'Divisa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5EEFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF984CE6), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items: AppConstants.currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency.code,
                        child: Text('${currency.code} - ${currency.label}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCurrency = value);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Switch cuenta predeterminada
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Establecer como cuenta predeterminada',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Switch(
                        value: _isDefault,
                        activeColor: const Color(0xFF984CE6),
                        onChanged: (value) {
                          setState(() => _isDefault = value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Botones fijos al final
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Botón Guardar cambios
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF984CE6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Guardar cambios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Botón Eliminar cuenta (texto rojo)
                TextButton(
                  onPressed: _deleteAccount,
                  child: const Text(
                    'Eliminar cuenta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Modo detalles (vista anterior)
  Widget _buildDetailMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono y nombre de la cuenta
          _buildAccountHeader(),
          
          const SizedBox(height: 32),
          
          // Saldo actual
          _buildBalanceCard(),
          
          const SizedBox(height: 32),
          
          // Campos de detalle
          _buildDetailFields(),
          
          const SizedBox(height: 32),
          
          // Botón eliminar
          _buildDeleteButton(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Header con icono y nombre de cuenta
  Widget _buildAccountHeader() {
    final accountTypeOption = AppConstants.accountTypes.firstWhere(
      (option) => option.value == _selectedType,
      orElse: () => AppConstants.accountTypes.last,
    );

    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF5EEFD),
              shape: BoxShape.circle,
            ),
            child: Icon(
              accountTypeOption.icon,
              color: const Color(0xFF984CE6),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          if (_isEditing)
            TextFormField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF984CE6)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            )
          else
            Text(
              widget.account.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          const SizedBox(height: 8),
          if (widget.account.isDefault == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 16, color: Color(0xFFFBBF24)),
                  SizedBox(width: 4),
                  Text(
                    'Cuenta predeterminada',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFBBF24),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Card con el saldo actual
  Widget _buildBalanceCard() {
    final balance = _isEditing 
        ? double.tryParse(_balanceController.text) ?? widget.account.balance
        : widget.account.balance;
    
    final convertedAmount = _currencyService.convert(
      amount: balance,
      fromCurrency: _selectedCurrency,
    );

    return Container(
      width: double.infinity,
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
        children: [
          const Text(
            'Saldo actual',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7C3AED),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (_isEditing)
            TextFormField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                prefix: Text('\$', style: TextStyle(fontSize: 36)),
                border: InputBorder.none,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El saldo es requerido';
                }
                if (double.tryParse(value) == null) {
                  return 'Saldo inválido';
                }
                return null;
              },
            )
          else
            Text(
              '\$${_formatBalance(balance)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            _selectedCurrency,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7C3AED),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_selectedCurrency != 'USD') ...[
            const SizedBox(height: 8),
            Text(
              '≈ USD \$${_formatBalance(convertedAmount)}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Campos en modo solo lectura
  Widget _buildDetailFields() {
    final accountTypeOption = AppConstants.accountTypes.firstWhere(
      (option) => option.value == widget.account.type,
      orElse: () => AppConstants.accountTypes.last,
    );

    return Column(
      children: [
        _buildDetailRow('Tipo de cuenta', accountTypeOption.label),
        const Divider(height: 32),
        _buildDetailRow('Moneda', widget.account.currency),
        const Divider(height: 32),
        _buildDetailRow(
          'Creada el',
          _formatDate(widget.account.createdAt),
        ),
      ],
    );
  }

  /// Fila de detalle
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Botón de eliminar
  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _deleteAccount,
        icon: const Icon(Icons.delete_outline),
        label: const Text('Eliminar cuenta'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Formatea el balance con separadores de miles
  String _formatBalance(double balance) {
    final absBalance = balance.abs();
    final formatted = absBalance.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return balance < 0 ? '-$formatted' : formatted;
  }

  /// Formatea fecha
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    
    try {
      final date = DateTime.parse(dateString);
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

/// Diálogo para eliminar cuenta con opción de transferir saldo
class _DeleteAccountDialog extends StatefulWidget {
  final String accountName;
  final double accountBalance;
  final String accountCurrency;
  final List<AccountModel> otherAccounts;

  const _DeleteAccountDialog({
    required this.accountName,
    required this.accountBalance,
    required this.accountCurrency,
    required this.otherAccounts,
  });

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _transferEnabled = false;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    // Si hay otras cuentas y el saldo no es cero, habilitar la opción de transferencia
    if (widget.otherAccounts.isNotEmpty && widget.accountBalance != 0) {
      _transferEnabled = false; // Por defecto deshabilitado
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyService = CurrencyConversionService();
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Eliminar cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensaje de advertencia
                  Text(
                    'Al eliminar esta cuenta, se eliminarán permanentemente todas las transacciones y datos asociados. Esta acción no se puede deshacer.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Alerta de saldo si tiene balance
                  if (widget.accountBalance != 0) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Esta cuenta tiene un saldo de ${currencyService.formatAmount(amount: widget.accountBalance, currency: widget.accountCurrency)}. Transfiere el saldo antes de eliminarla.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF92400E),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                  
                  // Opción de transferir saldo
                  if (widget.otherAccounts.isNotEmpty && widget.accountBalance != 0) ...[
                    Row(
                      children: [
                        Checkbox(
                          value: _transferEnabled,
                          onChanged: (value) {
                            setState(() {
                              _transferEnabled = value ?? false;
                              if (!_transferEnabled) {
                                _selectedAccountId = null;
                              }
                            });
                          },
                          activeColor: const Color(0xFF984CE6),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _transferEnabled = !_transferEnabled;
                                if (!_transferEnabled) {
                                  _selectedAccountId = null;
                                }
                              });
                            },
                            child: const Text(
                              'Transferir saldo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Dropdown de cuentas
                    if (_transferEnabled) ...[
                      const Text(
                        'Transferir a',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedAccountId,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF5EEFD),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF984CE6),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintText: 'Selecciona una cuenta',
                        ),
                        items: widget.otherAccounts.map((account) {
                          return DropdownMenuItem<String>(
                            value: account.id,
                            child: Text(
                              '${account.name} (...${account.id.substring(account.id.length - 4)})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAccountId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Botón eliminar
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Validar que si está habilitada la transferencia, se haya seleccionado una cuenta
                    if (_transferEnabled && _selectedAccountId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecciona una cuenta para transferir el saldo'),
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      );
                      return;
                    }
                    
                    Navigator.pop(context, {
                      'confirmed': true,
                      'transferEnabled': _transferEnabled,
                      'targetAccountId': _selectedAccountId,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Eliminar cuenta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
