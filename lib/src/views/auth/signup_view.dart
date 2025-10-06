// ignore_for_file: use_build_context_synchronously

import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _confirmPasswordCtl = TextEditingController();
  final _userNameCtl = TextEditingController();
  final _fullNameCtl = TextEditingController();
  final _countryCtl = TextEditingController();
  final _currencyCtl = TextEditingController();

  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passwordCtl.dispose();
    _confirmPasswordCtl.dispose();
    _userNameCtl.dispose();
    _fullNameCtl.dispose();
    _countryCtl.dispose();
    _currencyCtl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes aceptar los Términos de Servicio y Política de Privacidad',
          ),
        ),
      );
      return;
    }

    
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      final res = await authViewModel.signUp(
        _emailCtl.text.trim(),
        _passwordCtl.text,
        _userNameCtl.text.trim(),
        _fullNameCtl.text.trim(),
        _countryCtl.text.trim(),
        _currencyCtl.text.trim(),
      );
      

      if (res != null) {
        // Although the user is created, they need to confirm their email.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso', style: TextStyle(color: Colors.black)),
            backgroundColor: AppColors.success,
          ),
        );
        _emailCtl.clear();
        _passwordCtl.clear();
        _confirmPasswordCtl.clear();
        _userNameCtl.clear();
        _fullNameCtl.clear();
        _countryCtl.clear();
        _currencyCtl.clear();
        setState(() => _acceptTerms = false);
        GoRouter.of(context).go('/login');
      } else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error en el registro', style: TextStyle(color: AppColors.background)),
            backgroundColor: AppColors.error,
          ),
        );
        _emailCtl.clear();
        _passwordCtl.clear();
        _confirmPasswordCtl.clear();
        _userNameCtl.clear();
        _fullNameCtl.clear();
        _countryCtl.clear();
        _currencyCtl.clear();
        setState(() => _acceptTerms = false);
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2EFE7),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              // Título
              const Text(
                'Registro',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),

              // Campos del formulario
              _buildTextField(_fullNameCtl, 'Nombre completo', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(_userNameCtl, 'Usuario', Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(
                _emailCtl,
                'Correo electrónico',
                Icons.email,
                TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(_countryCtl, 'País', Icons.location_on),
              const SizedBox(height: 16),
              _buildTextField(_currencyCtl, 'Moneda', Icons.attach_money),
              const SizedBox(height: 16),
              _buildPasswordField(_passwordCtl, 'Contraseña'),
              const SizedBox(height: 16),
              _buildPasswordField(_confirmPasswordCtl, 'Confirmar contraseña'),
              const SizedBox(height: 24),

              // Checkbox de términos
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _acceptTerms = !_acceptTerms;
                        });
                      },
                      child: const Text(
                        'Acepto los Términos de Servicio y la Política de Privacidad',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botón de registro
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Enlace para iniciar sesión
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navegar a pantalla de login
                    GoRouter.of(context).go('/login');
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: '¿Ya tienes una cuenta? ',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: 'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Este campo es requerido';
        }
        if (keyboardType == TextInputType.emailAddress && !v.contains('@')) {
          return 'Email inválido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String labelText,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Este campo es requerido';
        }
        if (v.length < 6) {
          return 'Mínimo 6 caracteres';
        }
        if (controller == _confirmPasswordCtl && v != _passwordCtl.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
    );
  }
}
