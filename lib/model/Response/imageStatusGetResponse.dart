// To parse this JSON data, do
//
//     final ImageStatusGetResponse = ImageStatusGetResponseFromJson(jsonString);

import 'dart:convert';

List<ImageStatusGetResponse> imageStatusGetResponseFromJson(String str) =>
    List<ImageStatusGetResponse>.from(
        json.decode(str).map((x) => ImageStatusGetResponse.fromJson(x)));

String imageStatusGetResponseToJson(List<ImageStatusGetResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ImageStatusGetResponse {
  int order_id;
  int status;
  String image_status;

  ImageStatusGetResponse({
    required this.order_id,
    required this.status,
    required this.image_status,
  });

  factory ImageStatusGetResponse.fromJson(Map<String, dynamic> json) =>
      ImageStatusGetResponse(
        order_id: json["order_id"],
        status: json["status"],
        image_status: json["image_status"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": order_id,
        "status": status,
        "image_status": image_status,
      };
}
