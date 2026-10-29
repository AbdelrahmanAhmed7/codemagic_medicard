import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/helpers/shared_pref_helper.dart';
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

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF3F6FA),
    appBar: AppBar(
      title: Text('invoice.new_request'.tr()),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF17324D),
      surfaceTintColor: Colors.transparent,
    ),
    body: FutureBuilder<String>(
      future: _cardNoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final cardNo = snapshot.data ?? '';
        if (cardNo.isEmpty) {
          return _LoginRequired(onLogin: () => context.push('/medicard'));
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

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF3F6FA),
    appBar: AppBar(
      title: Text('invoice.my_invoices'.tr()),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF17324D),
      surfaceTintColor: Colors.transparent,
    ),
    body: FutureBuilder<String>(
      future: _cardNoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final cardNo = snapshot.data ?? '';
        if (cardNo.isEmpty) {
          return _LoginRequired(onLogin: () => context.push('/medicard'));
        }
        return _InvoiceListTab(cardNo: cardNo, repository: _repository);
      },
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

  const _InvoiceListTab({required this.cardNo, required this.repository});

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
  String _status = 'All';
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
        status: _status,
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F4F1),
                        borderRadius: BorderRadius.circular(17.r),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: const Color(0xFF0F766E),
                        size: 26.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'invoice.history_description'.tr(),
                            style: TextStyle(
                              color: const Color(0xFF17324D),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'invoice.history_hint'.tr(),
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: 12.sp,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children:
                      [
                            'All',
                            'Pending',
                            'Approved',
                            'Completed',
                            'Rejected',
                            'Cancelled',
                          ]
                          .map(
                            (status) => Padding(
                              padding: EdgeInsetsDirectional.only(end: 8.w),
                              child: ChoiceChip(
                                label: Text(
                                  status == 'All'
                                      ? 'invoice.all_statuses'.tr()
                                      : 'invoice.status_${status.toLowerCase()}'
                                            .tr(),
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _status == status
                                      ? const Color(0xFF0F766E)
                                      : const Color(0xFF64748B),
                                ),
                                selected: _status == status,
                                selectedColor: const Color(0xFFCCFBF1),
                                backgroundColor: Colors.white,
                                showCheckmark: false,
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 6.h,
                                ),
                                shape: const StadiumBorder(),
                                side: BorderSide(
                                  color: _status == status
                                      ? const Color(0xFF82C7BB)
                                      : const Color(0xFFE6EBF0),
                                ),
                                onSelected: (selected) {
                                  if (!selected || _status == status) return;
                                  _status = status;
                                  if (_scrollController.hasClients) {
                                    _scrollController.jumpTo(0);
                                  }
                                  reload();
                                },
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              Expanded(child: _buildList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    if (_isInitialLoad && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_invoices.isEmpty && _error != null) {
      return _ErrorState(message: 'invoice.load_failed'.tr(), onRetry: reload);
    }
    if (_invoices.isEmpty) {
      return RefreshIndicator(
        onRefresh: reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 48.h),
            Icon(
              Icons.receipt_long_outlined,
              size: 60.sp,
              color: const Color(0xFF98A4B5),
            ),
            SizedBox(height: 14.h),
            Center(
              child: Text(
                (_status == 'All' ? 'invoice.empty' : 'invoice.empty_filter')
                    .tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.black54),
              ),
            ),
            if (_status == 'All') ...[
              SizedBox(height: 16.h),
              Center(
                child: FilledButton.icon(
                  onPressed: () => context.push('/medicard-invoices'),
                  icon: const Icon(Icons.add_rounded),
                  label: Text('invoice.new_request'.tr()),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: reload,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        itemCount: _invoices.length + (_hasMore || _error != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _invoices.length) {
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
          return _InvoiceCard(invoice: _invoices[index]);
        },
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceRecord invoice;

  const _InvoiceCard({required this.invoice});

  Color get _statusColor {
    switch (invoice.status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return const Color(0xFF15803D);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFFB45309);
    }
  }

  String get _statusLabel {
    switch (invoice.status.toLowerCase()) {
      case 'pending':
        return 'invoice.status_pending'.tr();
      case 'approved':
        return 'invoice.status_approved'.tr();
      case 'completed':
        return 'invoice.status_completed'.tr();
      case 'rejected':
        return 'invoice.status_rejected'.tr();
      case 'cancelled':
        return 'invoice.status_cancelled'.tr();
      default:
        return invoice.status;
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.only(bottom: 14.h),
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 1.5,
    shadowColor: const Color(0xFF17324D).withValues(alpha: 0.07),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.r),
      side: const BorderSide(color: Color(0xFFE8EDF2)),
    ),
    child: Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  width: 52.w,
                  height: 52.w,
                  color: const Color(0xFFF0F5F6),
                  child: invoice.providerLogo.isEmpty
                      ? Icon(
                          Icons.local_hospital_outlined,
                          color: const Color(0xFF0F766E),
                          size: 25.sp,
                        )
                      : CachedNetworkImage(
                          imageUrl: invoice.providerLogo,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Icon(
                            Icons.local_hospital_outlined,
                            color: const Color(0xFF0F766E),
                            size: 25.sp,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Text(
                  invoice.providerName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17324D),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'invoice.request_number'.tr(args: [invoice.id.toString()]),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (invoice.notes.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FB),
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Text(
                invoice.notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.4,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
          if (invoice.createdAt != null ||
              invoice.lineCount > 0 ||
              invoice.totalAmount > 0) ...[
            SizedBox(height: 14.h),
            Container(height: 1, color: const Color(0xFFF0F3F6)),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
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
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF6F3),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${NumberFormat.decimalPattern(context.locale.languageCode).format(invoice.totalAmount)} ${'common.egp'.tr()}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

class _InvoiceMetadata extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InvoiceMetadata({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14.sp, color: const Color(0xFF94A3B8)),
      SizedBox(width: 5.w),
      Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w600,
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
