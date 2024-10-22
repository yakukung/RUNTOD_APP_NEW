// To parse this JSON data, do
//
//     final UsersUpdateProfilePutRequest = UsersUpdateProfilePutRequestFromJson(jsonString);

import 'dart:convert';

List<UsersUpdateProfilePutRequest> usersUpdateProfilePutRequestFromJson(
        String str) =>
    List<UsersUpdateProfilePutRequest>.from(
        json.decode(str).map((x) => UsersUpdateProfilePutRequest.fromJson(x)));

String usersUpdateProfilePutRequestToJson(
        List<UsersUpdateProfilePutRequest> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsersUpdateProfilePutRequest {
  String fullname;
  String username;
  String email;
  String phone;
  String password;
  String image_profile;
  String address;
  int uid;

  UsersUpdateProfilePutRequest({
    required this.fullname,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.image_profile,
    required this.address,
    required this.uid,
  });

  factory UsersUpdateProfilePutRequest.fromJson(Map<String, dynamic> json) =>
      UsersUpdateProfilePutRequest(
        fullname: json["fullname"],
        username: json["username"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        image_profile: json["image_profile "],
        address: json["address"],
        uid: json["uid"],
      );

  Map<String, dynamic> toJson() => {
        "fullname": fullname,
        "username": username,
        "email": email,
        "phone": phone,
        "password": password,
        "image_profile": image_profile,
        "address": address,
        "uid": uid,
      };
}
