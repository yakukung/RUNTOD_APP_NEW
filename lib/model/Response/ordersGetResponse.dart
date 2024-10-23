// To parse this JSON data, do
//
//     final OrdersGetData = OrdersGetDataFromJson(jsonString);

import 'dart:convert';

List<OrdersGetData> ordersGetDataFromJson(String str) =>
    List<OrdersGetData>.from(
        json.decode(str).map((x) => OrdersGetData.fromJson(x)));

String ordersGetDataToJson(List<OrdersGetData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrdersGetData {
  int order_id;
  String sender_name;
  String receiver_name;
  String sender_address;
  String receiver_address;
  int status;
  int total_orders;

  OrdersGetData({
    required this.order_id,
    required this.sender_name,
    required this.sender_address,
    required this.receiver_name,
    required this.receiver_address,
    required this.status,
    required this.total_orders,
  });

  factory OrdersGetData.fromJson(Map<String, dynamic> json) => OrdersGetData(
        order_id: json["order_id"],
        sender_name: json["sender_name"],
        sender_address: json["sender_address"],
        receiver_name: json["receiver_name"],
        receiver_address: json["receiver_address"],
        status: json["status"],
        total_orders: json["total_orders"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": order_id,
        "sender_name": sender_name,
        "sender_address": sender_address,
        "receiver_name": receiver_name,
        "receiver_address": receiver_address,
        "status": status,
        "total_orders": total_orders,
      };
}
