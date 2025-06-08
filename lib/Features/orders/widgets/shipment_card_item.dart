// lib/Features/orders/widgets/shipment_card_item.dart

import 'package:Tosell/Features/orders/models/shipment.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';

class ShipmentCardItem extends ConsumerWidget {
  final Shipment shipment;
  final Function? onTap;

  const ShipmentCardItem({
    required this.shipment,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = Theme.of(context);
    DateTime date = DateTime.parse(
        shipment.creationDate ?? DateTime.now().toIso8601String());
    
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.only(right: 2, left: 2, bottom: 2),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            color: const Color(0xffEAEEF0),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1000),
                            color: theme.colorScheme.surface,
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/box.svg",
                            width: 24,
                            height: 24,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shipment.code ?? "لايوجد",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Tajawal",
                                ),
                              ),
                              Text(
                                "${date.day}.${date.month}.${date.year}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Tajawal",
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildShipmentStatus(shipment.status ?? 0),
                        const Gap(AppSpaces.small),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildSection(
                            "طلبات: ${shipment.ordersCount ?? 0}",
                            "assets/svg/48. Files.svg",
                            theme,
                            textColor: Colors.black,
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: theme.colorScheme.outline,
                          ),
                          const Gap(AppSpaces.small),
                          buildSection(
                            "التجار: ${shipment.merchantsCount ?? 0}",
                            "assets/svg/User.svg",
                            theme,
                            textColor: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentStatus(int index) {
    // Using orderStatus from order_enum for consistency
    // You might need a separate shipmentStatus array if statuses differ
    return Container(
      width: 100,
      height: 26,
      decoration: BoxDecoration(
        color: orderStatus[index].color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          orderStatus[index].name!,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget buildSection(
    String title,
    String iconPath,
    ThemeData theme, {
    bool isRed = false,
    bool isGray = false,
    void Function()? onTap,
    EdgeInsets? padding,
    double? textWidth,
    Color? textColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Padding(
                padding: padding ?? const EdgeInsets.all(0),
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  color: isRed
                      ? theme.colorScheme.error
                      : isGray
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  width: textWidth,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: textColor ?? theme.colorScheme.secondary,
                      fontFamily: "Tajawal",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}