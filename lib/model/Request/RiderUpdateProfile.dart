// To parse this JSON data, do
//
//     final RiderUpdateProfilePutRequest = RiderUpdateProfilePutRequestFromJson(jsonString);

import 'dart:convert';

List<RiderUpdateProfilePutRequest> riderUpdateProfilePutRequestFromJson(
        String str) =>
    List<RiderUpdateProfilePutRequest>.from(
        json.decode(str).map((x) => RiderUpdateProfilePutRequest.fromJson(x)));

String riderUpdateProfilePutRequestToJson(
        List<RiderUpdateProfilePutRequest> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RiderUpdateProfilePutRequest {
  String fullname;
  String username;
  String email;
  String phone;
  String password;
  String image_profile;
  String license_plate;
  int uid;

  RiderUpdateProfilePutRequest({
    required this.fullname,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.image_profile,
    required this.license_plate,
    required this.uid,
  });

  factory RiderUpdateProfilePutRequest.fromJson(Map<String, dynamic> json) =>
      RiderUpdateProfilePutRequest(
        fullname: json["fullname"],
        username: json["username"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        image_profile: json["image_profile "],
        license_plate: json["license_plate"],
        uid: json["uid"],
      );

  Map<String, dynamic> toJson() => {
        "fullname": fullname,
        "username": username,
        "email": email,
        "phone": phone,
        "password": password,
        "image_profile": image_profile,
        "license_plate": license_plate,
        "uid": uid,
      };
}
