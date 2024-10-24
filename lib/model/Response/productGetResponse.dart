// To parse this JSON data, do
//
//     final productGetResponse = productGetResponseFromJson(jsonString);

import 'dart:convert';

List<ProductGetResponse> productGetResponseFromJson(String str) => List<ProductGetResponse>.from(json.decode(str).map((x) => ProductGetResponse.fromJson(x)));

String productGetResponseToJson(List<ProductGetResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductGetResponse {
    int productId;
    int senderId;
    String nameProduct;
    String detailProduct;
    String imageProduct;
    String createdDate;

    ProductGetResponse({
        required this.productId,
        required this.senderId,
        required this.nameProduct,
        required this.detailProduct,
        required this.imageProduct,
        required this.createdDate,
    });

    factory ProductGetResponse.fromJson(Map<String, dynamic> json) => ProductGetResponse(
        productId: json["product_id"],
        senderId: json["sender_id"],
        nameProduct: json["name_product"],
        detailProduct: json["detail_product"],
        imageProduct: json["image_product"],
        createdDate: json["created_date"],
    );

    Map<String, dynamic> toJson() => {
        "product_id": productId,
        "sender_id": senderId,
        "name_product": nameProduct,
        "detail_product": detailProduct,
        "image_product": imageProduct,
        "created_date": createdDate,
    };
}
