import 'package:flutter/material.dart' hide Notification;
import 'package:intl/intl.dart';

import '../constant.dart';
import '../service/DatabaseHelper.dart';
import '../service/NotificationService.dart';
import '../service/SmartArabicStyle.dart';
import '../service/SmartArabicText.dart';
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Notification> _notifications = [];
  int _unreadCount = 0;
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notifications = await _dbHelper.getAllNotifications();
    final unreadCount = await _dbHelper.getUnreadCount();

    setState(() {
      _notifications = notifications;
      _unreadCount = unreadCount;
    });
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:SmartArabicText(
          text: 'الإشعارات',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            Badge(
              label: Text(_unreadCount.toString()),
              child: IconButton(
                icon: const Icon(Icons.mark_email_read),
                onPressed: _markAllAsRead,
                tooltip: 'جعل الإشعارات مقرؤة',
              ),
            ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('حذف كل الإشعارات'),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear') {
                _clearAllNotifications();
              }
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا يوجد إشعارات',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView.builder(
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return _buildNotificationItem(notification);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Notification notification) {
    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id!);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification.isRead ? Colors.white : Colors.blue[50],
        child: InkWell(
          onTap: () => _markAsRead(notification.id!),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: notification.isRead ? Colors.grey[300] : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.category),
                    color: notification.isRead ? Colors.grey : Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Time and actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(notification.timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            children: [
                              if (notification.data.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.info_outline, size: 16),
                                  onPressed: () => _showNotificationDetails(notification),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              IconButton(
                                icon: Icon(
                                  notification.isRead
                                      ? Icons.mark_email_unread
                                      : Icons.mark_email_read,
                                  size: 16,
                                ),
                                onPressed: () => _toggleReadStatus(notification),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'order':
        return Icons.shopping_bag;
      case 'promotion':
        return Icons.local_offer;
      case 'alert':
        return Icons.warning;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  void _showNotificationDetails(Notification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.body),
              const SizedBox(height: 16),
              if (notification.data.isNotEmpty) ...[
                const Text(
                  'بيانات إضافية:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...notification.data.entries.map(
                      (entry) => Text('${entry.key}: ${entry.value}'),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'الوقت: ${DateFormat('dd MMM yyyy, hh:mm a').format(notification.timestamp)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
  Future<void> _toggleReadStatus(Notification notification) async {
    if (notification.isRead) {
      // Re-mark as unread (you'll need to add this method to DatabaseHelper)
      // For simplicity, we'll just reload
      await _loadNotifications();
    } else {
      await _dbHelper.markAsRead(notification.id!);
      await _loadNotifications();
    }
  }

  Future<void> _markAsRead(int id) async {
    await _dbHelper.markAsRead(id);
    await _loadNotifications();
  }
  Future<void> _markAllAsRead() async {
    await _dbHelper.markAllAsRead();
    await _loadNotifications();
  }
  Future<void> _deleteNotification(int id) async {
    await _dbHelper.deleteNotification(id);
    await _loadNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف الإشعارات')),
    );
  }
  Future<void> _clearAllNotifications() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('حذف جميع الإشعارات'),
        content: const Text('هل انت متأكد من حذف الإشعارات ؟?'),
        actions: [
          TextButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.primaryBlue)),
            onPressed: () {
              Navigator.of(context).pop();

            },
            child: Text("إلغاء" , style: SmartArabicTextStyle.create(context: context,
                baseSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700),),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbHelper.clearAllNotifications();
              await _loadNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف جميع الإشعارات')),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}