import 'package:flutter/material.dart';
import '../data/notification_repository.dart';

class _NotiColors {
  static const Color bordo = Color(0xFF722F37);
  static const Color bordoLight = Color(0xFF8B3A42);
  static const Color background = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF242424);
  static const Color inputBg = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color green = Color(0xFF4CAF50);
  static const Color blue = Color(0xFF42A5F5);
  static const Color orange = Color(0xFFFF9800);
  static const Color red = Color(0xFFE53935);
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'favorite':
        return Icons.favorite_rounded;
      case 'message':
        return Icons.chat_bubble_rounded;
      case 'sold':
        return Icons.check_circle_rounded;
      case 'new_product':
        return Icons.new_releases_rounded;
      case 'price_drop':
        return Icons.trending_down_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'favorite':
        return _NotiColors.red;
      case 'message':
        return _NotiColors.blue;
      case 'sold':
        return _NotiColors.green;
      case 'new_product':
        return _NotiColors.orange;
      case 'price_drop':
        return _NotiColors.green;
      default:
        return _NotiColors.bordo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notiRepo = NotificationRepository();

    return Scaffold(
      backgroundColor: _NotiColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _NotiColors.bordo.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: _NotiColors.bordo,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Obavjestenja',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _NotiColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Sve vase aktivnosti na jednom mjestu',
                          style: TextStyle(
                            fontSize: 13,
                            color: _NotiColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mark all read button
                  GestureDetector(
                    onTap: () {
                      notiRepo.markAllAsRead();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Sva obavjestenja oznacena kao procitana'),
                          backgroundColor: _NotiColors.cardBg,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _NotiColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _NotiColors.textMuted.withOpacity(0.15)),
                      ),
                      child: const Icon(Icons.done_all_rounded, color: _NotiColors.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Notifications list
            Expanded(
              child: StreamBuilder<List<AppNotification>>(
                stream: notiRepo.getNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _NotiColors.bordo),
                    );
                  }

                  final notifications = snapshot.data ?? [];

                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: _NotiColors.cardBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _NotiColors.textMuted.withOpacity(0.15),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              size: 44,
                              color: _NotiColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Nema obavjestenja',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _NotiColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 48),
                            child: Text(
                              'Kada neko lajka vas artikal, posalje poruku ili se desi nesto novo, pojavit ce se ovdje.',
                              style: TextStyle(fontSize: 14, color: _NotiColors.textMuted, height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group by today, yesterday, earlier
                  final now = DateTime.now();
                  final todayItems = <AppNotification>[];
                  final yesterdayItems = <AppNotification>[];
                  final earlierItems = <AppNotification>[];

                  for (final n in notifications) {
                    if (n.timestamp == null) {
                      earlierItems.add(n);
                      continue;
                    }
                    final diff = now.difference(n.timestamp!);
                    if (diff.inDays == 0) {
                      todayItems.add(n);
                    } else if (diff.inDays == 1) {
                      yesterdayItems.add(n);
                    } else {
                      earlierItems.add(n);
                    }
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (todayItems.isNotEmpty) ...[
                        _buildSectionHeader('Danas'),
                        ...todayItems.map((n) => _buildNotificationTile(context, n, notiRepo)),
                      ],
                      if (yesterdayItems.isNotEmpty) ...[
                        _buildSectionHeader('Jucer'),
                        ...yesterdayItems.map((n) => _buildNotificationTile(context, n, notiRepo)),
                      ],
                      if (earlierItems.isNotEmpty) ...[
                        _buildSectionHeader('Ranije'),
                        ...earlierItems.map((n) => _buildNotificationTile(context, n, notiRepo)),
                      ],
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _NotiColors.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    AppNotification notification,
    NotificationRepository notiRepo,
  ) {
    final iconColor = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);

    // Format time
    String timeText = '';
    if (notification.timestamp != null) {
      final diff = DateTime.now().difference(notification.timestamp!);
      if (diff.inMinutes < 1) {
        timeText = 'Upravo sada';
      } else if (diff.inHours < 1) {
        timeText = 'Prije ${diff.inMinutes}m';
      } else if (diff.inDays < 1) {
        timeText = 'Prije ${diff.inHours}h';
      } else {
        timeText = 'Prije ${diff.inDays}d';
      }
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
      ),
      onDismissed: (_) => notiRepo.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            notiRepo.markAsRead(notification.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.transparent
                : _NotiColors.bordo.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: notification.isRead
                ? null
                : Border.all(color: _NotiColors.bordo.withOpacity(0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                              color: _NotiColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _NotiColors.bordo,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _NotiColors.textMuted,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 11,
                        color: notification.isRead
                            ? _NotiColors.textMuted.withOpacity(0.6)
                            : _NotiColors.bordoLight,
                        fontWeight: FontWeight.w500,
                      ),
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
}
