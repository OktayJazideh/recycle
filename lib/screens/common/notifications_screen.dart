import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/app_data_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _ds = AppDataService();

  @override
  Widget build(BuildContext context) {
    final user = _ds.currentUser!;
    final notifs = _ds.getUserNotifications(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('اعلان\u200cها')),
      body: notifs.isEmpty
        ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.notifications_off_outlined, size: 56, color: AppColors.divider),
            SizedBox(height: 12),
            Text('اعلانی وجود ندارد', style: TextStyle(color: AppColors.textSecondary)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifs.length,
            itemBuilder: (_, i) {
              final n = notifs[i];
              final isRead = n['isRead'] == true;
              return Card(
                color: isRead ? Colors.white : AppColors.backgroundGreen,
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _typeColor(n['type']).withValues(alpha: 0.15),
                    child: Icon(_typeIcon(n['type']), color: _typeColor(n['type']), size: 20),
                  ),
                  title: Text(n['message'], style: TextStyle(fontSize: 13, fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(_timeAgo(n['createdAt']), style: const TextStyle(fontSize: 11)),
                  trailing: isRead ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle)),
                  onTap: () {
                    _ds.markNotificationRead(n['id']);
                    setState(() {});
                  },
                ),
              );
            },
          ),
    );
  }

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'request': return Icons.add_circle;
      case 'offer': return Icons.local_offer;
      case 'offer_accepted': return Icons.check_circle;
      case 'order_status': return Icons.update;
      case 'ticket': return Icons.support;
      case 'ticket_reply': return Icons.reply;
      case 'new_request': return Icons.notifications_active;
      default: return Icons.info;
    }
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'request': return AppColors.blue;
      case 'offer': return AppColors.orange;
      case 'offer_accepted': return AppColors.primaryGreen;
      case 'order_status': return AppColors.purple;
      case 'ticket': return AppColors.red;
      case 'ticket_reply': return AppColors.darkGreen;
      case 'new_request': return AppColors.orange;
      default: return AppColors.textSecondary;
    }
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} دقیقه پیش';
    if (diff.inHours < 24) return '${diff.inHours} ساعت پیش';
    return '${diff.inDays} روز پیش';
  }
}
