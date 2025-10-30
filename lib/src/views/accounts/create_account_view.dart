import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/constants/account_constants.dart';
import 'package:clarifi_app/src/viewmodels/account_viewmodel.dart';

/// Vista modal para crear una nueva cuenta
/// Implementa la HU-03.1: Crear Nueva Cuenta
/// 
/// Esta vista sigue los principios SOLID:
/// - SRP: La vista solo se encarga de la UI, delegando la lógica de negocio al AccountViewModel
/// - OCP: Extensible para agregar nuevos tipos de validación sin modificar el código base
/// - DIP: Depende de abstracciones (AccountViewModel) en lugar de implementaciones concretas
/// 
/// Características:
/// - Validación de formulario en tiempo real
/// - Validación de nombre único mediante el ViewModel
/// - Manejo de estados de carga y errores
/// - Feedback visual al usuario (SnackBars)
/// - Guardado real en Supabase mediante AccountViewModel
/// - Redirección opcional a la lista de cuentas
class CreateAccountView extends StatefulWidget {
  final bool redirectToList;
  
  const CreateAccountView({
    super.key,
    this.redirectToList = false,
  });

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}class _CreateAccountViewState extends State<CreateAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController();

  String? _selectedAccountType;
  String? _selectedCurrency;
  bool _isDefaultAccount = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  /// Valida que el nombre no esté vacío
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de la cuenta es obligatorio';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  /// Valida que se haya seleccionado un tipo de cuenta
  String? _validateAccountType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Seleccione un tipo de cuenta';
    }
    return null;
  }

  /// Valida que se haya seleccionado una divisa
  String? _validateCurrency(String? value) {
    if (value == null || value.isEmpty) {
      return 'Seleccione una divisa';
    }
    return null;
  }

  /// Maneja la creación de la cuenta
  Future<void> _handleCreateAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Obtener el ViewModel
      final accountViewModel = context.read<AccountViewModel>();

      // Parsear el balance inicial
      final initialBalance = double.tryParse(_initialBalanceController.text) ?? 0.0;

      // Intentar crear la cuenta usando el ViewModel
      final success = await accountViewModel.createAccount(
        name: _nameController.text.trim(),
        type: _selectedAccountType!,
        currency: _selectedCurrency!,
        balance: initialBalance,
        isDefault: _isDefaultAccount,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta creada exitosamente'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );

          // Cerrar el modal
          Navigator.of(context).pop(true);
          
          // Redirigir a la lista de cuentas si está configurado
          if (widget.redirectToList) {
            context.go('/accounts/list');
          }
        } else {
          // Mostrar mensaje de error del ViewModel
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                accountViewModel.errorMessage ?? 'Error al crear la cuenta',
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nueva cuenta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: _buildForm(context),
    );
  }

  /// Construye el formulario
  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildAccountTypeDropdown(),
            const SizedBox(height: 16),
            _buildCurrencyDropdown(),
            const SizedBox(height: 16),
            _buildInitialBalanceField(),
            const SizedBox(height: 16),
            _buildDefaultAccountSwitch(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// Campo de nombre de cuenta
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            hintText: 'p. ej., Ahorros Personales',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF5EEFD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF984CE6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: _validateName,
        ),
      ],
    );
  }

  /// Dropdown de tipo de cuenta
  Widget _buildAccountTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          value: _selectedAccountType,
          decoration: InputDecoration(
            hintText: 'Dinero',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF5EEFD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF984CE6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: AccountConstants.accountTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type.value,
              child: Text(type.label),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedAccountType = newValue;
            });
          },
          validator: _validateAccountType,
        ),
      ],
    );
  }

  /// Dropdown de divisa
  Widget _buildCurrencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            hintText: 'USD - US Dollar',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF5EEFD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF984CE6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: AccountConstants.currencies.map((currency) {
            return DropdownMenuItem<String>(
              value: currency.code,
              child: Text(currency.label),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCurrency = newValue;
            });
          },
          validator: _validateCurrency,
        ),
      ],
    );
  }

  /// Campo de saldo inicial
  Widget _buildInitialBalanceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saldo inicial (opcional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _initialBalanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: '\$ 0.00',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF5EEFD),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF984CE6), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  /// Switch de cuenta predeterminada
  Widget _buildDefaultAccountSwitch() {
    return Row(
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
          value: _isDefaultAccount,
          onChanged: (value) {
            setState(() {
              _isDefaultAccount = value;
            });
          },
          activeColor: const Color(0xFF984CE6),
        ),
      ],
    );
  }

  /// Botón de crear cuenta
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreateAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF984CE6),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF984CE6).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Crear una cuenta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

