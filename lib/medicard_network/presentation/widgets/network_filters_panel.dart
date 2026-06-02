import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../network/data/city_response_model.dart';
import '../../../../network/data/government_response_model.dart';
import '../../core/network_colors.dart';
import '../../logic/medicard_network_cubit.dart';

class NetworkFiltersPanel extends StatelessWidget {
  final MedicardNetworkLoaded state;
  final VoidCallback onClearFilters;
  final ValueChanged<int?> onGovernmentChanged;
  final ValueChanged<int?> onCityChanged;

  const NetworkFiltersPanel({
    super.key,
    required this.state,
    required this.onClearFilters,
    required this.onGovernmentChanged,
    required this.onCityChanged,
  });

  bool get _hasActiveFilters =>
      state.selectedGovernmentId != null ||
      state.selectedCityId != null ||
      state.selectedCategoryId != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: NC.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: NC.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Accent bar
              Container(
                width: 4.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: NC.primaryLt,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'network.search_customization'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters)
                GestureDetector(
                  onTap: onClearFilters,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: NC.danger.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'network.clear_filters'.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: NC.danger,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: NetworkDropdown<Government>(
                  hint: 'network.government'.tr(),
                  items: state.governments,
                  selectedId: state.selectedGovernmentId,
                  getId: (g) => g.id,
                  getName: (g) => g.name,
                  onChanged: onGovernmentChanged,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: NetworkDropdown<City>(
                  hint: 'network.city'.tr(),
                  items: state.cities,
                  selectedId: state.selectedCityId,
                  getId: (c) => c.cityId,
                  getName: (c) => c.cityName,
                  onChanged: onCityChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Exported so it can be reused elsewhere if needed
class NetworkDropdown<T> extends StatelessWidget {
  final String hint;
  final List<T> items;
  final int? selectedId;
  final int Function(T) getId;
  final String Function(T) getName;
  final ValueChanged<int?> onChanged;

  const NetworkDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedId,
    required this.getId,
    required this.getName,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: NC.surface2,
        border: Border.all(color: NC.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButton<int>(
        value: selectedId,
        hint: Text(hint, style: TextStyle(fontSize: 12.sp, color: NC.textLight)),
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: NC.primaryLt, size: 20.sp),
        dropdownColor: NC.surface,
        borderRadius: BorderRadius.circular(14.r),
        items: [
          DropdownMenuItem<int>(
            value: null,
            child: Text(hint, style: TextStyle(fontSize: 12.sp, color: NC.textMid)),
          ),
          ...items.map(
                (item) => DropdownMenuItem<int>(
              value: getId(item),
              child: Text(
                getName(item),
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F172A)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}