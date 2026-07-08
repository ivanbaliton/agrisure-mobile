import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/app_notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AppNotificationService _service = AppNotificationService();

  bool isLoading = true;
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.token == null) return;

    setState(() {
      isLoading = true;
    });

    final data = await _service.getNotifications(authProvider.token!);

    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  Future<void> markAsRead(int id) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.token == null) return;

    await _service.markAsRead(token: authProvider.token!, notificationId: id);

    await fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : RefreshIndicator(
              onRefresh: fetchNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  final bool isRead =
                      notification['is_read'] == true ||
                      notification['is_read'] == 1;

                  return Card(
                    elevation: isRead ? 1 : 3,
                    child: ListTile(
                      leading: Icon(
                        isRead
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        color: isRead ? Colors.grey : Colors.green,
                      ),
                      title: Text(
                        notification['title'] ?? 'Notification',
                        style: TextStyle(
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notification['message'] ?? ''),
                      trailing: isRead
                          ? null
                          : const Icon(Icons.circle, size: 10),
                      onTap: () {
                        markAsRead(notification['id']);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
