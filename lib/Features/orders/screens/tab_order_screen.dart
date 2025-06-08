// lib/Features/orders/screens/tab_order_screen.dart

import 'package:Tosell/Features/orders/providers/shipments_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';
import 'package:Tosell/Features/orders/widgets/order_card_item.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/router/app_router.dart';

class TabOrderScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  
  const TabOrderScreen({super.key, this.filter});

  @override
  ConsumerState<TabOrderScreen> createState() => _TabOrderScreenState();
}

class _TabOrderScreenState extends ConsumerState<TabOrderScreen> {
  late OrderFilter? _currentFilter;
  final Set<String> _selectedOrderIds = <String>{};
  bool _isSelectionMode = false;
  bool _isCreatingShipment = false;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    _fetchInitialOrders();
  }

  void _fetchInitialOrders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersNotifierProvider.notifier).getAll(
        page: 1,
        queryParams: _currentFilter?.toJson(),
      );
    });
  }

  @override
  void didUpdateWidget(covariant TabOrderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
      _fetchInitialOrders();
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedOrderIds.clear();
      }
    });
  }

  void _selectAll(List<Order> orders) {
    setState(() {
      _selectedOrderIds.clear();
      _selectedOrderIds.addAll(orders.map((order) => order.id!));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedOrderIds.clear();
    });
  }

  void _toggleOrderSelection(String orderId) {
    setState(() {
      if (_selectedOrderIds.contains(orderId)) {
        _selectedOrderIds.remove(orderId);
      } else {
        _selectedOrderIds.add(orderId);
      }
    });
  }

  Future<void> _createShipment() async {
    if (_selectedOrderIds.isEmpty) return;

    setState(() {
      _isCreatingShipment = true;
    });

    try {
      final result = await ref
          .read(shipmentsNotifierProvider.notifier)
          .createPickupShipment(orderIds: _selectedOrderIds.toList());

      if (result.$1 != null) {
        // Success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الشحنة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear selection and refresh orders
          setState(() {
            _selectedOrderIds.clear();
            _isSelectionMode = false;
          });
          
          // Refresh orders list
          ref.read(ordersNotifierProvider.notifier).getAll(
            page: 1,
            queryParams: _currentFilter?.toJson(),
          );
        }
      } else {
        // Error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.$2 ?? 'حدث خطأ في إنشاء الشحنة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingShipment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with selection controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedOrderIds.isEmpty
                        ? 'جميع الطلبات'
                        : 'تم تحديد ${_selectedOrderIds.length} طلب',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Multi-selection icon
                GestureDetector(
                  onTap: _toggleSelectionMode,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isSelectionMode 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Icon(
                      _isSelectionMode ? Icons.close : Icons.checklist,
                      color: _isSelectionMode 
                          ? Colors.white 
                          : Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                if (_isSelectionMode) ...[
                  const Gap(AppSpaces.small),
                  // Select All / Clear All
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onSelected: (value) {
                      final ordersData = ordersState.value ?? [];
                      if (value == 'select_all') {
                        _selectAll(ordersData);
                      } else if (value == 'clear_all') {
                        _clearSelection();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'select_all',
                        child: Text('تحديد الكل'),
                      ),
                      const PopupMenuItem(
                        value: 'clear_all',
                        child: Text('إلغاء التحديد'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Orders list
          Expanded(
            child: ordersState.when(
              data: (data) => _buildOrdersList(data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text(err.toString())),
            ),
          ),
        ],
      ),
      
      // Create Shipment Button
      bottomNavigationBar: _selectedOrderIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: FillButton(
                label: _isCreatingShipment 
                    ? 'جارٍ الإنشاء...' 
                    : 'إنشاء شحنة (${_selectedOrderIds.length})',
                onPressed: _createShipment,
                icon: _isCreatingShipment
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/svg/box.svg',
                        color: Colors.white,
                        width: 20,
                        height: 20,
                      ),
              ),
            )
          : null,
    );
  }

  Widget _buildOrdersList(List<Order> data) {
    return GenericPagedListView<Order>(
      key: ValueKey(widget.filter?.toJson()),
      noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
      fetchPage: (pageKey, _) async {
        return await ref.read(ordersNotifierProvider.notifier).getAll(
          page: pageKey,
          queryParams: _currentFilter?.toJson(),
        );
      },
      itemBuilder: (context, order, index) => _buildSelectableOrderCard(order),
    );
  }

  Widget _buildSelectableOrderCard(Order order) {
    final isSelected = _selectedOrderIds.contains(order.id);
    
    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleOrderSelection(order.id!);
        } else {
          // Navigate to order details
          context.push(AppRoutes.orderDetails, extra: order.code);
        }
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isSelected ? 0.8 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              OrderCardItem(
                order: order,
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleOrderSelection(order.id!);
                  } else {
                    context.push(AppRoutes.orderDetails, extra: order.code);
                  }
                },
              ),
              if (_isSelectionMode)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoItemsFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/svg/NoItemsFound.gif', width: 240, height: 240),
        Text(
          'لا توجد طلبات مضافة',
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xffE96363),
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'اضغط على زر "جديد" لإضافة طلب جديد و ارساله الى زبونك',
          style: context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xff698596),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: FillButton(
            label: 'إضافة اول طلب',
            onPressed: () => context.push(AppRoutes.addOrder),
            icon: SvgPicture.asset(
              'assets/svg/navigation_add.svg',
              color: const Color(0xffFAFEFD),
            ),
            reverse: true,
          ),
        ),
      ],
    );
  }
}