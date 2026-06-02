import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../network/data/network_category_response_model.dart';
import '../../core/network_colors.dart';

class NetworkCategoriesRow extends StatelessWidget {
  final List<NetworkCategory> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelect;

  const NetworkCategoriesRow({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
          child: Text(
            'network.categories'.tr(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: NC.textMid,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: categories.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return _CatChip(
                  label: 'network.all'.tr(),
                  isSelected: selectedId == null,
                  color: NC.primaryMid,
                  onTap: () => onSelect(null),
                );
              }
              final cat = categories[i - 1];
              return _CatChip(
                label: cat.name,
                isSelected: selectedId == cat.id,
                color: networkCatColor(cat.name),
                onTap: () => onSelect(cat.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CatChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color : NC.surface,
          borderRadius: BorderRadius.circular(50.r),
          border: Border.all(
            color: isSelected ? color : NC.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : NC.textMid,
          ),
        ),
      ),
    );
  }
}