import 'package:Tosell/Features/orders/models/shipment.dart';
import 'package:Tosell/Features/orders/providers/shipments_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';

class TabShipmentScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  
  const TabShipmentScreen({super.key, this.filter});

  @override
  ConsumerState<TabShipmentScreen> createState() => _TabShipmentScreenState();
}

class _TabShipmentScreenState extends ConsumerState<TabShipmentScreen> {
  late OrderFilter? _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    _fetchInitialShipments();
  }

  void _fetchInitialShipments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shipmentsNotifierProvider.notifier).getAll(
        page: 1,
        queryParams: _currentFilter?.toJson(),
      );
    });
  }

  @override
  void didUpdateWidget(covariant TabShipmentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
      _fetchInitialShipments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsState = ref.watch(shipmentsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.filter == null
                  ? 'جميع الوصولات'
                  : 'الوصولات المفلترة',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          Expanded(
            child: shipmentsState.when(
              data: (data) => _buildShipmentsList(data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text(err.toString())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentsList(List<Shipment> data) {
    return GenericPagedListView<Shipment>(
      key: ValueKey(widget.filter?.toJson()),
      noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
      fetchPage: (pageKey, _) async {
        return await ref.read(shipmentsNotifierProvider.notifier).getAll(
          page: pageKey,
          queryParams: _currentFilter?.toJson(),
        );
      },
      itemBuilder: (context, shipment, index) => ShipmentCartItem(
        shipment: shipment,
        onTap: () => _navigateToShipmentDetails(shipment),
      ),
    );
  }

  void _navigateToShipmentDetails(Shipment shipment) {
    // Navigate to orders screen with shipment filter
    context.push(
      AppRoutes.orders,
      extra: OrderFilter(
        shipmentId: shipment.id,
        shipmentCode: shipment.code,
      ),
    );
  }

  Widget _buildNoItemsFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/svg/NoItemsFound.gif',
          width: 240,
          height: 240,
        ),
        const SizedBox(height: AppSpaces.medium),
        Text(
          'لا توجد وصولات',
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.primary,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'لم يتم إنشاء أي شحنات بعد',
          style: context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xff698596),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}