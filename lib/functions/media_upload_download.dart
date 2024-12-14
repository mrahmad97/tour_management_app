import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class MediaUploadDownload {
  // Function to upload an image to Supabase
  Future<String?> uploadImageToSupabase(dynamic imageFile) async {
    try {
      // Create a unique file name for the image
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Reference to the 'chats' bucket
      final storage = Supabase.instance.client.storage.from('chats');

      if (kIsWeb) {
        // Web platform: handle Uint8List for web
        if (imageFile is Uint8List) {
          await storage.uploadBinary(fileName, imageFile);
        } else if (imageFile is File) {
          await storage.upload(fileName, imageFile);
        } else {
          print("Invalid image type for web.");
          return null;
        }
      } else {
        // Mobile/Desktop platform: handle File
        if (imageFile is File) {
          await storage.upload(fileName, imageFile);
        } else {
          print("Invalid image type for mobile/desktop.");
          return null;
        }
      }

      // Generate the public URL for the uploaded image
      String publicUrl = storage.getPublicUrl(fileName);

      // Return the public URL
      return publicUrl;
    } catch (e) {
      // Catch any exceptions and print the error
      print('Error uploading image: $e');
      return null;
    }
  }

}
