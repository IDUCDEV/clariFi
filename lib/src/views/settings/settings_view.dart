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
            onTap: () => _showDevelopmentMessage(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notificación',
            subtitle: 'Gestiona las notificaciones',
            onTap: () => _showDevelopmentMessage(context),
          ),
          
          const Divider(height: 32),
          
          // ========================================
          // CONFIGURACIONES GENERALES
          // ========================================
          _buildSectionHeader('Configuraciones generales'),
          _buildSettingsTile(
            context,
            icon: Icons.language_outlined,
            title: 'Idioma',
            subtitle: 'Cambiar el idioma de la aplicación',
            onTap: () => _showDevelopmentMessage(context),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: 'Seguridad',
            subtitle: 'Administrar cuentas vinculadas',
            onTap: () => _showDevelopmentMessage(context),
          ),
          
          const Divider(height: 32),
          
          // ========================================
          // CONFIGURACIONES DE LA CUENTA
          // ========================================
          _buildSectionHeader('Configuraciones de la cuenta'),
          _buildSettingsTile(
            context,
            icon: Icons.account_balance_outlined,
            title: 'Cuentas vinculadas',
            subtitle: 'Administrar cuentas vinculadas',
            onTap: () => context.push('/accounts/list'),
          ),
          
          const Divider(height: 32),
          
          // ========================================
          // CONFIGURACIÓN DE PRESUPUESTO
          // ========================================
          _buildSectionHeader('Configuración de presupuesto'),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_active_outlined,
            title: 'Alertas',
            subtitle: 'Configurar alertas de presupuesto',
            onTap: () => GoRouter.of(context).push('/alerstBudgets'),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: 'Plantillas',
            subtitle: 'Administrar plantillas de presupuesto',
            onTap: () => GoRouter.of(context).push('/templatesBudgets'),
          ),
          
          const Divider(height: 32),
          
          // ========================================
          // CONFIGURACIÓN DE INFORMES
          // ========================================
          _buildSectionHeader('Configuración de informes'),
          _buildSettingsTile(
            context,
            icon: Icons.file_download_outlined,
            title: 'Opciones de exportación',
            subtitle: 'Configurar exportaciones de informes',
            onTap: () => _showDevelopmentMessage(context),
          ),
          
          const Divider(height: 32),
          
          // ========================================
          // AYUDA Y SOPORTE
          // ========================================
          _buildSectionHeader('Ayuda y soporte'),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Centro de ayuda',
            subtitle: 'Encuentra respuesta y apoyo',
            onTap: () => _showDevelopmentMessage(context),
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

  /// Construye el encabezado de una sección
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

  /// Construye un elemento de configuración
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Muestra mensaje de funcionalidad en desarrollo
  void _showDevelopmentMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Muestra diálogo de confirmación para cerrar sesión
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
