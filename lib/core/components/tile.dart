import 'package:flutter/material.dart';

enum NotificationType { warning, success, info }

class NotificationTile extends StatelessWidget {
  final NotificationType type;
  final String title;
  final String message;
  final String time;

  const NotificationTile({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _bgColor(),
            child: Icon(_icon(), color: _iconColor(), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon() {
    switch (type) {
      case NotificationType.warning:
        return Icons.warning_rounded;
      case NotificationType.success:
        return Icons.notifications_active_outlined;
      case NotificationType.info:
        return Icons.article_outlined;
    }
  }

  Color _bgColor() {
    switch (type) {
      case NotificationType.warning:
        return Colors.red.withOpacity(0.1);
      case NotificationType.success:
        return Colors.green.withOpacity(0.1);
      case NotificationType.info:
        return Colors.orange.withOpacity(0.1);
    }
  }

  Color _iconColor() {
    switch (type) {
      case NotificationType.warning:
        return Colors.red;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.info:
        return Colors.orange;
    }
  }
}
