// lib/services/notification_service.dart

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  /// Llama a init() antes de runApp() en main()
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      // Reemplaza con el nombre de tu icono en res/mipmap
      'resource://drawable/notification_icon',
      [
        NotificationChannel(
          channelKey: 'budgets_channel',
          channelName: 'Alertas de Presupuesto',
          channelDescription: 'Notificaciones cuando superes o te acerques al presupuesto',
          defaultColor: Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          channelShowBadge: true,
        )
      ],

    );

    // Pide permiso si no está concedido
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Muestra tu propio diálogo antes de solicitar
      // o pide permiso directamente:
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }
  

  /// Muestra una alerta de presupuesto
  static Future<void> showBudgetAlert({
    required int id,
    required String title,
    required String body,
  }) {
    return AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'budgets_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
