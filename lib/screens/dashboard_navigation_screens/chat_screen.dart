import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/colors.dart';
import '../../functions/media_upload_download.dart';
import '../../functions/push_notification_service.dart';
import '../../models/chat_model.dart';
import '../../providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  final String? groupId;

  const ChatScreen({super.key, required this.groupId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode(); // FocusNode for the text field
  late final UserProvider userProvider;
  final MediaUploadDownload mediaHandler = MediaUploadDownload();
  dynamic _pickedImage; // Store the picked image
  String _imageName = ''; // Display the image name before sending

  // Function to request necessary permissions
  Future<void> requestPermissions() async {
    if (!kIsWeb) {
      await Permission.storage.request();
    }
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    requestPermissions();
  }

  // Function to handle sending text messages
  Future<void> _sendTextMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty || _pickedImage != null) {
      String? imageUrl;

      // If an image is picked, upload it first
      if (_pickedImage != null) {
        imageUrl = await mediaHandler.uploadImageToSupabase(_pickedImage);
        if (imageUrl == null) {
          print("Image upload failed.");
          return;
        }
        print("Image uploaded successfully. URL: $imageUrl");
      }


      // Send the message to Firebase Firestore with the image URL (if available)
      // Create the message using the ChatModel
      final chatMessage = ChatModel(
        groupId: widget.groupId,
        senderId: userProvider.user?.uid,
        message: messageText.isNotEmpty ? messageText : null,
        mediaUrl: imageUrl,
        timestamp: DateTime.now(),
        isRead: false,
        isSent: true,
        isDelivered: false,
      );

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.groupId)
          .collection('messages')
          .add(chatMessage.toMap());

      // Fetch the group members (excluding the manager)
      final groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      final groupMembers = List<String>.from(groupSnapshot['members']);




      // Fetch FCM tokens of the group members (excluding the manager)
      final tokens = await Future.wait(groupMembers.map((userId) async {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        return userDoc['fcmToken']; // Get the FCM token for each user
      }));

      await sendChatNotificationToUsers(tokens,userProvider.user?.displayName,messageText, widget.groupId);

      _messageController.clear();
      setState(() {
        _pickedImage = null; // Clear picked image after sending
        _imageName = ''; // Reset image name
      });
    }
  }

  // Function to handle image attachment and display image name
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // First perform async work
      final imageBytes = kIsWeb
          ? await pickedFile.readAsBytes() // For web: read bytes
          : null; // For mobile/desktop: image will be a File, no need to read bytes here

      // Then update the state
      setState(() {
        _pickedImage = kIsWeb
            ? imageBytes
            : File(pickedFile.path); // Set the image based on platform
        _imageName = pickedFile.name; // Store the image name
      });
    } else {
      print('No image selected.');
    }
  }

  // Widget to build the input field
  Widget _buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!kIsWeb) {
                  _messageFocusNode.requestFocus(); // Focus the text field
                }
              },
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                onTap: () {
                  if (!kIsWeb) {
                    FocusScope.of(context).requestFocus(_messageFocusNode);
                  }
                },
              ),
            ),
          ),
          if (_imageName.isNotEmpty)
            Text(_imageName), // Display the picked image name
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendTextMessage,
          ),
        ],
      ),
    );
  }

  // Widget to build message bubbles
  Widget _buildMessageBubble(ChatModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryColor : AppColors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty)
              isMe
                  ? Image.network(message.mediaUrl!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover) // Display local image for self
                  : GestureDetector(
                      onTap: () {
                        // Add download functionality for others
                        print('Download link: ${message.mediaUrl}');
                      },
                      child: Image.network(message.mediaUrl!,
                          height: 150, width: 150, fit: BoxFit.cover),
                    ),
            if (message.message != null)
              Text(
                message.message!,
                style: TextStyle(
                    color:
                        isMe ? AppColors.surfaceColor : AppColors.primaryColor),
              ),
            Text(
              message.timestamp != null
                  ? DateFormat('hh:mm a').format(message.timestamp!)
                  : '',
              style: TextStyle(
                  fontSize: 10,
                  color:
                      isMe ? AppColors.surfaceColor : AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard when tapping outside
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat', style: TextStyle(color: AppColors.surfaceColor)),
          backgroundColor: AppColors.primaryColor,
        ),
        backgroundColor: AppColors.surfaceColor,
        resizeToAvoidBottomInset: true, // Enable resizing to avoid bottom inset
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.groupId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No messages yet.'));
                  }

                  final messages = snapshot.data!.docs.map((doc) {
                    return ChatModel.fromMap(doc.data() as Map<String, dynamic>);
                  }).toList();

                  return ListView.builder(
                    reverse: true,
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
            _buildMessageInputField(), // Input field stays at the bottom
          ],
        ),
      ),
    );
  }

}
