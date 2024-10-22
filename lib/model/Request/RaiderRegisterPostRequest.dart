// To parse this JSON data, do
//
//     final usersRegisterPostRequest = usersRegisterPostRequestFromJson(jsonString);

import 'dart:convert';

List<RiderRegisterPostRequest> riderRegisterPostRequestFromJson(String str) =>
    List<RiderRegisterPostRequest>.from(
        json.decode(str).map((x) => RiderRegisterPostRequest.fromJson(x)));

String riderRegisterPostRequestToJson(List<RiderRegisterPostRequest> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RiderRegisterPostRequest {
  String fullname;
  String username;
  String email;
  String phone;
  String password;
  String image_profile;
  String license_plateCtl;

  RiderRegisterPostRequest({
    required this.fullname,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.image_profile,
    required this.license_plateCtl,
  });

  factory RiderRegisterPostRequest.fromJson(Map<String, dynamic> json) =>
      RiderRegisterPostRequest(
        fullname: json["fullname"],
        username: json["username"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        image_profile: json["image_profile "],
        license_plateCtl: json["license_plateCtl"],
      );

  Map<String, dynamic> toJson() => {
        "fullname": fullname,
        "username": username,
        "email": email,
        "phone": phone,
        "password": password,
        "image_profile": image_profile,
        "license_plateCtl": license_plateCtl,
      };
}
