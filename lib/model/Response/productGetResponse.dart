// To parse this JSON data, do
//
//     final productGetResponse = productGetResponseFromJson(jsonString);

import 'dart:convert';

List<ProductGetResponse> productGetResponseFromJson(String str) =>
    List<ProductGetResponse>.from(
        json.decode(str).map((x) => ProductGetResponse.fromJson(x)));

String productGetResponseToJson(List<ProductGetResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductGetResponse {
  int orderItemId;
  int orderId;
  String senderId;
  String nameItem;
  String detailItem;
  String imageProduct;
  String createdDate;

  ProductGetResponse({
    required this.orderItemId,
    required this.orderId,
    required this.senderId,
    required this.nameItem,
    required this.detailItem,
    required this.imageProduct,
    required this.createdDate,
  });

  factory ProductGetResponse.fromJson(Map<String, dynamic> json) =>
      ProductGetResponse(
        orderItemId: json["order_item_id"],
        orderId: json["order_id"],
        senderId: json["sender_id"],
        nameItem: json["name_item"],
        detailItem: json["detail_item"],
        imageProduct: json["image_product"],
        createdDate: json["created_date"],
      );

  Map<String, dynamic> toJson() => {
        "order_item_id": orderItemId,
        "order_id": orderId,
        "sender_id": senderId,
        "name_item": nameItem,
        "detail_item": detailItem,
        "image_product": imageProduct,
        "created_date": createdDate,
      };
}
