import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/chat_message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates or finds existing chat room for a product between two users
  Future<String> getOrCreateChatRoom({
    required String otherUserId,
    required String otherUserName,
    String? productId,
    String? productTitle,
    String? productImageUrl,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Korisnik nije prijavljen');

    final currentUid = currentUser.uid;
    final currentName = currentUser.displayName ?? currentUser.email ?? 'Korisnik';

    // Look for existing chat room with same participants and product
    Query query = _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUid);

    final snapshot = await query.get();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final participants = List<String>.from(data['participants'] ?? []);
      final roomProductId = data['productId']?.toString();

      if (participants.contains(otherUserId)) {
        // If product-specific chat, match product too
        if (productId != null && roomProductId == productId) {
          return doc.id;
        }
        // If general chat (no product), match no-product rooms
        if (productId == null && (roomProductId == null || roomProductId.isEmpty)) {
          return doc.id;
        }
      }
    }

    // Create new chat room
    final roomRef = await _firestore.collection('chatRooms').add({
      'participants': [currentUid, otherUserId],
      'participantNames': {
        currentUid: currentName,
        otherUserId: otherUserName,
      },
      'productId': productId ?? '',
      'productTitle': productTitle ?? '',
      'productImageUrl': productImageUrl ?? '',
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': '',
      'unreadCounts': {
        currentUid: 0,
        otherUserId: 0,
      },
      'createdAt': FieldValue.serverTimestamp(),
    });

    return roomRef.id;
  }

  /// Send a message in a chat room
  Future<void> sendMessage(String chatRoomId, String text) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Korisnik nije prijavljen');

    final currentUid = currentUser.uid;
    final currentName = currentUser.displayName ?? currentUser.email ?? 'Korisnik';

    final message = {
      'senderId': currentUid,
      'senderName': currentName,
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    // Add message to subcollection
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(message);

    // Get chat room to find other participant
    final roomDoc = await _firestore.collection('chatRooms').doc(chatRoomId).get();
    final roomData = roomDoc.data();
    if (roomData != null) {
      final participants = List<String>.from(roomData['participants'] ?? []);
      final otherUserId = participants.firstWhere((id) => id != currentUid, orElse: () => '');

      // Update chat room with last message info and increment unread for other user
      Map<String, dynamic> updateData = {
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': currentUid,
      };

      if (otherUserId.isNotEmpty) {
        updateData['unreadCounts.$otherUserId'] = FieldValue.increment(1);
      }

      await _firestore.collection('chatRooms').doc(chatRoomId).update(updateData);
    }
  }

  /// Stream messages for a chat room
  Stream<List<ChatMessage>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Stream all chat rooms for current user
  Stream<List<ChatRoom>> getChatRooms() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatRoom.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Mark messages as read when opening a chat
  Future<void> markAsRead(String chatRoomId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'unreadCounts.${currentUser.uid}': 0,
    });
  }

  /// Get total unread count across all chats
  Stream<int> getTotalUnreadCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final unreadCounts = data['unreadCounts'] as Map<String, dynamic>? ?? {};
        total += (unreadCounts[currentUser.uid] as num?)?.toInt() ?? 0;
      }
      return total;
    });
  }

  /// Delete a chat room
  Future<void> deleteChatRoom(String chatRoomId) async {
    // Delete all messages first
    final messages = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_firestore.collection('chatRooms').doc(chatRoomId));
    await batch.commit();
  }
}
