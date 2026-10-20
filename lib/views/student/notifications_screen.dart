import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../models/notification_model.dart';
import '../../app/theme/app_theme.dart' as theme;
import '../../app/responsive/responsive_utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _notificationController = Get.put(NotificationController());
  final Set<String> _expandedNotifications = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Notifications'),
        actions: [
          if (_notificationController.studentUnreadCount > 0)
            TextButton(
              onPressed: () {
                _notificationController.markAllAsRead();
              },
              child: const Text(
                'Mark all read',
                style: TextStyle(fontSize: 14),
              ),
            ),
        ],
      ),
      body: Obx(
        () => _notificationController.studentNotifications.isEmpty
            ? _buildEmptyState()
            : _buildNotificationsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: ResponsiveUtils.responsiveIconSize(context, 80),
            color: theme.AppTheme.textSecondary,
          ),
          SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, 18),
              color: theme.AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: ResponsiveUtils.responsivePadding(context),
      itemCount: _notificationController.studentNotifications.length,
      itemBuilder: (context, index) {
        final notification = _notificationController.studentNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final isExpanded = _expandedNotifications.contains(notification.id);

    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.responsiveSpacing(context, 12),
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Mark as read when tapped
          if (!notification.isRead) {
            _notificationController.markAsRead(notification.id);
          }
          setState(() {
            if (isExpanded) {
              _expandedNotifications.remove(notification.id);
            } else {
              _expandedNotifications.add(notification.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isRead
                ? Colors.white
                : theme.AppTheme.primaryColor.withValues(alpha: 0.05),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.all(
                  ResponsiveUtils.responsiveSpacing(context, 16),
                ),
                leading: Container(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.responsiveSpacing(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: theme.AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.icon,
                    color: theme.AppTheme.primaryColor,
                    size: ResponsiveUtils.responsiveIconSize(context, 24),
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: notification.isRead
                        ? theme.AppTheme.textSecondary
                        : theme.AppTheme.textPrimary,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 4)),
                    Text(
                      isExpanded
                          ? notification.message
                          : notification.message.length > 50
                              ? '${notification.message.substring(0, 50)}...'
                              : notification.message,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                        color: theme.AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(context, 12),
                        color: theme.AppTheme.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (notification.isRead)
                      const SizedBox.shrink()
                    else
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: theme.AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.responsiveSpacing(context, 16),
                    vertical: ResponsiveUtils.responsiveSpacing(context, 8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          ResponsiveUtils.responsiveSpacing(context, 12),
                        ),
                        decoration: BoxDecoration(
                          color: theme.AppTheme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          notification.fullMessage ?? notification.message,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                            color: theme.AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 8)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _expandedNotifications.remove(notification.id);
                              });
                            },
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Close'),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.AppTheme.primaryColor,
                            ),
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
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
