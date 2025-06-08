import 'package:Tosell/Features/orders/screens/tab_order_screen.dart';
import 'package:Tosell/Features/orders/screens/tab_shipment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/screens/orders_filter_bottom_sheet.dart';

class MainOrderShipmentsScreen extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  
  const MainOrderShipmentsScreen({super.key, this.filter});

  @override
  ConsumerState<MainOrderShipmentsScreen> createState() =>
      _MainOrderShipmentsScreenState();
}

class _MainOrderShipmentsScreenState extends ConsumerState<MainOrderShipmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  OrderFilter? _currentFilter;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentFilter = widget.filter;
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
          // Clear search when switching tabs
          _searchController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => const OrdersFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const Gap(AppSpaces.large),
            // Search and Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: _searchController,
                      label: '',
                      showLabel: false,
                      hint: _currentTabIndex == 0 ? 'رقم الطلب' : 'رقم الوصل',
                      prefixInner: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          'assets/svg/search.svg',
                          color: Theme.of(context).colorScheme.primary,
                          width: 24,
                          height: 24,
                        ),
                      ),
                      onChanged: (value) {
                        // TODO: Implement search functionality
                      },
                    ),
                  ),
                  const Gap(AppSpaces.medium),
                  // Filter Icon
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _currentFilter != null
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              'assets/svg/Funnel.svg',
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        if (_currentFilter != null)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(AppSpaces.medium),
            
            // TabBar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).colorScheme.primary,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(context).colorScheme.secondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(text: 'الطلبات'),
                  Tab(text: 'الشحنات'),
                ],
              ),
            ),
            
            const Gap(AppSpaces.small),
            
            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  TabOrderScreen(filter: _currentFilter),
                  TabShipmentScreen(filter: _currentFilter),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}