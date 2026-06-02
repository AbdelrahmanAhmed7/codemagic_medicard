import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theming/app_colors.dart';
import '../core/theming/app_toast.dart';
import '../core/theming/app_text_styles.dart';
import '../data/card_personal_info_response_model.dart';
import 'logic/medicard_edit_profile_cubit.dart';
import 'logic/medicard_edit_profile_state.dart';

class MedicardEditProfileScreen extends StatefulWidget {
  final CardPersonalInfoDataModel personalData;
  final String cardNo;

  const MedicardEditProfileScreen({
    super.key,
    required this.personalData,
    required this.cardNo,
  });

  @override
  State<MedicardEditProfileScreen> createState() => _MedicardEditProfileScreenState();
}

class _MedicardEditProfileScreenState extends State<MedicardEditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _nationalIdController;
  late TextEditingController _passportController;
  
  late String _birthdate;
  late bool _isMale;
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.personalData.firstName);
    _lastNameController = TextEditingController(text: widget.personalData.lastName);
    _phoneController = TextEditingController(text: widget.personalData.mobile);
    _emailController = TextEditingController(text: widget.personalData.email ?? '');
    _nationalIdController = TextEditingController(text: widget.personalData.nationalId ?? '');
    _passportController = TextEditingController(text: widget.personalData.passport ?? '');
    _birthdate = widget.personalData.birthdate;
    _isMale = widget.personalData.isMale;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    _passportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicardEditProfileCubit, MedicardEditProfileState>(
      listener: (context, state) {
        state.when(
          initial: () {},
            loading: () {},
            success: (response) {
              showSuccessToast('medicard_edit_profile.success'.tr());
              context.pop(true);
            },
            failed: (error) {
              showErrorToast(error);
            },
          );
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.backgroundClr,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.blackClr),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'medicard_edit_profile.title'.tr(),
                style: AppTextStyles.font20BlackSemiBold(context),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + MediaQuery.of(context).padding.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100.w,
                            height: 100.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                              border: Border.all(color: AppColors.primaryClr, width: 2),
                            ),
                            child: _pickedImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      _pickedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : (widget.personalData.image != null &&
                                        widget.personalData.image!.isNotEmpty
                                    ? ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: widget.personalData.image!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.person, size: 50),
                                        ),
                                      )
                                    : const Icon(Icons.person,
                                        size: 50, color: Color(0xFF1E3A8A))),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E3A8A),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 18.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Form Fields
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'medicard_edit_profile.first_name'.tr(),
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 16.h),

                  _buildTextField(
                    controller: _lastNameController,
                    label: 'medicard_edit_profile.last_name'.tr(),
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 16.h),

                  _buildTextField(
                    controller: _phoneController,
                    label: 'medicard_edit_profile.phone'.tr(),
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16.h),

                  _buildTextField(
                    controller: _emailController,
                    label: 'medicard_edit_profile.email'.tr(),
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16.h),

                  _buildTextField(
                    controller: _nationalIdController,
                    label: 'medicard_edit_profile.national_id'.tr(),
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(height: 16.h),

                  _buildTextField(
                    controller: _passportController,
                    label: 'medicard_edit_profile.passport'.tr(),
                    icon: Icons.flight_outlined,
                  ),
                  SizedBox(height: 16.h),

                  // Birthdate
                  _buildDateField(),
                  SizedBox(height: 16.h),

                  // Gender
                  _buildGenderSelector(),
                  SizedBox(height: 32.h),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: state.maybeWhen(
                        loading: () => null,
                        orElse: () => () => _saveProfile(context),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: state.maybeWhen(
                        loading: () => const CircularProgressIndicator(color: Colors.white),
                        orElse: () => Text(
                          'medicard_edit_profile.save'.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(_birthdate) ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            _birthdate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF1E3A8A)),
            SizedBox(width: 12.w),
            Text(
              _birthdate,
              style: AppTextStyles.font14BlackMedium(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.wc, color: Color(0xFF1E3A8A)),
          SizedBox(width: 12.w),
          Text('medicard_edit_profile.gender'.tr(), style: AppTextStyles.font14BlackMedium(context)),
          const Spacer(),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isMale = true),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _isMale ? const Color(0xFF1E3A8A) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'medicard_edit_profile.male'.tr(),
                    style: TextStyle(
                      color: _isMale ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () => setState(() => _isMale = false),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: !_isMale ? const Color(0xFF1E3A8A) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'medicard_edit_profile.female'.tr(),
                    style: TextStyle(
                      color: !_isMale ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveProfile(BuildContext context) {
    // --- Validation ---
    if (_firstNameController.text.trim().isEmpty) {
      showErrorToast('auth.signup.validation.first_name_required'.tr());
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      showErrorToast('auth.signup.validation.last_name_required'.tr());
      return;
    }
    if (_phoneController.text.trim().length < 11) {
      showErrorToast('auth.login.validation.phone_length'.tr());
      return;
    }
    if (_nationalIdController.text.trim().isNotEmpty &&
        _nationalIdController.text.trim().length != 14) {
      showErrorToast('auth.signup.validation.national_id_invalid'.tr());
      return;
    }
    if (_emailController.text.trim().isNotEmpty &&
        !_emailController.text.contains('@')) {
      showErrorToast('personal_info.validation.email_invalid'.tr());
      return;
    }

    context.read<MedicardEditProfileCubit>().updateProfile(
          cardNo: widget.cardNo,
          lang: context.locale.languageCode,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          nationalId: _nationalIdController.text.trim(),
          passportNumber: _passportController.text.trim(),
          birthdate: _birthdate,
          isMale: _isMale,
          profileImage: _pickedImage?.path ??
              (widget.personalData.image?.startsWith('http') == true
                  ? null
                  : widget.personalData.image),
        );
  }
}
