import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final userEmail = authViewModel.userEmail; // Suponiendo que tienes un modelo de usuario
    final userName = authViewModel.userName; // Suponiendo que tienes un modelo de usuario
// Suponiendo que tienes un modelo de usuario

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar del usuario
            CircleAvatar(
  radius: 50,
  backgroundColor: theme.colorScheme.primaryContainer,
  backgroundImage: AssetImage('lib/assets/default_image.jpg'),
),
            const SizedBox(height: 16),

            // Nombre
            Text(
              userName ?? 'Usuario sin nombre',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Correo
            Text(
              userEmail ?? 'Sin correo',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Campos informativos (no interactivos)
            _buildDisabledTile(
              icon: Icons.edit_outlined,
              title: 'Editar perfil',
              subtitle: '(Próximamente)',
            ),
            _buildDisabledTile(
              icon: Icons.lock_outline,
              title: 'Cambiar contraseña',
              subtitle: '(Próximamente)',
            ),
            _buildDisabledTile(
              icon: Icons.delete_outline,
              title: 'Eliminar cuenta',
              subtitle: '(Próximamente)',
            ),
          ],
        ),
      ),
    );
  }

  /// ListTile deshabilitado visualmente
  Widget _buildDisabledTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        title,
        style: const TextStyle(color: Colors.grey),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey),
      ),
      enabled: false, // Deshabilita el tap
    );
  }
}