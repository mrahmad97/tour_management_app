// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// import 'package:tour_management_app/functions/push_notification_service.dart';
//
//
// Future<void> sendNotificationToUsers(List<String> tokens) async {
//   final String accessToken = await PushNotificationService.getAccessToken();
//
//   try {
//     for (String token in tokens) {
//       final message = {
//         "message": {
//           "token": token, // HTTP v1 API sends notifications one token at a time
//           "notification": {
//             "title": "New Route Added",
//             "body": "A new route has been added to your group. Check it out!"
//           },
//         },
//       };
//
//       // Get the access token
//       final String accessToken = await PushNotificationService.getAccessToken();
//
//       // Debugging step to verify the access token
//       print('Generated Access Token: $accessToken');
//
//       // Sending the notification
//       final response = await http.post(
//         Uri.parse(
//             'https://fcm.googleapis.com/v1/projects/tour-management-app-29401/messages:send'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $accessToken', // HTTP v1 API authentication
//         },
//         body: json.encode(message),
//       );
//
//       // Log the response
//       if (response.statusCode == 200) {
//         print('Notification sent successfully to token $token!');
//       } else {
//         print('Failed to send notification: ${response.body}');
//       }
//     }
//   } catch (e) {
//     print('Error sending notification: $e');
//     print('Generated Access Token: $accessToken');
//
//   }
// }
