import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/helpers/shared_pref_helper.dart';
import '../../core/services/url_launcher_service.dart';
import '../../core/theming/app_toast.dart';
import '../data/invoice_models.dart';
import '../repository/invoice_repository.dart';
import 'invoice_create_form.dart';

class InvoicesScreen extends StatefulWidget {
  final String? cardNo;
  final int? initialProviderId;
  final String? initialProviderName;
  final bool runTutorial;

  const InvoicesScreen({
    super.key,
    this.cardNo,
    this.initialProviderId,
    this.initialProviderName,
    this.runTutorial = false,
  });

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late final Future<String> _cardNoFuture;
  late final InvoiceRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = sl<InvoiceRepository>();
    _cardNoFuture = _resolveCardNo();
  }

  Future<String> _resolveCardNo() async {
    final suppliedCardNo = widget.cardNo?.trim() ?? '';
    if (suppliedCardNo.isNotEmpty) return suppliedCardNo;
    return (await SharedPrefHelper.getString(
      SharedPrefKeys.medicardCardNo,
    )).trim();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/medicard-home');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF3F6FA),
    body: SafeArea(
      child: Column(
        children: [
          _IntegratedPageHeader(
            title: 'invoice.new_request'.tr(),
            onBack: _goBack,
          ),
          Expanded(
            child: FutureBuilder<String>(
              future: _cardNoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cardNo = snapshot.data ?? '';
                if (cardNo.isEmpty) {
                  return _LoginRequired(
                    onLogin: () => context.push('/medicard'),
                  );
                }
                return InvoiceCreateForm(
                  key: ValueKey(widget.initialProviderId),
                  cardNo: cardNo,
                  repository: _repository,
                  initialProviderId: widget.initialProviderId,
                  initialProviderName: widget.initialProviderName,
                  runTutorial: widget.runTutorial,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class InvoiceHistoryScreen extends StatefulWidget {
  final String? cardNo;

  const InvoiceHistoryScreen({super.key, this.cardNo});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  late final Future<String> _cardNoFuture;
  late final InvoiceRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = sl<InvoiceRepository>();
    _cardNoFuture = _resolveCardNo();
  }

  Future<String> _resolveCardNo() async {
    final suppliedCardNo = widget.cardNo?.trim() ?? '';
    if (suppliedCardNo.isNotEmpty) return suppliedCardNo;
    return (await SharedPrefHelper.getString(
      SharedPrefKeys.medicardCardNo,
    )).trim();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/medicard-home');
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: context.canPop(),
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _goBack();
    },
    child: Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _cardNoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Column(
                children: [
                  _IntegratedPageHeader(
                    title: 'invoice.my_invoices'.tr(),
                    onBack: _goBack,
                  ),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }
            final cardNo = snapshot.data ?? '';
            if (cardNo.isEmpty) {
              return Column(
                children: [
                  _IntegratedPageHeader(
                    title: 'invoice.my_invoices'.tr(),
                    onBack: _goBack,
                  ),
                  Expanded(
                    child: _LoginRequired(
                      onLogin: () => context.push('/medicard'),
                    ),
                  ),
                ],
              );
            }
            return _InvoiceListTab(
              cardNo: cardNo,
              repository: _repository,
              onBack: _goBack,
            );
          },
        ),
      ),
    ),
  );
}

class _IntegratedPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _IntegratedPageHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(12.w, 8.h, 16.w, 6.h),
    child: Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: IconButton(
            onPressed: onBack,
            tooltip: 'common.back'.tr(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: const Color(0xFF17324D),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFF17324D),
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _LoginRequired extends StatelessWidget {
  final VoidCallback onLogin;

  const _LoginRequired({required this.onLogin});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(28.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.credit_card_off_rounded,
            size: 56.sp,
            color: const Color(0xFF1E3A8A),
          ),
          SizedBox(height: 16.h),
          Text(
            'invoice.login_required'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16.h),
          FilledButton(
            onPressed: onLogin,
            child: Text('medicard_home.guest_login_title'.tr()),
          ),
        ],
      ),
    ),
  );
}

class _InvoiceListTab extends StatefulWidget {
  final String cardNo;
  final InvoiceRepository repository;
  final VoidCallback onBack;

  const _InvoiceListTab({
    required this.cardNo,
    required this.repository,
    required this.onBack,
  });

  @override
  State<_InvoiceListTab> createState() => _InvoiceListTabState();
}

class _InvoiceListTabState extends State<_InvoiceListTab> {
  final _scrollController = ScrollController();
  final _invoices = <InvoiceRecord>[];
  int _page = 1;
  int _requestVersion = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isInitialLoad = true;
  String? _error;
  String? _loadedLanguage;

  String get _lang => context.locale.languageCode;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedLanguage == _lang) return;
    _loadedLanguage = _lang;
    reload();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading || !_hasMore) return;
    if (_scrollController.position.extentAfter < 240) _loadNextPage();
  }

  Future<void> reload() async {
    if (!mounted) return;
    _requestVersion++;
    setState(() {
      _invoices.clear();
      _page = 1;
      _hasMore = true;
      _error = null;
      _isInitialLoad = true;
      _isLoading = false;
    });
    await _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (!mounted || _isLoading || !_hasMore) return;
    final requestVersion = _requestVersion;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await widget.repository.getInvoices(
        lang: _lang,
        cardNo: widget.cardNo,
        status: 'All',
        page: _page,
      );
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _invoices.addAll(result.items);
        _hasMore = result.hasNextPage;
        _page++;
        _isInitialLoad = false;
      });
    } catch (error) {
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _error = error.toString();
        _isInitialLoad = false;
      });
    } finally {
      if (mounted && requestVersion == _requestVersion) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showCancelDialog(InvoiceRecord invoice) async {
    final reasonController = TextEditingController();
    var isSubmitting = false;
    String? reasonError;

    final message = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('invoice.cancel_title'.tr()),
          content: TextField(
            controller: reasonController,
            enabled: !isSubmitting,
            minLines: 3,
            maxLines: 5,
            autofocus: true,
            onChanged: (_) {
              if (reasonError != null) {
                setDialogState(() => reasonError = null);
              }
            },
            decoration: InputDecoration(
              labelText: 'invoice.cancel_reason'.tr(),
              hintText: 'invoice.cancel_reason_hint'.tr(),
              errorText: reasonError,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB91C1C),
              ),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) {
                        setDialogState(
                          () => reasonError = 'invoice.cancel_reason_required'
                              .tr(),
                        );
                        return;
                      }
                      setDialogState(() => isSubmitting = true);
                      try {
                        final backendMessage = await widget.repository
                            .cancelInvoice(
                              lang: _lang,
                              cardNo: widget.cardNo,
                              invoiceId: invoice.id,
                              reason: reason,
                            );
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop(backendMessage);
                        }
                      } catch (error) {
                        if (!dialogContext.mounted) return;
                        showErrorToast(error.toString());
                        setDialogState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('invoice.confirm_cancel'.tr()),
            ),
          ],
        ),
      ),
    );
    reasonController.dispose();

    if (!mounted || message == null) return;
    if (message.isNotEmpty) showSuccessToast(message);
    await reload();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: _buildList(context),
    ),
  );

  Widget _buildList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: reload,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: 16.h + MediaQuery.of(context).padding.bottom,
        ),
        itemCount:
            1 +
            (_invoices.isEmpty
                ? 1
                : _invoices.length + (_hasMore || _error != null ? 1 : 0)),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _IntegratedPageHeader(
              title: 'invoice.my_invoices'.tr(),
              onBack: widget.onBack,
            );
          }
          final invoiceIndex = index - 1;
          if (_invoices.isEmpty) {
            if (_isInitialLoad && _isLoading) {
              return Padding(
                padding: EdgeInsets.only(top: 72.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            if (_error != null) {
              return _ErrorState(
                message: 'invoice.load_failed'.tr(),
                onRetry: reload,
              );
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 42.h, 20.w, 20.h),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 60.sp,
                    color: const Color(0xFF98A4B5),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'invoice.empty'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                  ),
                  SizedBox(height: 16.h),
                  FilledButton.icon(
                    onPressed: () => context.push('/medicard-invoices'),
                    icon: const Icon(Icons.add_rounded),
                    label: Text('invoice.new_request'.tr()),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
            );
          }

          if (invoiceIndex >= _invoices.length) {
            if (_error != null) {
              return Center(
                child: TextButton.icon(
                  onPressed: _loadNextPage,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('common.retry'.tr()),
                ),
              );
            }
            if (_isLoading) {
              return Padding(
                padding: EdgeInsets.all(18.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return Center(
              child: TextButton(
                onPressed: _loadNextPage,
                child: Text('invoice.load_more'.tr()),
              ),
            );
          }
          final invoice = _invoices[invoiceIndex];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _InvoiceCard(
              invoice: invoice,
              onCancel: invoice.isPending
                  ? () => _showCancelDialog(invoice)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceRecord invoice;
  final VoidCallback? onCancel;

  const _InvoiceCard({required this.invoice, this.onCancel});

  Color get _statusColor {
    switch (invoice.status.trim().toLowerCase()) {
      case 'approved':
      case 'completed':
        return const Color(0xFF15803D);
      case 'rejected':
      case 'canceled':
      case 'cancelled':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFFB45309);
    }
  }

  String get _statusLabel {
    switch (invoice.status.trim().toLowerCase()) {
      case 'pending':
        return 'invoice.status_pending'.tr();
      case 'approved':
        return 'invoice.status_approved'.tr();
      case 'completed':
        return 'invoice.status_completed'.tr();
      case 'rejected':
        return 'invoice.status_rejected'.tr();
      case 'canceled':
      case 'cancelled':
        return 'invoice.status_cancelled'.tr();
      default:
        return invoice.status;
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.only(bottom: 10.h),
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
      side: const BorderSide(color: Color(0xFFE8EDF2)),
    ),
    child: Padding(
      padding: EdgeInsets.all(13.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  width: 42.w,
                  height: 42.w,
                  color: const Color(0xFFF0F5F6),
                  child: invoice.providerLogo.isEmpty
                      ? Icon(
                          Icons.local_hospital_outlined,
                          color: const Color(0xFF0F766E),
                          size: 21.sp,
                        )
                      : CachedNetworkImage(
                          imageUrl: invoice.providerLogo,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Icon(
                            Icons.local_hospital_outlined,
                            color: const Color(0xFF0F766E),
                            size: 21.sp,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.providerName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF17324D),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'invoice.request_number'.tr(
                        args: [invoice.id.toString()],
                      ),
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: _statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (invoice.branchName.trim().isNotEmpty) ...[
            SizedBox(height: 11.h),
            _InvoiceDetail(
              icon: Icons.storefront_outlined,
              title: 'invoice.branch'.tr(),
              value: invoice.branchName.trim(),
            ),
          ],
          if (invoice.address.trim().isNotEmpty) ...[
            SizedBox(height: 7.h),
            _InvoiceDetail(
              icon: Icons.location_on_outlined,
              title: 'invoice.address'.tr(),
              value: invoice.address.trim(),
            ),
          ],
          if (invoice.notes.trim().isNotEmpty) ...[
            SizedBox(height: 7.h),
            _InvoiceDetail(
              icon: Icons.medical_services_outlined,
              title: 'invoice.requested_service'.tr(),
              value: invoice.notes.trim(),
            ),
          ],
          if (invoice.cancelReason.trim().isNotEmpty) ...[
            SizedBox(height: 7.h),
            _InvoiceDetail(
              icon: Icons.report_gmailerrorred_rounded,
              title: 'invoice.cancel_reason'.tr(),
              value: invoice.cancelReason.trim(),
              isDestructive: true,
            ),
          ],
          if (invoice.createdAt != null ||
              invoice.lineCount > 0 ||
              invoice.totalAmount > 0) ...[
            SizedBox(height: 11.h),
            Container(height: 1, color: const Color(0xFFF0F3F6)),
            SizedBox(height: 9.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 6.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (invoice.createdAt != null)
                  _InvoiceMetadata(
                    icon: Icons.calendar_today_rounded,
                    label: DateFormat.yMMMd(
                      context.locale.languageCode,
                    ).format(invoice.createdAt!.toLocal()),
                  ),
                if (invoice.lineCount > 0)
                  _InvoiceMetadata(
                    icon: Icons.receipt_outlined,
                    label: 'invoice.line_count'.tr(
                      args: [invoice.lineCount.toString()],
                    ),
                  ),
                if (invoice.totalAmount > 0)
                  _InvoiceMetadata(
                    icon: Icons.payments_outlined,
                    label:
                        '${NumberFormat.decimalPattern(context.locale.languageCode).format(invoice.totalAmount)} ${'common.egp'.tr()}',
                    color: const Color(0xFF0F766E),
                    emphasize: true,
                  ),
              ],
            ),
          ],
          if (invoice.invoicePdfUrl.isNotEmpty || onCancel != null) ...[
            SizedBox(height: 10.h),
            Container(height: 1, color: const Color(0xFFF0F3F6)),
            SizedBox(height: 4.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                spacing: 4.w,
                runSpacing: 2.h,
                alignment: WrapAlignment.end,
                children: [
                  if (invoice.invoicePdfUrl.isNotEmpty)
                    TextButton.icon(
                      onPressed: () =>
                          UrlLauncherService().launchURL(invoice.invoicePdfUrl),
                      icon: Icon(Icons.download_rounded, size: 17.sp),
                      label: Text('invoice.download_pdf'.tr()),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0F766E),
                        visualDensity: VisualDensity.compact,
                        textStyle: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (onCancel != null)
                    TextButton.icon(
                      onPressed: onCancel,
                      icon: Icon(Icons.cancel_outlined, size: 17.sp),
                      label: Text('invoice.cancel_invoice'.tr()),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFB91C1C),
                        visualDensity: VisualDensity.compact,
                        textStyle: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _InvoiceDetail extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDestructive;

  const _InvoiceDetail({
    required this.icon,
    required this.title,
    required this.value,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFFB91C1C)
        : const Color(0xFF475569);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Icon(icon, size: 16.sp, color: color.withValues(alpha: 0.82)),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$title:  ',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            style: TextStyle(fontSize: 11.5.sp, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _InvoiceMetadata extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool emphasize;

  const _InvoiceMetadata({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF64748B),
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14.sp, color: color.withValues(alpha: 0.75)),
      SizedBox(width: 5.w),
      Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    ],
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Colors.redAccent,
            size: 42,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp),
          ),
          SizedBox(height: 12.h),
          FilledButton.tonal(
            onPressed: onRetry,
            child: Text('common.retry'.tr()),
          ),
        ],
      ),
    ),
  );
}
