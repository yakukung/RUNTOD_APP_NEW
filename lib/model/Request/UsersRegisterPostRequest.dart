// To parse this JSON data, do
//
//     final usersRegisterPostRequest = usersRegisterPostRequestFromJson(jsonString);

import 'dart:convert';

List<UsersRegisterPostRequest> usersRegisterPostRequestFromJson(String str) =>
    List<UsersRegisterPostRequest>.from(
        json.decode(str).map((x) => UsersRegisterPostRequest.fromJson(x)));

String usersRegisterPostRequestToJson(List<UsersRegisterPostRequest> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsersRegisterPostRequest {
  String fullname;
  String username;
  String email;
  String phone;
  String password;
  String image_profile;
  String address;

  UsersRegisterPostRequest({
    required this.fullname,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.image_profile,
    required this.address,
  });

  factory UsersRegisterPostRequest.fromJson(Map<String, dynamic> json) =>
      UsersRegisterPostRequest(
        fullname: json["fullname"],
        username: json["username"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        image_profile: json["image_profile "],
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "fullname": fullname,
        "username": username,
        "email": email,
        "phone": phone,
        "password": password,
        "image_profile": image_profile,
        "address": address,
      };
}
