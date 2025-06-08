// lib/Features/orders/models/create_shipment_request.dart

class CreateShipmentRequest {
  List<OrderShipmentItem> orders;

  CreateShipmentRequest({required this.orders});

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((order) => order.toJson()).toList(),
    };
  }
}

class OrderShipmentItem {
  String orderId;

  OrderShipmentItem({required this.orderId});

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
    };
  }
}