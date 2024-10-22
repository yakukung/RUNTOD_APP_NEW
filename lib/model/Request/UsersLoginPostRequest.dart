// To parse this JSON data, do
//
//     final usersLoginPostRequestDart = usersLoginPostRequestDartFromJson(jsonString);

import 'dart:convert';

UsersLoginPostRequest usersLoginPostRequestDartFromJson(String str) =>
    UsersLoginPostRequest.fromJson(json.decode(str));

String usersLoginPostRequestDartToJson(UsersLoginPostRequest data) =>
    json.encode(data.toJson());

class UsersLoginPostRequest {
  String usernameOrEmailOrPhone;
  String password;

  UsersLoginPostRequest({
    required this.usernameOrEmailOrPhone,
    required this.password,
  });

  factory UsersLoginPostRequest.fromJson(Map<String, dynamic> json) =>
      UsersLoginPostRequest(
        usernameOrEmailOrPhone: json["usernameOrEmailOrPhone"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "usernameOrEmailOrPhone": usernameOrEmailOrPhone,
        "password": password,
      };
}
