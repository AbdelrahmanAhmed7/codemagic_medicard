import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/network_colors.dart';

class NetworkSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final bool showDiscountToggle;
  final bool orderByDiscounts;
  final bool isSearching;
  final ValueChanged<String> onSearch;
  final VoidCallback onClear;
  final VoidCallback onToggleDiscount;

  const NetworkSearchBarDelegate({
    required this.searchController,
    required this.showDiscountToggle,
    required this.orderByDiscounts,
    required this.isSearching,
    required this.onSearch,
    required this.onClear,
    required this.onToggleDiscount,
  });

  @override
  double get minExtent => 68.h;

  @override
  double get maxExtent => 68.h;

  @override
  bool shouldRebuild(covariant NetworkSearchBarDelegate old) =>
      old.orderByDiscounts != orderByDiscounts ||
      old.showDiscountToggle != showDiscountToggle ||
      old.isSearching != isSearching ||
      old.searchController.text != searchController.text;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      height: 68.h,
      color: NC.bg,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: NC.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSearching
                      ? NC.primaryLt.withValues(alpha: 0.6)
                      : NC.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSearching
                        ? NC.primaryLt.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: isSearching ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onSubmitted: onSearch,
                textAlignVertical: TextAlignVertical.center,
                style:
                    TextStyle(fontSize: 13.sp, color: const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'network.search_placeholder'.tr(),
                  hintStyle: TextStyle(fontSize: 13.sp, color: NC.textLight),
                  // Prefix: spinner while debouncing, icon otherwise
                  prefixIcon: isSearching
                      ? Padding(
                          padding: EdgeInsets.all(12.w),
                          child: SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: NC.primaryMid,
                            ),
                          ),
                        )
                      : Icon(Icons.search_rounded,
                          color: NC.primaryMid, size: 20.sp),
                  // Suffix: clear button or nothing
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: NC.textLight, size: 18.sp),
                          onPressed: onClear,
                        )
                      : null,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          if (showDiscountToggle) ...[
            SizedBox(width: 8.w),
            _SortButton(
              active: orderByDiscounts,
              onTap: onToggleDiscount,
            ),
          ],
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _SortButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        height: 48.h,
        decoration: BoxDecoration(
          color: active ? NC.primary : NC.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: active ? NC.primary : NC.border),
          boxShadow: [
            BoxShadow(
              color: active
                  ? NC.primary.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: active ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.trending_down_rounded : Icons.sort_rounded,
              color: active ? Colors.white : NC.primaryMid,
              size: 18.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              active ? 'network.highest_discount'.tr() : 'network.sort'.tr(),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : NC.primaryMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}