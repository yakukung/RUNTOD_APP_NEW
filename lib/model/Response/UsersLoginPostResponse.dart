import 'dart:convert';

List<UsersLoginPostResponse> usersLoginPostResponseFromJson(String str) =>
    List<UsersLoginPostResponse>.from(
        json.decode(str).map((x) => UsersLoginPostResponse.fromJson(x)));

String usersLoginPostResponseToJson(List<UsersLoginPostResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsersLoginPostResponse {
  int uid;
  String fullname;
  String username;
  String email;
  String phone;
  String? address;
  int type;
  String? imageProfile; // เปลี่ยนชื่อจาก image เป็น imageProfile
  String? licensePlate; // เปลี่ยนชื่อจาก license_plate เป็น licensePlate
  String password;

  UsersLoginPostResponse({
    required this.uid,
    required this.fullname,
    required this.username,
    required this.email,
    required this.phone,
    required this.type,
    this.licensePlate,
    this.imageProfile,
    this.address,
    required this.password,
  });

  factory UsersLoginPostResponse.fromJson(Map<String, dynamic> json) =>
      UsersLoginPostResponse(
        uid: json["uid"],
        fullname: json["fullname"] ?? '',
        username: json["username"] ?? '',
        email: json["email"] ?? '',
        phone: json["phone"] ?? '',
        address: json["address"] ?? '',
        type: json["type"],
        imageProfile: json["image_profile"] ?? '', // แก้ไขให้ตรงกับ JSON
        licensePlate: json["license_plate"] ?? '', // แก้ไขให้ตรงกับ JSON
        password: json["password"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "fullname": fullname,
        "username": username,
        "email": email,
        "phone": phone,
        "address": address,
        "type": type,
        "license_plate": licensePlate, // ใช้ licensePlate
        "image_profile": imageProfile, // ใช้ imageProfile
        "password": password,
      };
}
