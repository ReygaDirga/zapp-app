import 'package:flutter/material.dart';
import 'package:zapp/core/components/tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: const [
              SizedBox(height: 8),
              _Header(),
              SizedBox(height: 24),

              SectionTitle(title: "Today"),
              SizedBox(height: 12),

              NotificationTile(
                type: NotificationType.warning,
                title: "Usage increased!",
                message:
                "This means your electricity consumption is higher than usual today",
                time: "9min ago",
              ),
              NotificationTile(
                type: NotificationType.success,
                title: "Report ready!",
                message:
                "Your electricity usage analysis has been completed",
                time: "14min ago",
              ),
              NotificationTile(
                type: NotificationType.info,
                title: "New update",
                message:
                "Open the app to read latest news",
                time: "20min ago",
              ),

              SectionTitle(title: "Yesterday"),
              SizedBox(height: 12),

              NotificationTile(
                type: NotificationType.success,
                title: "Report ready!",
                message:
                "Your electricity usage analysis has been completed",
                time: "Yesterday",
              ),
              NotificationTile(
                type: NotificationType.info,
                title: "New update",
                message:
                "Open the app to read latest news",
                time: "Yesterday",
              ),
              NotificationTile(
                type: NotificationType.warning,
                title: "Usage increased!",
                message:
                "This means your electricity consumption is higher than usual today",
                time: "Yesterday",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const Text(
          "Notifications",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }
}


