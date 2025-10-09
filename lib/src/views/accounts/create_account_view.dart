import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/constants/account_constants.dart';
import 'package:clarifi_app/src/widgets/form/custom_text_field.dart';
import 'package:clarifi_app/src/widgets/form/custom_dropdown.dart';
import 'package:clarifi_app/src/widgets/form/labeled_switch.dart';
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildHeader(context), _buildForm(context)],
        ),
      ),
    );
  }

  /// Construye el header del modal
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, color: Colors.black54),
          ),
          const SizedBox(width: 16),
          const Text(
            'Nueva cuenta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el formulario del modal
  Widget _buildForm(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
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
      ),
    );
  }

  /// Campo de nombre de cuenta
  Widget _buildNameField() {
    return CustomTextField(
      label: 'Nombre de cuenta',
      hintText: 'p. ej. Ahorros Personales',
      controller: _nameController,
      validator: _validateName,
    );
  }

  /// Dropdown de tipo de cuenta
  Widget _buildAccountTypeDropdown() {
    return CustomDropdown<String>(
      label: 'Tipo de cuenta',
      hintText: 'Seleccionar tipo',
      value: _selectedAccountType,
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
    );
  }

  /// Dropdown de divisa
  Widget _buildCurrencyDropdown() {
    return CustomDropdown<String>(
      label: 'Divisa',
      hintText: 'USD - Dólar',
      value: _selectedCurrency,
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
    );
  }

  /// Campo de saldo inicial
  Widget _buildInitialBalanceField() {
    return CustomTextField(
      label: 'Saldo inicial (opcional)',
      hintText: '\$ 0.00',
      controller: _initialBalanceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
    );
  }

  /// Switch de cuenta predeterminada
  Widget _buildDefaultAccountSwitch() {
    return LabeledSwitch(
      label: 'Establecer como cuenta predeterminada',
      value: _isDefaultAccount,
      onChanged: (value) {
        setState(() {
          _isDefaultAccount = value;
        });
      },
    );
  }

  /// Botón de crear cuenta
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleCreateAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Crear una cuenta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
