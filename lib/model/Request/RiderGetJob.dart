// To parse this JSON data, do
//
//     final RiderGetJobRequest = RiderGetJobRequestFromJson(jsonString);

import 'dart:convert';

List<RiderGetJobRequest> riderGetJobRequestFromJson(String str) =>
    List<RiderGetJobRequest>.from(
        json.decode(str).map((x) => RiderGetJobRequest.fromJson(x)));

String riderGetJobRequestToJson(List<RiderGetJobRequest> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RiderGetJobRequest {
  int uid;
  int order_id;

  RiderGetJobRequest({
    required this.uid,
    required this.order_id,
  });

  factory RiderGetJobRequest.fromJson(Map<String, dynamic> json) =>
      RiderGetJobRequest(
        uid: json["uid"],
        order_id: json["order_id"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "order_id": order_id,
      };
}
