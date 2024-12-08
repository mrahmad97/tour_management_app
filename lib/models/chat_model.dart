import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String? id; // Unique message ID
  final String? groupId; // Group ID the message belongs to
  final String? senderId; // Sender's user ID
  final String? message; // Text message content
  final String? mediaUrl; // URL of any attached media (image, video, etc.)
  final DateTime? timestamp; // Time the message was sent
  final bool? isRead; // Whether the message has been read
  final bool? isSent; // Whether the message has been sent successfully
  final bool? isDelivered; // Whether the message has been delivered successfully

  ChatModel({
    this.id,
    this.groupId,
    this.senderId,
    this.message,
    this.mediaUrl,
    this.timestamp,
    this.isRead,
    this.isSent,
    this.isDelivered,
  });

  // Factory method to create a ChatModel from Firestore data
  factory ChatModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return ChatModel(
      id: id,
      groupId: data['groupId'] as String?,
      senderId: data['senderId'] as String?,
      message: data['message'] as String?,
      mediaUrl: data['mediaUrl'] as String?,
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
      isRead: data['isRead'] as bool? ?? false,
      isSent: data['isSent'] as bool? ?? true,
      isDelivered: data['isDelivered'] as bool? ?? false,
    );
  }

  // Convert a ChatModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'senderId': senderId,
      'message': message,
      'mediaUrl': mediaUrl,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'isRead': isRead ?? false,
      'isSent': isSent ?? true,
      'isDelivered': isDelivered ?? false,
    };
  }

  // Copy with method to create a modified instance
  ChatModel copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? message,
    String? mediaUrl,
    DateTime? timestamp,
    bool? isRead,
    bool? isSent,
    bool? isDelivered,
  }) {
    return ChatModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }

  @override
  String toString() {
    return 'ChatModel{id: $id, groupId: $groupId, senderId: $senderId, message: $message, mediaUrl: $mediaUrl, timestamp: $timestamp, isRead: $isRead, isSent: $isSent, isDelivered: $isDelivered}';
  }
}
