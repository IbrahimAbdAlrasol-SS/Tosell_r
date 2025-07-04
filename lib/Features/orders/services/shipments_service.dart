// lib/Features/orders/services/shipments_service.dart

import 'package:Tosell/Features/orders/models/shipment.dart';
import 'package:Tosell/Features/orders/models/create_shipment_request.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';

class ShipmentsService {
  final BaseClient<Shipment> baseClient;

  ShipmentsService()
      : baseClient =
            BaseClient<Shipment>(fromJson: (json) => Shipment.fromJson(json));

  /// Get all shipments with pagination
  Future<ApiResponse<Shipment>> getAll({
    int page = 1,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      var result = await baseClient.getAll(
        endpoint: '/shipment/merchant/my-shipments',
        page: page,
        queryParams: queryParams,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Get shipment details by ID
  Future<Shipment?> getShipmentById({required String id}) async {
    try {
      var result = await baseClient.getById(
        endpoint: '/shipment',
        id: id,
      );
      return result.singleData;
    } catch (e) {
      rethrow;
    }
  }

  /// Create pickup shipment
  Future<(Shipment?, String?)> createPickupShipment({
    required List<String> orderIds,
  }) async {
    try {
      final request = CreateShipmentRequest(
        orders: orderIds
            .map((id) => OrderShipmentItem(orderId: id))
            .toList(),
      );

      var result = await baseClient.create(
        endpoint: '/shipment/pick-up',
        data: request.toJson(),
      );

      if (result.singleData != null) {
        return (result.singleData, null);
      } else {
        return (null, result.message ?? 'خطأ في إنشاء الشحنة');
      }
    } catch (e) {
      return (null, e.toString());
    }
  }
}