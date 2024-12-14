class SignupModel {
  String name;
  String email;
  String password;
  String confirmPassword;
  String userType; // Example: "User" or "Manager"
  String phoneNumber;
  String imageURL;

  SignupModel({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.userType,
    required this.phoneNumber,
    required this.imageURL,
  });


}
