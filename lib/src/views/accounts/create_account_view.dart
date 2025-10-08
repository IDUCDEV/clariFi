import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/constants/account_constants.dart';
import 'package:clarifi_app/src/widgets/form/custom_text_field.dart';
import 'package:clarifi_app/src/widgets/form/custom_dropdown.dart';
import 'package:clarifi_app/src/widgets/form/labeled_switch.dart';

/// Vista modal para crear una nueva cuenta
/// Implementa la HU-03.1: Crear Nueva Cuenta
/// 
/// Esta vista sigue los principios SOLID:
/// - SRP: La vista solo se encarga de la UI, delegando la lógica a un ViewModel (futuro)
/// - OCP: Extensible para agregar nuevos tipos de validación sin modificar el código base
/// - DIP: Depende de abstracciones (widgets personalizados) en lugar de implementaciones concretas
class CreateAccountView extends StatefulWidget {
  const CreateAccountView({super.key});

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
  void _handleCreateAccount() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // TODO: Integrar con AccountViewModel para guardar en la BD
      // Por ahora solo simula la creación
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta creada exitosamente'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
          
          Navigator.of(context).pop(true); // Retorna true para indicar éxito
        }
      });
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
