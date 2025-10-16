// screens/budget_alerts_screen.dart
import 'package:clarifi_app/src/widgets/info_card.dart';
import 'package:clarifi_app/src/widgets/notification_details.dart';
import 'package:clarifi_app/src/widgets/section_header.dart';
import 'package:clarifi_app/src/widgets/threshold_switch.dart';
import 'package:flutter/material.dart';

// models/alert_preferences.dart
class AlertPreferences {
  final bool inAppNotification;
  final bool pushNotification;
  final bool criticalNotification;
  final double inAppThreshold;
  final double pushThreshold;
  final double criticalThreshold;
  final List<String> disabledBudgets;
  final bool dailyNotificationLimit;

  const AlertPreferences({
    required this.inAppNotification,
    required this.pushNotification,
    required this.criticalNotification,
    required this.inAppThreshold,
    required this.pushThreshold,
    required this.criticalThreshold,
    required this.disabledBudgets,
    required this.dailyNotificationLimit,
  });

  AlertPreferences copyWith({
    bool? inAppNotification,
    bool? pushNotification,
    bool? criticalNotification,
    double? inAppThreshold,
    double? pushThreshold,
    double? criticalThreshold,
    List<String>? disabledBudgets,
    bool? dailyNotificationLimit,
  }) {
    return AlertPreferences(
      inAppNotification: inAppNotification ?? this.inAppNotification,
      pushNotification: pushNotification ?? this.pushNotification,
      criticalNotification: criticalNotification ?? this.criticalNotification,
      inAppThreshold: inAppThreshold ?? this.inAppThreshold,
      pushThreshold: pushThreshold ?? this.pushThreshold,
      criticalThreshold: criticalThreshold ?? this.criticalThreshold,
      disabledBudgets: disabledBudgets ?? this.disabledBudgets,
      dailyNotificationLimit: dailyNotificationLimit ?? this.dailyNotificationLimit,
    );
  }
}

class BudgetAlertsScreen extends StatefulWidget {
  const BudgetAlertsScreen({Key? key}) : super(key: key);

  @override
  State<BudgetAlertsScreen> createState() => _BudgetAlertsScreenState();
}

class _BudgetAlertsScreenState extends State<BudgetAlertsScreen> {
  AlertPreferences _preferences = const AlertPreferences(
    inAppNotification: true,
    pushNotification: true,
    criticalNotification: false,
    inAppThreshold: 80.0,
    pushThreshold: 90.0,
    criticalThreshold: 95.0,
    disabledBudgets: [],
    dailyNotificationLimit: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas de presupuesto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            SectionHeader(
              title: 'Manténgase al día con las alertas de presupuesto',
              subtitle: 'Rocio Prof. (Rocio) es olor humano para ayudarle a administrar los gastos y mantenerlo en el uso de su presupuesto. Personaliza tus preferencias de alertas continuación.',
            ),

            // Umbrales de Alerta
            SectionHeader(
              title: 'Umbrales de alerta',
            ),
            ThresholdSwitch(
              title: 'Notificación en la aplicación',
              value: _preferences.inAppNotification,
              onChanged: (value) => _updatePreferences(inAppNotification: value),
              threshold: _preferences.inAppThreshold,
              onThresholdChanged: (value) => _updatePreferences(inAppThreshold: value),
            ),
            ThresholdSwitch(
              title: 'Notificación push',
              value: _preferences.pushNotification,
              onChanged: (value) => _updatePreferences(pushNotification: value),
              threshold: _preferences.pushThreshold,
              onThresholdChanged: (value) => _updatePreferences(pushThreshold: value),
            ),
            ThresholdSwitch(
              title: 'Notificación crítica',
              value: _preferences.criticalNotification,
              onChanged: (value) => _updatePreferences(criticalNotification: value),
              threshold: _preferences.criticalThreshold,
              onThresholdChanged: (value) => _updatePreferences(criticalThreshold: value),
            ),

            const SizedBox(height: 24),

            // Personalización
            InfoCard(
              title: 'Personalizar seguridad presupuesto',
              description: 'Desarrollar un riesgo personal sobre pero cada presupuesto',
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  // Navegar a pantalla de personalización
                },
              ),
            ),

            const SizedBox(height: 16),

            // Detalles de notificación
            const NotificationDetails(),

            const SizedBox(height: 16),

            // Frecuencia de alerta
            InfoCard(
              title: 'Frecuencia de alerta',
              description: 'Para evitar el tigran, se envuelta un máximo de una notificación por ventana el día.',
            ),

            const SizedBox(height: 16),

            // Deshabilitar alertas
            InfoCard(
              title: 'Deshabilitar alertas',
              description: 'Desactivar alertas para presupuestos específicos',
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  // Navegar a pantalla de deshabilitar alertas
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePreferences({
    bool? inAppNotification,
    bool? pushNotification,
    bool? criticalNotification,
    double? inAppThreshold,
    double? pushThreshold,
    double? criticalThreshold,
    List<String>? disabledBudgets,
    bool? dailyNotificationLimit,
  }) {
    setState(() {
      _preferences = _preferences.copyWith(
        inAppNotification: inAppNotification,
        pushNotification: pushNotification,
        criticalNotification: criticalNotification,
        inAppThreshold: inAppThreshold,
        pushThreshold: pushThreshold,
        criticalThreshold: criticalThreshold,
        disabledBudgets: disabledBudgets,
        dailyNotificationLimit: dailyNotificationLimit,
      );
    });
  }
}