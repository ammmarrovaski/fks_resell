import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppNotification {
  final String id;
  final String type; // 'favorite', 'message', 'sold', 'new_product'
  final String title;
  final String body;
  final String? productId;
  final String? chatRoomId;
  final String? fromUserId;
  final String? fromUserName;
  final DateTime? timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.productId,
    this.chatRoomId,
    this.fromUserId,
    this.fromUserName,
    this.timestamp,
    this.isRead = false,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parsedTime;
    if (map['timestamp'] != null && map['timestamp'] is Timestamp) {
      parsedTime = (map['timestamp'] as Timestamp).toDate();
    }

    return AppNotification(
      id: docId,
      type: map['type']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      productId: map['productId']?.toString(),
      chatRoomId: map['chatRoomId']?.toString(),
      fromUserId: map['fromUserId']?.toString(),
      fromUserName: map['fromUserName']?.toString(),
      timestamp: parsedTime,
      isRead: map['isRead'] == true,
    );
  }
}

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a notification for a user
  Future<void> createNotification({
    required String toUserId,
    required String type,
    required String title,
    required String body,
    String? productId,
    String? chatRoomId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Don't notify yourself
    if (toUserId == currentUser.uid) return;

    await _firestore
        .collection('users')
        .doc(toUserId)
        .collection('notifications')
        .add({
      'type': type,
      'title': title,
      'body': body,
      'productId': productId ?? '',
      'chatRoomId': chatRoomId ?? '',
      'fromUserId': currentUser.uid,
      'fromUserName': currentUser.displayName ?? currentUser.email ?? 'Korisnik',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// Stream notifications for current user
  Stream<List<AppNotification>> getNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppNotification.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Get unread count
  Stream<int> getUnreadCount() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
