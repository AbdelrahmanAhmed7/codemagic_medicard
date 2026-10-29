import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../core/theming/app_snack_bar.dart';
import '../../core/tutorial/tutorial_bubble.dart';
import '../../core/tutorial/tutorial_service.dart';
import '../data/invoice_models.dart';
import '../repository/invoice_repository.dart';

class InvoiceCreateForm extends StatefulWidget {
  final String cardNo;
  final InvoiceRepository repository;
  final int? initialProviderId;
  final String? initialProviderName;

  /// When true, runs the in-page coach-mark tour after mount.
  final bool runTutorial;

  const InvoiceCreateForm({
    super.key,
    required this.cardNo,
    required this.repository,
    this.initialProviderId,
    this.initialProviderName,
    this.runTutorial = false,
  });

  @override
  State<InvoiceCreateForm> createState() => _InvoiceCreateFormState();
}

class _InvoiceCreateFormState extends State<InvoiceCreateForm> {
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  InvoiceProvider? _provider;
  InvoiceBranch? _branch;
  // Multi-image support
  final List<XFile> _attachments = [];
  bool _isSubmitting = false;
  bool _isLoadingInitialProvider = false;

  // ── Coach-mark keys ────────────────────────────────────────────────────────
  final _providerKey = GlobalKey();
  final _branchKey = GlobalKey();
  final _detailsKey = GlobalKey();
  final _requestFieldKey = GlobalKey();
  final _uploadButtonsKey = GlobalKey();

  TutorialCoachMark? _coachMark;
  bool _tutorialStarted = false;

  String get _lang => context.locale.languageCode;

  @override
  void initState() {
    super.initState();
    if (widget.initialProviderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialProvider();
      });
    }
    if (widget.runTutorial) {
      Future<void>.delayed(const Duration(milliseconds: 450), _startFormTour);
    }
  }

  @override
  void dispose() {
    _coachMark?.finish();
    _notesController.dispose();
    super.dispose();
  }

  // ── Coach-mark tour (steps 2-4) ────────────────────────────────────────────
  Future<void> _startFormTour() async {
    if (!mounted || _tutorialStarted) return;

    while (mounted && _isLoadingInitialProvider) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (!mounted) return;

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    void skip() {
      TutorialService.markSeen();
      _coachMark?.skip();
    }

    TargetFocus? makeTarget({
      required GlobalKey key,
      required String text,
      required String nextLabel,
      required VoidCallback onNext,
      bool showSkip = true,
      List<GlobalKey> dependentKeys = const [],
    }) {
      if (key.currentContext == null ||
          dependentKeys.any((key) => key.currentContext == null)) {
        return null;
      }
      return TargetFocus(
        identify: key.toString(),
        keyTarget: key,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        enableTargetTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (_, _) => TutorialBubble(
              text: text,
              nextLabel: nextLabel,
              onNext: onNext,
              onSkip: showSkip ? skip : null,
              showSkip: showSkip,
            ),
          ),
        ],
      );
    }

    final targets = <TargetFocus>[];

    final t2 = makeTarget(
      key: _providerKey,
      text: 'اختار مقدم الخدمة الأول',
      nextLabel: 'التالي',
      onNext: () => _coachMark?.next(),
    );
    final t3 = makeTarget(
      key: _branchKey,
      text: 'بعدها اختار الفرع',
      nextLabel: 'التالي',
      onNext: () => _coachMark?.next(),
    );
    final t4 = makeTarget(
      key: _detailsKey,
      text: 'اكتب عايز إيه، أو ارفع صورة الروشتة',
      nextLabel: 'تمام، فهمت',
      onNext: () {
        TutorialService.markSeen();
        _coachMark?.finish();
      },
      showSkip: false,
      dependentKeys: [_requestFieldKey, _uploadButtonsKey],
    );

    if (t2 != null) targets.add(t2);
    if (t3 != null) targets.add(t3);
    if (t4 != null) targets.add(t4);

    if (targets.isEmpty) {
      await TutorialService.markSeen();
      return;
    }

    _tutorialStarted = true;
    await TutorialService.markSeen();
    if (!mounted) return;

    _coachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.7,
      hideSkip: true,
      beforeFocus: (target) async {
        final targetContext = target.keyTarget?.currentContext;
        if (targetContext == null) return;
        await Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 300),
          alignment: 0.35,
          curve: Curves.easeInOut,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      onFinish: () => TutorialService.markSeen(),
      onSkip: () {
        TutorialService.markSeen();
        return true;
      },
    )..show(context: context);
  }

  Future<void> _loadInitialProvider() async {
    setState(() => _isLoadingInitialProvider = true);
    try {
      final page = await widget.repository.getProviders(
        lang: _lang,
        search: widget.initialProviderName,
      );
      final providers = page.items;
      final match = providers.where(
        (provider) => provider.providerId == widget.initialProviderId,
      );
      if (!mounted) return;
      if (match.isNotEmpty) {
        setState(() => _provider = match.first);
      }
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isLoadingInitialProvider = false);
    }
  }

  Future<void> _chooseProvider() async {
    final provider = await _showPagedPicker<InvoiceProvider>(
      title: 'invoice.choose_provider'.tr(),
      searchHint: 'invoice.search_providers'.tr(),
      loadPage: (query, page) => widget.repository.getProviders(
        lang: _lang,
        search: query,
        page: page,
      ),
      titleOf: (item) => item.providerName.trim(),
      subtitleOf: (item) => item.categoryName,
      leadingBuilder: (item) => _ProviderLogo(url: item.providerLogo),
      isSelected: (item) => item.providerId == _provider?.providerId,
    );
    if (provider == null || !mounted) return;
    setState(() {
      _provider = provider;
      _branch = null;
    });
  }

  Future<void> _chooseBranch() async {
    final provider = _provider;
    if (provider == null) return;
    final branch = await _showPagedPicker<InvoiceBranch>(
      title: 'invoice.choose_branch'.tr(),
      allowSearch: false,
      titleFontSize: 16,
      subtitleFontSize: 13,
      loadPage: (_, page) => widget.repository.getProviderBranches(
        lang: _lang,
        providerId: provider.providerId,
        page: page,
      ),
      titleOf: (item) => item.branchName.trim().isEmpty
          ? item.area.trim()
          : item.branchName.trim(),
      subtitleOf: (item) => [
        item.area,
        item.city,
        item.government,
      ].where((part) => part.trim().isNotEmpty).join(' - '),
      leadingBuilder: (_) =>
          const _PickerIcon(icon: Icons.location_on_outlined),
      isSelected: (item) => item.locationId == _branch?.locationId,
    );
    if (branch == null || !mounted) return;
    setState(() => _branch = branch);
  }

  Future<T?> _showPagedPicker<T>({
    required String title,
    String searchHint = '',
    bool allowSearch = true,
    required Future<InvoicePage<T>> Function(String query, int page) loadPage,
    required String Function(T item) titleOf,
    required String Function(T item) subtitleOf,
    double titleFontSize = 13,
    double subtitleFontSize = 10,
    Widget Function(T item)? leadingBuilder,
    bool Function(T item)? isSelected,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => _InvoicePagedPicker<T>(
        title: title,
        searchHint: searchHint,
        allowSearch: allowSearch,
        loadPage: loadPage,
        titleOf: titleOf,
        subtitleOf: subtitleOf,
        titleFontSize: titleFontSize,
        subtitleFontSize: subtitleFontSize,
        leadingBuilder: leadingBuilder,
        isSelected: isSelected,
      ),
    );
  }

  Future<void> _pickAttachment(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final images = await _imagePicker.pickMultiImage(imageQuality: 85);
        if (images.isNotEmpty && mounted) {
          setState(() => _attachments.addAll(images));
        }
      } else {
        final image = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
        );
        if (image != null && mounted) setState(() => _attachments.add(image));
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showError(error);
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final provider = _provider;
    final branch = _branch;
    final notes = _notesController.text.trim();
    if (provider == null ||
        branch == null ||
        (notes.isEmpty && _attachments.isEmpty)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      final created = await widget.repository.createInvoice(
        lang: _lang,
        cardNo: widget.cardNo,
        providerId: provider.providerId,
        providerLocationId: branch.locationId,
        notes: notes,
        attachments: List.unmodifiable(_attachments),
      );
      if (!mounted) return;
      _notesController.clear();
      setState(() {
        _provider = null;
        _branch = null;
        _attachments.clear();
      });
      await _showSuccessAndOpenInvoices(created);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showSuccessAndOpenInvoices(CreatedInvoice invoice) async {
    final dialog = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF15803D),
                size: 56,
              ),
              SizedBox(height: 12.h),
              Text(
                'invoice.created_successfully'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF166534),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'invoice.request_number'.tr(args: [invoice.id.toString()]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    await dialog;
    if (!mounted) return;
    context.go(
      Uri(
        path: '/medicard-invoices/history',
        queryParameters: {'cardNo': widget.cardNo},
      ).toString(),
    );
  }

  void _showError(Object error) {
    String message;
    if (error is PlatformException) {
      switch (error.code) {
        case 'photo_access_denied':
        case 'access_denied':
          message = 'تم رفض الوصول للصور. يرجى السماح من الإعدادات.';
        case 'camera_access_denied':
          message = 'تم رفض الوصول للكاميرا. يرجى السماح من الإعدادات.';
        default:
          message = error.message?.isNotEmpty == true
              ? error.message!
              : 'تعذر فتح اختيار الصور. حاول مرة أخرى.';
      }
    } else {
      message = error
          .toString()
          .replaceFirst(RegExp(r'^Exception:\s*'), '')
          .replaceFirst(RegExp(r'^Bad state:\s*'), '');
    }
    showAppSnackBar(
      context,
      message,
      type: SnackBarType.error,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _provider != null &&
        _branch != null &&
        (_notesController.text.trim().isNotEmpty || _attachments.isNotEmpty) &&
        !_isSubmitting;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            28.h + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF0E7490)],
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'invoice.create_title'.tr(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'invoice.open_description'.tr(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            height: 1.4,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _ProgressStep(
                  number: 1,
                  label: 'invoice.provider'.tr(),
                  complete: _provider != null,
                ),
                _ProgressStep(
                  number: 2,
                  label: 'invoice.branch'.tr(),
                  complete: _branch != null,
                ),
                _ProgressStep(
                  number: 3,
                  label: 'invoice.request_details'.tr(),
                  complete:
                      _notesController.text.trim().isNotEmpty ||
                      _attachments.isNotEmpty,
                ),
              ],
            ),
            SizedBox(height: 18.h),
            _FormSection(
              icon: Icons.apartment_rounded,
              title: 'invoice.provider_and_branch'.tr(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RequiredLabel('invoice.provider'.tr()),
                  SizedBox(height: 8.h),
                  _SelectionButton(
                    key: _providerKey,
                    label:
                        _provider?.providerName.trim() ??
                        'invoice.choose_provider'.tr(),
                    supportingText:
                        _provider?.categoryName ?? 'invoice.provider_hint'.tr(),
                    leading: _provider == null
                        ? null
                        : _ProviderLogo(url: _provider!.providerLogo),
                    placeholderIcon: Icons.search_rounded,
                    isLoading: _isLoadingInitialProvider,
                    isSelected: _provider != null,
                    onTap: _isLoadingInitialProvider || _isSubmitting
                        ? null
                        : _chooseProvider,
                  ),
                  SizedBox(height: 16.h),
                  _RequiredLabel('invoice.branch'.tr()),
                  SizedBox(height: 8.h),
                  _SelectionButton(
                    key: _branchKey,
                    label: _branch == null
                        ? 'invoice.choose_branch'.tr()
                        : _branch!.branchName.trim().isEmpty
                        ? _branch!.area.trim()
                        : _branch!.branchName.trim(),
                    supportingText: _branch == null
                        ? _provider == null
                              ? 'invoice.choose_provider_first'.tr()
                              : 'invoice.branch_hint'.tr()
                        : [
                            _branch!.address,
                            _branch!.city,
                            _branch!.government,
                          ].where((part) => part.trim().isNotEmpty).join(' - '),
                    leading: _branch == null
                        ? null
                        : const _PickerIcon(icon: Icons.location_on_outlined),
                    placeholderIcon: Icons.location_on_outlined,
                    isSelected: _branch != null,
                    onTap: _provider == null || _isSubmitting
                        ? null
                        : _chooseBranch,
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _FormSection(
              icon: Icons.edit_note_rounded,
              title: 'invoice.request_details'.tr(),
              child: Column(
                key: _detailsKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'invoice.notes_or_image_required'.tr(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.4,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'invoice.notes'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    key: _requestFieldKey,
                    controller: _notesController,
                    enabled: !_isSubmitting,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 500,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'invoice.notes_hint'.tr(),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: EdgeInsets.all(14.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(
                          color: Color(0xFF0F766E),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'invoice.prescription'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    key: _uploadButtonsKey,
                    children: [
                      Expanded(
                        child: _AttachmentAction(
                          icon: Icons.camera_alt_outlined,
                          label: 'invoice.take_photo'.tr(),
                          onTap: _isSubmitting
                              ? null
                              : () => _pickAttachment(ImageSource.camera),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _AttachmentAction(
                          icon: Icons.photo_library_outlined,
                          label: 'invoice.choose_photo'.tr(),
                          onTap: _isSubmitting
                              ? null
                              : () => _pickAttachment(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                  if (_attachments.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.w,
                        mainAxisSpacing: 8.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: _attachments.length,
                      itemBuilder: (_, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(_attachments[index].path),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 4.h,
                              right: 4.w,
                              child: GestureDetector(
                                onTap: _isSubmitting
                                    ? null
                                    : () => _removeAttachment(index),
                                child: Container(
                                  width: 22.w,
                                  height: 22.w,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 13.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              height: 54.h,
              child: FilledButton(
                onPressed: canSubmit ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSubmitting)
                      SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(Icons.send_rounded, size: 19),
                    SizedBox(width: 9.w),
                    Text(
                      _isSubmitting
                          ? 'common.loading'.tr()
                          : 'invoice.submit_request'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final int number;
  final String label;
  final bool complete;

  const _ProgressStep({
    required this.number,
    required this.label,
    required this.complete,
  });

  @override
  Widget build(BuildContext context) => Chip(
    backgroundColor: complete ? const Color(0xFFCCFBF1) : Colors.white,
    side: BorderSide(
      color: complete ? const Color(0xFF99F6E4) : const Color(0xFFE2E8F0),
    ),
    avatar: complete
        ? const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF0F766E),
            size: 18,
          )
        : CircleAvatar(
            backgroundColor: const Color(0xFFF1F5F9),
            child: Text('$number', style: const TextStyle(fontSize: 11)),
          ),
    label: Text(
      label,
      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF334155)),
    ),
  );
}

class _FormSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _FormSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(color: const Color(0xFFE7EDF3)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.035),
          blurRadius: 16.r,
          offset: Offset(0, 5.h),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F3),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(icon, size: 18.sp, color: const Color(0xFF0F766E)),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        child,
      ],
    ),
  );
}

class _AttachmentAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF0F766E),
      backgroundColor: const Color(0xFFF8FAFC),
      side: const BorderSide(color: Color(0xFFDCE7E8)),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.r)),
    ),
    child: Column(
      children: [
        Icon(icon, size: 21.sp),
        SizedBox(height: 5.h),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _RequiredLabel extends StatelessWidget {
  final String label;

  const _RequiredLabel(this.label);

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '$label ',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
          ),
        ),
        TextSpan(
          text: '*',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFFDC2626),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _SelectionButton extends StatelessWidget {
  final String label;
  final String supportingText;
  final VoidCallback? onTap;
  final Widget? leading;
  final IconData placeholderIcon;
  final bool isLoading;
  final bool isSelected;

  const _SelectionButton({
    super.key,
    required this.label,
    required this.supportingText,
    required this.onTap,
    required this.placeholderIcon,
    this.leading,
    this.isLoading = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: isSelected ? const Color(0xFFF5FBFA) : const Color(0xFFF8FAFC),
    borderRadius: BorderRadius.circular(14.r),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8CCBC2)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            leading ?? _PickerIcon(icon: placeholderIcon, muted: !isSelected),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    supportingText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            if (isLoading)
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                isSelected
                    ? Icons.edit_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 21.sp,
                color: const Color(0xFF64748B),
              ),
          ],
        ),
      ),
    ),
  );
}

class _PickerIcon extends StatelessWidget {
  final IconData icon;
  final bool muted;

  const _PickerIcon({required this.icon, this.muted = false});

  @override
  Widget build(BuildContext context) => Container(
    width: 42.w,
    height: 42.w,
    decoration: BoxDecoration(
      color: muted ? const Color(0xFFEFF3F7) : const Color(0xFFE8F5F3),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Icon(
      icon,
      size: 20.sp,
      color: muted ? const Color(0xFF64748B) : const Color(0xFF0F766E),
    ),
  );
}

class _ProviderLogo extends StatelessWidget {
  final String url;

  const _ProviderLogo({required this.url});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10.r),
    child: SizedBox(
      width: 42.w,
      height: 42.w,
      child: url.trim().isEmpty
          ? const ColoredBox(
              color: Color(0xFFE9EEF5),
              child: Icon(Icons.local_hospital_outlined),
            )
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => const ColoredBox(
                color: Color(0xFFE9EEF5),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, _, _) => const ColoredBox(
                color: Color(0xFFE9EEF5),
                child: Icon(Icons.local_hospital_outlined),
              ),
            ),
    ),
  );
}

class _InvoicePagedPicker<T> extends StatefulWidget {
  final String title;
  final String searchHint;
  final bool allowSearch;
  final Future<InvoicePage<T>> Function(String query, int page) loadPage;
  final String Function(T item) titleOf;
  final String Function(T item) subtitleOf;
  final double titleFontSize;
  final double subtitleFontSize;
  final Widget Function(T item)? leadingBuilder;
  final bool Function(T item)? isSelected;

  const _InvoicePagedPicker({
    required this.title,
    required this.searchHint,
    required this.allowSearch,
    required this.loadPage,
    required this.titleOf,
    required this.subtitleOf,
    required this.titleFontSize,
    required this.subtitleFontSize,
    this.leadingBuilder,
    this.isSelected,
  });

  @override
  State<_InvoicePagedPicker<T>> createState() => _InvoicePagedPickerState<T>();
}

class _InvoicePagedPickerState<T> extends State<_InvoicePagedPicker<T>> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _items = <T>[];
  Timer? _debounce;
  String _query = '';
  String? _error;
  int _page = 1;
  int _queryVersion = 0;
  bool _hasMore = true;
  bool _hasLoaded = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNextPage());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _loading || !_hasMore) return;
    if (_scrollController.position.extentAfter < 240) _loadNextPage();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _query = query.trim();
    _queryVersion++;
    setState(() {
      _items.clear();
      _page = 1;
      _hasMore = true;
      _hasLoaded = false;
      _loading = false;
      _error = null;
    });
    _debounce = Timer(const Duration(milliseconds: 350), _loadNextPage);
  }

  Future<void> _loadNextPage() async {
    if (!mounted || _loading || !_hasMore) return;
    final version = _queryVersion;
    final requestedPage = _page;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await widget.loadPage(_query, requestedPage);
      if (!mounted || version != _queryVersion) return;
      setState(() {
        _items.addAll(page.items);
        _hasMore = page.hasNextPage;
        _page++;
        _hasLoaded = true;
      });
    } catch (error) {
      if (!mounted || version != _queryVersion) return;
      setState(() {
        _error = error.toString();
        _hasLoaded = true;
      });
    } finally {
      if (mounted && version == _queryVersion) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.of(context).size.height * 0.84,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                    ),
                  ),
                ],
              ),
              if (widget.allowSearch) ...[
                SizedBox(height: 8.h),
                TextField(
                  controller: _searchController,
                  onChanged: _onQueryChanged,
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _onQueryChanged('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F766E),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE8EDF2)),
        Expanded(
          child: _items.isEmpty && (_loading || !_hasLoaded)
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0F766E)),
                )
              : _items.isEmpty && _error == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 42.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'common.no_data'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                  itemCount:
                      _items.length + (_hasMore || _error != null ? 1 : 0),
                  separatorBuilder: (_, _) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    if (index >= _items.length) {
                      if (_error != null) {
                        return Center(
                          child: TextButton.icon(
                            onPressed: _loadNextPage,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text('common.retry'.tr()),
                          ),
                        );
                      }
                      if (_loading) {
                        return Padding(
                          padding: EdgeInsets.all(16.h),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        );
                      }
                      return Center(
                        child: TextButton(
                          onPressed: _loadNextPage,
                          child: Text('invoice.load_more'.tr()),
                        ),
                      );
                    }

                    final item = _items[index];
                    final subtitle = widget.subtitleOf(item);
                    final isSelected = widget.isSelected?.call(item) ?? false;
                    return Material(
                      color: isSelected
                          ? const Color(0xFFF0F9F7)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15.r),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15.r),
                        onTap: () => Navigator.of(context).pop(item),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 11.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF91CFC5)
                                  : const Color(0xFFE8EDF2),
                            ),
                          ),
                          child: Row(
                            children: [
                              widget.leadingBuilder?.call(item) ??
                                  const _PickerIcon(
                                    icon: Icons.business_outlined,
                                  ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.titleOf(item),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: widget.titleFontSize.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (subtitle.isNotEmpty) ...[
                                      SizedBox(height: 3.h),
                                      Text(
                                        subtitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: widget.subtitleFontSize.sp,
                                          height: 1.35,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.chevron_right_rounded,
                                color: isSelected
                                    ? const Color(0xFF0F766E)
                                    : const Color(0xFF94A3B8),
                                size: 21.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}
