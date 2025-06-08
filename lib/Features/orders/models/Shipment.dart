// lib/Features/orders/models/shipment.dart

class Shipment {
  String? code;
  int? type;
  int? status;
  int? ordersCount;
  int? merchantsCount;
  String? id;
  bool? deleted;
  String? creationDate;

  Shipment({
    this.code,
    this.ordersCount,
    this.merchantsCount,
    this.type,
    this.status,
    this.id,
    this.deleted,
    this.creationDate,
  });

  Shipment.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    ordersCount = json['ordersCount'];
    merchantsCount = json['merchantsCount'];
    type = json['type'];
    status = json['status'];
    id = json['id'];
    deleted = json['deleted'];
    creationDate = json['creationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['code'] = code;
    data['ordersCount'] = ordersCount;
    data['merchantsCount'] = merchantsCount;
    data['type'] = type;
    data['status'] = status;
    data['id'] = id;
    data['deleted'] = deleted;
    data['creationDate'] = creationDate;
    return data;
  }
}