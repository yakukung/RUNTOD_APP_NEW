// To parse this JSON data, do
//
//     final usergetAlldata = usergetAlldataFromJson(jsonString);

import 'dart:convert';

List<UsergetAlldata> usergetAlldataFromJson(String str) => List<UsergetAlldata>.from(json.decode(str).map((x) => UsergetAlldata.fromJson(x)));

String usergetAlldataToJson(List<UsergetAlldata> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsergetAlldata {
    int uid;
    String fullname;
    String username;
    String email;
    String phone;
    String password;
    int type;
    int wallet;
    String? image;

    UsergetAlldata({
        required this.uid,
        required this.fullname,
        required this.username,
        required this.email,
        required this.phone,
        required this.password,
        required this.type,
        required this.wallet,
        required this.image,
    });

    factory UsergetAlldata.fromJson(Map<String, dynamic> json) => UsergetAlldata(
        uid: json["uid"],
        fullname: json["fullname"],
        username: json["username"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        type: json["type"],
        wallet: json["wallet"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "uid": uid,
        "fullname": fullname,
        "username": username,
        "email": email,
        "phone": phone,
        "password": password,
        "type": type,
        "wallet": wallet,
        "image": image,
    };
}
