import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/Features/auth/models/User.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/widgets/order_card_item.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';
import 'package:Tosell/Features/orders/screens/orders_filter_bottom_sheet.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersScreen({super.key, this.filter});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with TickerProviderStateMixin {
  late OrderFilter? _currentFilter;
  late TabController _tabController;
  List<String> selectedOrderIds = [];

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter;
    _tabController = TabController(length: 2, vsync: this);
    _fetchInitialOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
      _fetchInitialOrders();
    }
  }

  void _onOrderSelectionChanged(String orderId, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedOrderIds.add(orderId);
      } else {
        selectedOrderIds.remove(orderId);
      }
    });
  }

  void _selectAllOrders(List<Order> orders) {
    setState(() {
      selectedOrderIds = orders.map((order) => order.id ?? '').where((id) => id.isNotEmpty).toList();
    });
  }

  void _clearSelection() {
    setState(() {
      selectedOrderIds.clear();
    });
  }

  void _showSelectionMenu() {
    final ordersState = ref.read(ordersNotifierProvider);
    if (ordersState is AsyncData<List<Order>>) {
      showMenu(
        context: context,
        position: const RelativeRect.fromLTRB(50, 50, 0, 0),
        items: [
          PopupMenuItem(
            child: Row(
              children: [
                const Icon(Icons.select_all),
                const SizedBox(width: 8),
                Text('تحديد الكل'),
              ],
            ),
            onTap: () => _selectAllOrders(ordersState.value),
          ),
          PopupMenuItem(
            child: Row(
              children: [
                const Icon(Icons.clear),
                const SizedBox(width: 8),
                Text('إلغاء الكل'),
              ],
            ),
            onTap: _clearSelection,
          ),
        ],
      );
    }
  }

  Future<void> _sendShipment() async {
    if (selectedOrderIds.isEmpty) return;
    
    try {
      final success = await ref.read(ordersNotifierProvider.notifier).createShipment(selectedOrderIds);
      
      if (success) {
        _clearSelection();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الشحنة بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpaces.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search and Filter Row
              Row(
                children: [
                  const Gap(10),
                  Expanded(
                    child: CustomTextFormField(
                      label: '',
                      showLabel: false,
                      hint: 'رقم الطلب',
                      prefixInner: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          'assets/svg/search.svg',
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                          height: 3,
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppSpaces.medium),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (_) => const OrdersFilterBottomSheet(),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.filter?.status == null
                                    ? Theme.of(context).colorScheme.outline
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/svg/Funnel.svg',
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        if (widget.filter != null)
                          Positioned(
                            top: 6,
                            right: 10,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(5),
              
              // Title Row with Selection Icon
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.filter == null
                          ? ' جميع الطلبات'
                          : 'جميع الطلبات "${orderStatus[widget.filter?.status ?? 0].name}"',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // Selection icon - only show in shipments tab
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        if (_tabController.index == 1) {
                          return GestureDetector(
                            onTap: _showSelectionMenu,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.checklist,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              // TabBar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  tabs: const [
                    Tab(text: 'طلبات'),
                    Tab(text: 'شحنات'),
                  ],
                ),
              ),
              
              const Gap(AppSpaces.small),

              // TabBarView
              ordersState.when(
                data: (data) => _buildTabContent(data),
                loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
                error: (err, _) => Expanded(child: Center(child: Text(err.toString()))),
              ),
            ],
          ),
        ),
      ),
      // Send Shipment Button
      bottomNavigationBar: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          if (_tabController.index == 1 && selectedOrderIds.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: FillButton(
                label: 'إرسال الشحنة (${selectedOrderIds.length})',
                onPressed: _sendShipment,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTabContent(List<Order> data) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          // Orders Tab
          _buildOrdersList(data, isShipmentTab: false),
          // Shipments Tab
          _buildOrdersList(data, isShipmentTab: true),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> data, {required bool isShipmentTab}) {
    return GenericPagedListView(
      key: ValueKey('${widget.filter?.toJson()}_$isShipmentTab'),
      noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
      fetchPage: (pageKey, _) async {
        return await ref.read(ordersNotifierProvider.notifier).getAll(
          page: pageKey,
          queryParams: _currentFilter?.toJson(),
        );
      },
      itemBuilder: (context, order, index) => _buildOrderCard(order, isShipmentTab),
    );
  }

  Widget _buildOrderCard(Order order, bool isShipmentTab) {
    if (isShipmentTab) {
      final isSelected = selectedOrderIds.contains(order.id);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(isSelected ? 0.95 : 1.0)
          ..translate(0.0, 0.0, isSelected ? -10.0 : 0.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
                : null,
          ),
          child: Stack(
            children: [
              OrderCardItem(
                order: order,
                onTap: () => _onOrderSelectionChanged(order.id ?? '', !isSelected),
              ),
              if (isSelected)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return OrderCardItem(
        order: order,
        onTap: () => context.push(AppRoutes.orderDetails, extra: order.code),
      );
    }
  }

  Widget _buildNoItemsFound() {
    return Column(
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
            icon: SvgPicture.asset('assets/svg/navigation_add.svg',
                color: const Color(0xffFAFEFD)),
            reverse: true,
          ),
        )
      ],
    );
  }
}