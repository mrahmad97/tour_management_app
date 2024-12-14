import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class PushNotificationService {
  // Method to retrieve the Firebase Cloud Messaging (FCM) access token
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "tour-management-app-29401",
      "private_key_id": "b601484333ebc0993eb6b0abbe421f05af25c07a",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC/413lqJ8zJJF7\nK+H/WgUB3VYHVg4N/hlME0KHkPxZxUhrelZCumCktw9E/03OYKjnt2eNxmcqfS6v\nkF9DP7M+8/B1HWVwGi3CIFJ1treML4gEMIEkUII5ZAx6aNq4oQ3LXGDHQ/DwZUbP\n3UHiY3E/BlZ8TfWXOlDPuHTDv7wZZo8tNilbaPksLYbZHu5JXHrR0b0LACPw+BAl\nEzVbiDe/gSTa2jx5lMm7yeDYEcOylbDLI3WF/Q0/XAoK9fv2i5kEGo6HLxc9FgkX\n1S9Sfl1YPVtxYywMkdHZuaDcAoctO/5tfxXlhbD+cOMzazCXnmGjDU3NhidPF6or\nNRIElIDvAgMBAAECggEAMwxu33kjmTyCQ41iG0e8i0lx6JO5O3m9CyMYkO4+ZDd6\n07UBG9FvgoJ82nM9JMlMRhDhyLLeoUwaTnSPE1nv+rB06QNACDm+sKVeqphIbk/6\n1Hp+8MVGT7RRKYOZpIKcI9zYlkp538phs0z+iRbBeu3ZtkobKvdFpm1BCw6IIQ1U\n1pP2Y4+9qKXHxHKPtzTgu/Ocp0IOWdyY0BzOzdDRXfIfbWzSW927g7PflN3JzEn6\n0rXQCQRH6lOvIIouieQwA4ema9Ggh0Xfy2ihms8khCA1/TVVeu/gQ8Uq76fN0Gls\nLitgC/IfxB3zBuJOSYQi0N8BzEa52Aw4+F9STTCsYQKBgQDisqvGdcMJ4W5q16vH\nwwdjJxHrAiPP4RHO0nqQl2ossegew4AioBlISvdDVL9tg7vMaqvhLVZQ4fvG88LS\nwq53/pys5iXP4LlPIf5h0iVgq1mbo8C2ngboUXLeZiN13HJHY9FaPbFpYuW8AU0U\nVW0/jdCJ1EYsu4KAu60Rcd1GXwKBgQDYsNs3ogfS457ftqYzhc9NA2LaUVr9mDBW\nEvrcM0np4y+MruhH2za1rURzAlq9hYdfEsx+4dD3JaFQ9n77vhv5XdSKsrqK9po0\nHp9b74vnO+v8GcMEB7nsscO3mPfB+sVUqr6DPQWTPJtU76Rtz6hPoT5P5kWKvRN+\nvF0aXSMvcQKBgCdcZGzh94pYpOZSKhZWK4swtnC6f2NRrdjePL+sOpgmD6p/wVjB\nuYIO2h3Lsi0eqVXV06AWUh1bD2881b/oY4icIbH3h+svFp3BxjxP04OUXMukRAqx\nJ3vg4HPzAgctzn3MvAXSHmKw9DiPdUWpi310bxfvTnvn1sHpVCRqQ8Q7AoGBANg/\nbxZPClXIuNVzltuWLzIhLfbH9/Fafup3WIiGWr4h7mMMbly/hRK7zrKj5+B5MIaN\n4SzCuOLcV+fPhxw+NfafUCv2f7mMrolTAiAiqFDkePYG05rjBwYSxUolSyP32hRL\nrYKVVEoC0tVproO0F7kYJnJgUIhLdvgkjRlxV1rRAoGBAMkuaV84Qnr7spekQMfj\nw802Qi+xUtUueB8YbJRyteXTVTco5TkQaemdYqBo889JiyyPjfzwcJSmbpwAmY8T\nb/0cd7mY9ezwfPMMUgD3aZfMJrQIEPMG/wKh5JqW+Tvkut7wnRmWbgf7v1WX6MLW\n8S6Ei8fLqO1jWdxdOwyRDXCa\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-gzl21@tour-management-app-29401.iam.gserviceaccount.com",
      "client_id": "113554880209895913164",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-gzl21%40tour-management-app-29401.iam.gserviceaccount.com",
    };

    List<String> scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    try {
      final auth.ServiceAccountCredentials credentials =
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson);

      final auth.AccessCredentials accessCredentials =
      await auth.obtainAccessCredentialsViaServiceAccount(credentials, scopes, http.Client());

      print('Access Token Generated Successfully');
      return accessCredentials.accessToken.data;
    } catch (e) {
      print('Error generating access token: $e');
      rethrow;
    }
  }
}

Future<void> sendNotificationToUsers(List<dynamic> tokens, String groupId) async {
  try {
    final String accessToken = await PushNotificationService.getAccessToken();

    for (String token in tokens) {
      final message = {
        "message": {
          "token": token,
          "notification": {
            "title": "New Route Added",
            "body": "A new route has been added to your group. Check it out!",
          },
          "data": {
            "type": "route", // Add custom fields here
            "groupId": groupId, // Example custom field
          },
        },
      };

      try {
        final response = await http.post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/tour-management-app-29401/messages:send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode(message),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully to token $token!');
        } else {
          print('Failed to send notification to token $token: ${response.body}');
        }
      } catch (e) {
        print('Error sending notification to token $token: $e');
      }
    }
  } catch (e) {
    print('Error in sending notifications: $e');
  }
}

Future<void> sendMemberNotificationToUsers(List<dynamic> tokens, String groupId) async {
  try {
    final String accessToken = await PushNotificationService.getAccessToken();

    for (String token in tokens) {
      final message = {
        "message": {
          "token": token,
          "notification": {
            "title": "A New Member Added to Group",
            "body": "A new member has been added to your group. Check it out!",
          },
          "data": {
            "type": "groupMember", // Add custom fields here
            "groupId": groupId, // Example custom field
          },
        },
      };

      try {
        final response = await http.post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/tour-management-app-29401/messages:send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode(message),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully to token $token!');
        } else {
          print('Failed to send notification to token $token: ${response.body}');
        }
      } catch (e) {
        print('Error sending notification to token $token: $e');
      }
    }
  } catch (e) {
    print('Error in sending notifications: $e');
  }
}


Future<void> sendChatNotificationToUsers(List<dynamic> tokens, String? user, String text, String? groupId) async {
  try {
    final String accessToken = await PushNotificationService.getAccessToken();

    for (String token in tokens) {
      final message = {
        "message": {
          "token": token,
          "notification": {
            "title": user,
            "body": text,
          },
          "data": {
            "type": "chat", // Add custom fields here
            "groupId": groupId, // Example custom field
          },
        },
      };

      try {
        final response = await http.post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/tour-management-app-29401/messages:send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode(message),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully to token $token!');
        } else {
          print('Failed to send notification to token $token: ${response.body}');
        }
      } catch (e) {
        print('Error sending notification to token $token: $e');
      }
    }
  } catch (e) {
    print('Error in sending notifications: $e');
  }
}
