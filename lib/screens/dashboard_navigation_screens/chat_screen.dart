import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../models/chat_model.dart';
import '../../providers/user_provider.dart';

class ChatScreen extends StatefulWidget {
  final String? groupId; // Group ID for this chat screen

  const ChatScreen({super.key, this.groupId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  // Send a message to Firestore
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      final chatMessage = ChatModel(
        groupId: widget.groupId,
        senderId: userProvider.user?.uid,
        message: message,
        timestamp: DateTime.now(),
        isSent: true,
        isDelivered: false,
        isRead: false,
      );

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.groupId)
          .collection('messages')
          .add(chatMessage.toMap());

      _messageController.clear();

    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true) // Fetch latest messages first
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!.docs.map((doc) {
                  return ChatModel.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                  reverse: true, // Display latest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == userProvider.user?.uid;

                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),

          // Input Field
          _buildMessageInputField(),
        ],
      ),
    );
  }

  // Message bubble widget
  Widget _buildMessageBubble(ChatModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Display sender's name if available
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(message.senderId).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                  return const Text(
                    'Unknown User',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  );
                }
                final senderName = snapshot.data!['name'] ?? 'Unknown User';
                return Text(
                  senderName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),

            // Display media if available
            if (message.mediaUrl != null)
              Image.network(message.mediaUrl!, height: 150, width: 150, fit: BoxFit.cover),

            // Display message content
            if (message.message != null)
              Text(
                message.message!,
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 5),

            // Display timestamp
            Text(
              message.timestamp?.toString() ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }


  // Message input field widget
  Widget _buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => sendMessage(_messageController.text),
          ),
        ],
      ),
    );
  }
}
