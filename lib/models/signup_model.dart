class SignupModel {
  String name;
  String email;
  String password;
  String confirmPassword;
  String userType; // Example: "User" or "Manager"

  SignupModel({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.userType,
  });


}
