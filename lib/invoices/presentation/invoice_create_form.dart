import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theming/app_snack_bar.dart';
import '../data/invoice_models.dart';
import '../repository/invoice_repository.dart';

class InvoiceCreateForm extends StatefulWidget {
  final String cardNo;
  final InvoiceRepository repository;
  final int? initialProviderId;
  final String? initialProviderName;

  const InvoiceCreateForm({
    super.key,
    required this.cardNo,
    required this.repository,
    this.initialProviderId,
    this.initialProviderName,
  });

  @override
  State<InvoiceCreateForm> createState() => _InvoiceCreateFormState();
}

class _InvoiceCreateFormState extends State<InvoiceCreateForm> {
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  InvoiceProvider? _provider;
  InvoiceBranch? _branch;
  XFile? _attachment;
  bool _isSubmitting = false;
  bool _isLoadingInitialProvider = false;

  String get _lang => context.locale.languageCode;

  @override
  void initState() {
    super.initState();
    if (widget.initialProviderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialProvider();
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
    Widget Function(T item)? leadingBuilder,
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
        leadingBuilder: leadingBuilder,
      ),
    );
  }

  Future<void> _pickAttachment(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image != null && mounted) setState(() => _attachment = image);
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showError(error);
    }
  }

  Future<void> _submit() async {
    final provider = _provider;
    final branch = _branch;
    final notes = _notesController.text.trim();
    final attachment = _attachment;
    if (provider == null ||
        branch == null ||
        (notes.isEmpty && attachment == null)) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.repository.createInvoice(
        lang: _lang,
        cardNo: widget.cardNo,
        providerId: provider.providerId,
        providerLocationId: branch.locationId,
        notes: notes,
        attachment: attachment,
      );
      if (!mounted) return;
      _notesController.clear();
      setState(() {
        _provider = null;
        _branch = null;
        _attachment = null;
      });
      showAppSnackBar(
        context,
        'invoice.created_successfully'.tr(),
        type: SnackBarType.success,
      );
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(Object error) {
    showAppSnackBar(
      context,
      error.toString(),
      type: SnackBarType.error,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _provider != null &&
        _branch != null &&
        (_notesController.text.trim().isNotEmpty || _attachment != null) &&
        !_isSubmitting;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        20.w,
        24.h + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        Text(
          'invoice.create_title'.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 18.h),
        _RequiredLabel('invoice.provider'.tr()),
        SizedBox(height: 7.h),
        _SelectionButton(
          label:
              _provider?.providerName.trim() ??
              (_isLoadingInitialProvider
                  ? 'common.loading'.tr()
                  : 'invoice.choose_provider'.tr()),
          leading: _provider == null
              ? null
              : _ProviderLogo(url: _provider!.providerLogo),
          onTap: _isLoadingInitialProvider ? null : _chooseProvider,
        ),
        SizedBox(height: 16.h),
        _RequiredLabel('invoice.branch'.tr()),
        SizedBox(height: 7.h),
        _SelectionButton(
          label: _branch == null
              ? 'invoice.choose_branch'.tr()
              : [
                  _branch!.branchName,
                  _branch!.area,
                  _branch!.city,
                ].where((part) => part.trim().isNotEmpty).join(' - '),
          onTap: _provider == null ? null : _chooseBranch,
        ),
        SizedBox(height: 16.h),
        Text(
          'invoice.notes_or_image_required'.tr(),
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
        ),
        SizedBox(height: 8.h),
        Text(
          'invoice.notes'.tr(),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 7.h),
        TextField(
          controller: _notesController,
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'invoice.notes_hint'.tr(),
            alignLabelWithHint: true,
            filled: true,
            fillColor: const Color(0xFFF6F8FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'invoice.prescription'.tr(),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 7.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickAttachment(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text('invoice.take_photo'.tr()),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickAttachment(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text('invoice.choose_photo'.tr()),
              ),
            ),
          ],
        ),
        if (_attachment != null) ...[
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Image.file(
              File(_attachment!.path),
              height: 190.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () => setState(() => _attachment = null),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text('common.delete'.tr()),
            ),
          ),
        ],
        SizedBox(height: 20.h),
        SizedBox(
          height: 52.h,
          child: FilledButton.icon(
            onPressed: canSubmit ? _submit : null,
            icon: _isSubmitting
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              _isSubmitting
                  ? 'common.loading'.tr()
                  : 'invoice.submit_request'.tr(),
            ),
          ),
        ),
      ],
    );
  }
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
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
        TextSpan(
          text: '*',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _SelectionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? leading;

  const _SelectionButton({
    required this.label,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14.r),
    child: InputDecorator(
      decoration: InputDecoration(
        enabled: onTap != null,
        suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
        filled: true,
        fillColor: const Color(0xFFF6F8FB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, SizedBox(width: 10.w)],
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
        ],
      ),
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
  final Widget Function(T item)? leadingBuilder;

  const _InvoicePagedPicker({
    required this.title,
    required this.searchHint,
    required this.allowSearch,
    required this.loadPage,
    required this.titleOf,
    required this.subtitleOf,
    this.leadingBuilder,
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
    height: MediaQuery.of(context).size.height * 0.78,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8DFE8),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                widget.title,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
              ),
              if (widget.allowSearch) ...[
                SizedBox(height: 12.h),
                TextField(
                  controller: _searchController,
                  onChanged: _onQueryChanged,
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF6F8FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _items.isEmpty && (_loading || !_hasLoaded)
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty && _error == null
              ? Center(child: Text('common.no_data'.tr()))
              : ListView.separated(
                  controller: _scrollController,
                  itemCount:
                      _items.length + (_hasMore || _error != null ? 1 : 0),
                  separatorBuilder: (_, _) => const Divider(height: 1),
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
                            child: CircularProgressIndicator(),
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
                    return ListTile(
                      leading: widget.leadingBuilder?.call(item),
                      title: Text(
                        widget.titleOf(item),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: subtitle.isEmpty ? null : Text(subtitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).pop(item),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}
