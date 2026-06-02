import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../network/data/network_provider_response_model.dart';
import '../../core/network_colors.dart';

class ServicesBottomSheet extends StatelessWidget {
  final List<NetworkService> services;

  const ServicesBottomSheet({super.key, required this.services});

  static void show(BuildContext context, List<NetworkService> services) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NC.surface,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (_) => ServicesBottomSheet(services: services),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: NC.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'الخدمات المتاحة والخصومات',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: NC.surface2,
                    shape: BoxShape.circle,
                    border: Border.all(color: NC.border),
                  ),
                  child: Icon(Icons.close_rounded, size: 16.sp, color: NC.textMid),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.42,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: services.length,
              separatorBuilder: (_, _) => Divider(color: NC.border, height: 1),
              itemBuilder: (_, i) {
                final s = services[i];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.serviceName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: NC.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: NC.success.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '${s.discount}%',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}