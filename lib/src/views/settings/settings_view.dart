import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Vista de Ajustes/Configuración
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
         title: const Text('Configuración general'),
         centerTitle: true,
       ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          // ========================================
          // PERFIL DE USUARIO
          // ========================================
          _buildSectionHeader('Perfil de usuario'),
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Perfil',
            subtitle: 'Gestiona los detalles de tu perfil',
            onTap: () => context.push('/profile'),
            enabled: true, // 🔹 Activo
          ),
          _buildDisabledTile(
            icon: Icons.notifications_outlined,
            title: 'Notificación',
            subtitle: '(Próximamente)',
          ),

          const Divider(height: 32),

          // ========================================
          // CONFIGURACIONES GENERALES
          // ========================================
          _buildSectionHeader('Configuraciones generales'),
          _buildDisabledTile(
            icon: Icons.language_outlined,
            title: 'Idioma',
            subtitle: '(Próximamente)',
          ),
          _buildDisabledTile(
            icon: Icons.security_outlined,
            title: 'Seguridad',
            subtitle: '(Próximamente)',
          ),

          const Divider(height: 32),

          // ========================================
          // CONFIGURACIONES DE LA CUENTA
          // ========================================
          _buildSectionHeader('Configuraciones de la cuenta'),
          _buildDisabledTile(
            icon: Icons.account_balance_outlined,
            title: 'Cuentas vinculadas',
            subtitle: '(Próximamente)',
          ),

          const Divider(height: 32),

          // ========================================
          // CONFIGURACIÓN DE PRESUPUESTO
          // ========================================
          _buildSectionHeader('Configuración de presupuesto'),
          _buildDisabledTile(
            icon: Icons.notifications_active_outlined,
            title: 'Alertas',
            subtitle: '(Próximamente)',
          ),
          _buildDisabledTile(
            icon: Icons.description_outlined,
            title: 'Plantillas',
            subtitle: '(Próximamente)',
          ),

          const Divider(height: 32),

          // ========================================
          // CONFIGURACIÓN DE INFORMES
          // ========================================
          _buildSectionHeader('Configuración de informes'),
          _buildDisabledTile(
            icon: Icons.file_download_outlined,
            title: 'Opciones de exportación',
            subtitle: '(Próximamente)',
          ),

          const Divider(height: 32),

          // ========================================
          // AYUDA Y SOPORTE
          // ========================================
          _buildSectionHeader('Ayuda y soporte'),
          _buildDisabledTile(
            icon: Icons.help_outline,
            title: 'Centro de ayuda',
            subtitle: '(Próximamente)',
          ),

          const SizedBox(height: 32),

          // ========================================
          // BOTÓN CERRAR SESIÓN
          // ========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FilledButton.tonalIcon(
              onPressed: () => _showLogoutDialog(context, authViewModel),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Encabezado de sección
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// Tile activo
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }

  /// Tile deshabilitado (gris, sin interacción)
  Widget _buildDisabledTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title, style: const TextStyle(color: Colors.grey)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      enabled: false,
    );
  }

  /// Diálogo para cerrar sesión
  void _showLogoutDialog(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              authViewModel.logout();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
