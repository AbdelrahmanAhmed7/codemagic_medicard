import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicard/presentation/widgets/medicard_card_visual.dart';

import '../core/constants/app_assets.dart';
import '../core/theming/app_colors.dart';
import '../core/theming/app_toast.dart';
import '../core/theming/app_text_styles.dart';
import '../core/utils/app_button.dart';
import '../core/utils/app_text_field.dart';
import '../core/utils/egyptian_phone_field.dart';
import '../core/utils/language_helper.dart';
import 'logic/medicard_activation_cubit.dart';
import 'logic/medicard_activation_state.dart';

class MediCardSignupScreen extends StatefulWidget {
  const MediCardSignupScreen({super.key});

  @override
  State<MediCardSignupScreen> createState() => _MediCardSignupScreenState();
}

class _MediCardSignupScreenState extends State<MediCardSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicardNumberController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _passportController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedGender;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _medicardNumberController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    _passportController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicardActivationCubit, MedicardActivationState>(
      listenWhen: (previous, current) => true,
      listener: (context, state) {
        state.when(
          initial: () {
          },
          loading: () {
          },
          success: (response) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go('/medicard-login');
              }
            });
          },
          failed: (error) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                showErrorToast(error);
              }
            });
          },
        );
      },
      buildWhen: (previous, current) => true,
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );

        return Scaffold(
          backgroundColor: AppColors.backgroundClr,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundClr,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.blackClr),
              onPressed: () => context.go('/medicard'),
            ),
            title: Text('medicard_registration.title'.tr(), style: AppTextStyles.font16BlackMedium(context)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h + MediaQuery.of(context).padding.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediCardCardVisual(
                    cardNumber: _medicardNumberController.text,
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    birthdate: _birthDateController.text,
                    expireDate: DateFormat('yyyy-MM-dd').format(
                      DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day),
                    ),
                    profileImage: _pickedImage,
                    onRemoveImage: () {
                      setState(() {
                        _pickedImage = null;
                      });
                    },
                  ),
              SizedBox(height: 32.h),
              
              // Card Information
              _buildTextField(
                label: 'medicard_registration.medicard_number'.tr(), 
                hint: 'medicard_registration.medicard_number_hint'.tr(), 
                prefixIcon: AppAssets.cardIcon, 
                isRequired: true,
                keyboardType: TextInputType.number,
                controller: _medicardNumberController,
                maxLength: 12,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                onChanged: (_) => setState(() {}),
                customValidator: (value) {
                  final text = value ?? '';
                  if (text.isEmpty) {
                    return 'medicard_registration.validation.field_required'.tr();
                  }
                  if (text.length != 12) {
                    return 'medicard_registration.validation.card_length'.tr();
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(text)) {
                    return 'medicard_registration.validation.card_numbers_only'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              
              // Personal Information
              _buildTextField(
                label: 'medicard_registration.first_name'.tr(), 
                hint: 'medicard_registration.first_name_hint'.tr(), 
                isRequired: true,
                controller: _firstNameController,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                label: 'medicard_registration.last_name'.tr(), 
                hint: 'medicard_registration.last_name_hint'.tr(), 
                isRequired: true,
                controller: _lastNameController,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 16.h),
              _buildGenderDropdown(),
              SizedBox(height: 16.h),
              _buildBirthdatePicker(),
              SizedBox(height: 24.h),
              
              // Contact Information
              _buildPhoneField(),
              SizedBox(height: 16.h),
              _buildTextField(
                label: 'medicard_registration.email'.tr(), 
                hint: 'medicard_registration.email_hint'.tr(), 
                keyboardType: TextInputType.emailAddress, 
                isRequired: false,
                controller: _emailController,
              ),
              SizedBox(height: 24.h),
              
              // Identity Documents (Optional)
                  _buildTextField(
                    label: 'medicard_registration.national_id'.tr(),
                    hint: 'medicard_registration.national_id_hint'.tr(),
                    prefixIcon: AppAssets.idIcon,
                    keyboardType: TextInputType.number,
                    isRequired: false,
                    controller: _nationalIdController,
                    maxLength: 14,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(14),
                    ],
                  ),
              SizedBox(height: 16.h),
              _buildTextField(
                label: 'medicard_registration.passport_number'.tr(), 
                hint: 'medicard_registration.passport_number_hint'.tr(), 
                prefixIcon: AppAssets.idIcon,
                isRequired: false,
                controller: _passportController,
              ),
              SizedBox(height: 24.h),
              
              // Security
              _buildPasswordField(),
              SizedBox(height: 16.h),
              _buildConfirmPasswordField(),
              SizedBox(height: 24.h),
              
              // Profile Photo (Optional)
              _buildPhotoPicker(),

              SizedBox(height: 32.h),
              AppButton(
                text: 'medicard_registration.register_button'.tr(),
                useGradient: true,
                isLoading: isLoading,
                gradient: LinearGradient(
                  colors: [const Color(0xFF1E3A8A), const Color(0xFF1E3A8A).withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onPressed: isLoading ? null : () {
                  // Unfocus any text fields
                  FocusScope.of(context).unfocus();
                  
                  final isValid = _formKey.currentState!.validate();
                  
                  if (isValid) {
                    // Format phone number (add 0 if not present) and convert numerals
                    String rawPhone = _phoneController.text.trim();
                    String formattedPhone = rawPhone.startsWith('0') ? rawPhone : '0$rawPhone';
                    formattedPhone = LanguageHelper.convertArabicToEnglishNumerals(formattedPhone);

                    final cardNo = LanguageHelper.convertArabicToEnglishNumerals(_medicardNumberController.text.trim());
                    final password = LanguageHelper.convertArabicToEnglishNumerals(_passwordController.text.trim());
                    final confirmPassword = LanguageHelper.convertArabicToEnglishNumerals(_confirmPasswordController.text.trim());
                    final nationalId = _nationalIdController.text.isEmpty 
                        ? null 
                        : LanguageHelper.convertArabicToEnglishNumerals(_nationalIdController.text.trim());
                    final birthdate = LanguageHelper.convertArabicToEnglishNumerals(_birthDateController.text.trim());
                    final passportNumber = _passportController.text.isEmpty 
                        ? null 
                        : LanguageHelper.convertArabicToEnglishNumerals(_passportController.text.trim());

                    final cubit = context.read<MedicardActivationCubit>();
                    final lang = context.locale.languageCode;

                    cubit.activateCard(
                      cardNo: cardNo,
                      phoneNumber: formattedPhone,
                      password: password,
                      confirmPassword: confirmPassword,
                      firstName: _firstNameController.text.trim(),
                      lastName: _lastNameController.text.trim(),
                      nationalId: nationalId,
                      birthdate: birthdate,
                      passportNumber: passportNumber,
                      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
                      isMale: _selectedGender == 'Male',
                      profileImage: null, // TODO: Handle image upload
                      lang: lang,
                    );
                  } else {
                    // Form is invalid - the fields will show their own errors. 
                    // No global snackbar as per user request.
                  }
                },
              ),
              SizedBox(height: 24.h),

              // Already activated? Login
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'medicard_registration.already_activated'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[700],
                    ),
                    children: [
                      TextSpan(
                        text: 'medicard_registration.login'.tr(),
                        style: TextStyle(
                          color: const Color(0xFF233154),
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.push('/medicard-login');
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
    TextEditingController? controller,
    Function(String)? onChanged,
    String? Function(String?)? customValidator,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.font14BlackMedium(context)),
            if (isRequired) ...[
              SizedBox(width: 4.w),
              Text('*', style: TextStyle(color: AppColors.errorClr, fontSize: 14.sp)),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        AppTextField(
          hintText: hint,
          prefixImagePath: prefixIcon,
          keyboardType: keyboardType,
          controller: controller,
          onChanged: onChanged,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          validator: customValidator ?? (isRequired
              ? (value) => (value?.isEmpty ?? true) ? 'medicard_registration.validation.field_required'.tr() : null
              : null),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('medicard_registration.gender'.tr(),
                style: AppTextStyles.font14BlackMedium(context)),
            SizedBox(width: 4.w),
            Text('*', style: TextStyle(color: AppColors.errorClr, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 8.h),
        FormField<String>(
          initialValue: _selectedGender,
          validator: (value) => (value == null)
              ? 'medicard_registration.validation.field_required'.tr()
              : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: field.hasError
                        ? AppColors.errorClr
                        : Colors.grey.shade300,
                    width: field.hasError ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wc_rounded,
                        color: const Color(0xFF1E3A8A), size: 20.sp),
                    SizedBox(width: 12.w),
                    Text('medicard_registration.gender'.tr(),
                        style: AppTextStyles.font14BlackMedium(context)),
                    const Spacer(),
                    _genderChip(
                      label: 'medicard_registration.male'.tr(),
                      selected: _selectedGender == 'Male',
                      onTap: () {
                        setState(() => _selectedGender = 'Male');
                        field.didChange('Male');
                      },
                    ),
                    SizedBox(width: 8.w),
                    _genderChip(
                      label: 'medicard_registration.female'.tr(),
                      selected: _selectedGender == 'Female',
                      onTap: () {
                        setState(() => _selectedGender = 'Female');
                        field.didChange('Female');
                      },
                    ),
                  ],
                ),
              ),
              if (field.hasError) ...[
                SizedBox(height: 6.h),
                Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Text(
                    field.errorText!,
                    style: TextStyle(
                      color: AppColors.errorClr,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _genderChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E3A8A) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBirthdatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('medicard_registration.birthdate'.tr(), style: AppTextStyles.font14BlackMedium(context)),
            SizedBox(width: 4.w),
            Text('*', style: TextStyle(color: AppColors.errorClr, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime(2000, 1, 1),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: const Color(0xFF1E3A8A),
                      onPrimary: Colors.white,
                      onSurface: AppColors.blackClr,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                _birthDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              });
            }
          },
          child: AbsorbPointer(
            child: AppTextField(
              controller: _birthDateController,
              hintText: 'medicard_registration.birthdate_hint'.tr(),
              prefixIcon: Icons.calendar_today,
              validator: (value) {
                // نعتمد على قيمة الكنترولر بدل قيمة الـ FormField الداخلية،
                // لأن المستخدم ما بيكتبش بنفسه في الفيلد (بيختار من الـ DatePicker)
                final text = _birthDateController.text.trim();
                if (text.isEmpty) {
                  return 'medicard_registration.validation.field_required'.tr();
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('medicard_registration.phone_number'.tr(), style: AppTextStyles.font14BlackMedium(context)),
            SizedBox(width: 4.w),
            Text('*', style: TextStyle(color: AppColors.errorClr, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 8.h),
        EgyptianPhoneField(
          controller: _phoneController,
          maxLength: _phoneController.text.startsWith('0') ? 11 : 10,
          onChanged: (_) => setState(() {}),
          hintText: 'medicard_registration.phone_number_hint'.tr(),
          phoneRequiredKey: 'auth.signup.validation.phone_required',
          phoneInvalidKey: 'auth.signup.validation.phone_invalid',
          // Custom validator that's أكثر لينًا
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'auth.signup.validation.phone_required'.tr();
            }
            
            // Remove leading 0 if present
            String cleanValue = value.startsWith('0') ? value.substring(1) : value;
            
            // Check if it's 10 digits starting with 10, 11, 12, or 15
            if (cleanValue.length == 10 && RegExp(r'^(10|11|12|15)[0-9]{8}$').hasMatch(cleanValue)) {
              return null;
            }

            return 'auth.signup.validation.phone_invalid'.tr();
          },
        ),
      ],
    );
  }

  Widget _buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('medicard_registration.profile_photo'.tr(), style: AppTextStyles.font14BlackMedium(context)),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.lightGreyClr,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFF233154).withValues(alpha: 0.3),
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              image: _pickedImage != null
                  ? DecorationImage(
                      image: FileImage(_pickedImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _pickedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF233154).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: const Color(0xFF233154),
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'medicard_registration.tap_to_upload'.tr(),
                        style: AppTextStyles.font12GreyRegular(context),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('medicard_registration.password'.tr(), style: AppTextStyles.font14BlackMedium(context)),
            SizedBox(width: 4.w),
            Text('*', style: TextStyle(color: AppColors.errorClr, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 8.h),
        AppTextField(
          controller: _passwordController,
          hintText: 'medicard_registration.password_hint'.tr(),
          prefixImagePath: AppAssets.passwordIcon,
          isPassword: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'medicard_registration.validation.password_required'.tr();
            }
            if (value!.length < 8) {
              return 'medicard_registration.validation.password_length'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('medicard_registration.confirm_password'.tr(), style: AppTextStyles.font14BlackMedium(context)),
            SizedBox(width: 4.w),
            Text('*', style: TextStyle(color: AppColors.errorClr, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 8.h),
        AppTextField(
          controller: _confirmPasswordController,
          hintText: 'medicard_registration.confirm_password_hint'.tr(),
          prefixImagePath: AppAssets.passwordIcon,
          isPassword: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'medicard_registration.validation.confirm_password_required'.tr();
            }
            if (value != _passwordController.text) {
              return 'medicard_registration.validation.passwords_not_match'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }
}