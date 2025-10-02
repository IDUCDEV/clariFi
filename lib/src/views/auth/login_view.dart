
// ignore_for_file: use_build_context_synchronously

import 'package:clarifi_app/src/colors/colors.dart';
import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      final res = await authViewModel.login(
        _emailCtl.text.trim(),
        _passwordCtl.text,
      );

      if (res != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión exitoso', style: TextStyle(color: Colors.black)),
            backgroundColor: AppColors.success,
          ),
        );
        _emailCtl.clear();
        _passwordCtl.clear();
        // Navigate to dashboard after login
        GoRouter.of(context).go('/dashboard');
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
              Image.asset(
                'lib/assets/logo.png',
                width: 230,
                height: 230,
              ),
              const Text(
                'Iniciar Sesión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),

              // Campos del formulario
              _buildTextField(
                _emailCtl,
                'Correo electrónico',
                Icons.email,
                TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(_passwordCtl, 'Contraseña'),
              const SizedBox(height: 32),

              // Botón de login
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
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
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Enlace para registrarse
              Center(
                child: GestureDetector(
                  onTap: () {
                    GoRouter.of(context).go('/signup');
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: '¿No tienes una cuenta? ',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: 'Registrarse',
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
              Center(
                child: GestureDetector(
                  onTap: () {
                    
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: '¿Olvidaste tu contraseña? ',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: 'Recuperar contraseña',
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
        return null;
      },
    );
  }
}
