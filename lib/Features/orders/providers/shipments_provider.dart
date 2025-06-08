import 'dart:async';
import 'package:Tosell/Features/orders/models/shipment.dart';
import 'package:Tosell/Features/orders/services/CreateShipmentRequest.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';

part 'shipments_provider.g.dart';

@riverpod
class ShipmentsNotifier extends _$ShipmentsNotifier {
  final ShipmentsService _service = ShipmentsService();

  Future<ApiResponse<Shipment>> getAll({
    int page = 1,
    Map<String, dynamic>? queryParams,
  }) async {
    return await _service.getAll(
      page: page,
      queryParams: queryParams,
    );
  }

  Future<Shipment?> getShipmentById({required String id}) async {
    return await _service.getShipmentById(id: id);
  }

  Future<(Shipment?, String?)> createPickupShipment({
    required List<String> orderIds,
  }) async {
    try {
      // Set loading state
      state = const AsyncValue.loading();

      final result = await _service.createPickupShipment(orderIds: orderIds);

      if (result.$1 != null) {
        // Success - refresh the shipments list
        await refresh();
        return (result.$1, null);
      } else {
        // Error
        state = AsyncError(result.$2 ?? 'خطأ غير معروف', StackTrace.current);
        return (null, result.$2);
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return (null, e.toString());
    }
  }

  Future<void> refresh() async {
    try {
      final result = await getAll();
      state = AsyncValue.data(result.data ?? []);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  @override
  FutureOr<List<Shipment>> build() async {
    var result = await getAll();
    return result.data ?? [];
  }
}