// To parse this JSON data, do
//
//     final ImageStatusPostRequest = ImageStatusPostRequestFromJson(jsonString);

import 'dart:convert';

List<ImageStatusPostRequest> imageStatusPostRequestFromJson(String str) =>
    List<ImageStatusPostRequest>.from(
        json.decode(str).map((x) => ImageStatusPostRequest.fromJson(x)));

String imageStatusPostRequestToJson(List<ImageStatusPostRequest> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ImageStatusPostRequest {
  int order_id;
  int status;
  String image_status;
  int uid;

  ImageStatusPostRequest({
    required this.order_id,
    required this.uid,
    required this.status,
    required this.image_status,
  });

  factory ImageStatusPostRequest.fromJson(Map<String, dynamic> json) =>
      ImageStatusPostRequest(
        order_id: json["order_id"],
        uid: json["uid"],
        status: json["status"],
        image_status: json["image_status"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": order_id,
        "uid": uid,
        "status": status,
        "image_status": image_status,
      };
}
