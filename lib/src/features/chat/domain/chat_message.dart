import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime? timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parsedTimestamp;
    if (map['timestamp'] != null && map['timestamp'] is Timestamp) {
      parsedTimestamp = (map['timestamp'] as Timestamp).toDate();
    }

    return ChatMessage(
      id: docId,
      senderId: map['senderId']?.toString() ?? '',
      senderName: map['senderName']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      timestamp: parsedTimestamp,
      isRead: map['isRead'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}

class ChatRoom {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String? productId;
  final String? productTitle;
  final String? productImageUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCounts;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.participantNames,
    this.productId,
    this.productTitle,
    this.productImageUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCounts = const {},
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? parsedTime;
    if (map['lastMessageTime'] != null && map['lastMessageTime'] is Timestamp) {
      parsedTime = (map['lastMessageTime'] as Timestamp).toDate();
    }

    Map<String, String> names = {};
    if (map['participantNames'] != null && map['participantNames'] is Map) {
      names = Map<String, String>.from(map['participantNames']);
    }

    Map<String, int> unread = {};
    if (map['unreadCounts'] != null && map['unreadCounts'] is Map) {
      unread = Map<String, int>.from(
        (map['unreadCounts'] as Map).map((k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0)),
      );
    }

    List<String> participantsList = [];
    if (map['participants'] != null && map['participants'] is List) {
      participantsList = List<String>.from(map['participants']);
    }

    return ChatRoom(
      id: docId,
      participants: participantsList,
      participantNames: names,
      productId: map['productId']?.toString(),
      productTitle: map['productTitle']?.toString(),
      productImageUrl: map['productImageUrl']?.toString(),
      lastMessage: map['lastMessage']?.toString(),
      lastMessageTime: parsedTime,
      lastMessageSenderId: map['lastMessageSenderId']?.toString(),
      unreadCounts: unread,
    );
  }
}
