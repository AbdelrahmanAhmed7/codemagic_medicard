import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/location_service.dart';
import '../core/network_colors.dart';
import '../logic/medicard_network_cubit.dart';
import '../../core/utils/language_helper.dart';
import 'provider_details_screen.dart';
import 'widgets/location_status_banner.dart';
import 'widgets/network_app_bar.dart';
import 'widgets/network_search_bar.dart';
import 'widgets/network_stats_ribbon.dart';
import 'widgets/network_categories_row.dart';
import 'widgets/network_filters_panel.dart';
import 'widgets/provider_card.dart';
import 'widgets/services_dialog.dart';
import 'widgets/network_state_widgets.dart';

class MedicardNetworkScreen extends StatefulWidget {
  final String? initialSearchQuery;

  const MedicardNetworkScreen({super.key, this.initialSearchQuery});

  @override
  State<MedicardNetworkScreen> createState() => _MedicardNetworkScreenState();
}

class _MedicardNetworkScreenState extends State<MedicardNetworkScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final LocationService _locationService = sl<LocationService>();

  bool _isLoadingMore = false;

  Timer? _debounceTimer;
  bool _isSearching = false;
  static const _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null) {
      _searchController.text = widget.initialSearchQuery!;
    }
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocationAndLoad());
  }

  void _onSearchChanged() {
    setState(() {});
    _debounceTimer?.cancel();

    final text = _searchController.text;

    if (text.isEmpty) {
      setState(() => _isSearching = false);
      context.read<MedicardNetworkCubit>().search(
        null,
        LanguageHelper.getLanguageCode(context),
      );
      return;
    }

    setState(() => _isSearching = true);

    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) return;
      setState(() => _isSearching = false);
      context.read<MedicardNetworkCubit>().search(
        text,
        LanguageHelper.getLanguageCode(context),
      );
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _lifecycleListener.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // AppLifecycle: only needed for permanently-denied permission recovery
  // (user went to app settings to grant permission manually).
  // GPS enabling is handled inline via the native SettingsClient dialog —
  // no onResume dependency needed for that path.
  late final AppLifecycleListener _lifecycleListener = AppLifecycleListener(
    onResume: () async {
      if (!mounted) return;
      final cubit = context.read<MedicardNetworkCubit>();
      final currentState = cubit.state;
      // Only act if we're in a loaded state that still has no location
      if (currentState is! MedicardNetworkLoaded) return;
      if (currentState.locationStatus != LocationAccessStatus.permanentlyDenied) return;

      // User may have just granted permission from app settings
      final result = await _locationService.tryGetLocationSilently();
      if (!mounted) return;
      if (result.hasCoordinates) {
        cubit.updateLocationAndRefresh(
          LanguageHelper.getLanguageCode(context),
          latitude: result.latitude!,
          longitude: result.longitude!,
          locationStatus: result.status,
        );
      }
    },
  );

  // ─── Location + initial load ───────────────────────────────────────────────
  //
  // Strict sequence — API fires EXACTLY ONCE after this completes:
  //   1. Request runtime permission (native dialog, stays in-app)
  //   2. If GPS off → invoke SettingsClient native dialog (stays in-app)
  //      → await result directly (enabled / rejected / error)
  //   3. Fetch coordinates
  //   4. Fire API with whatever result we have
  //
  // No polling. No onResume. No leaving the app.
  Future<void> _initLocationAndLoad() async {
    if (!mounted) return;
    final cubit = context.read<MedicardNetworkCubit>();
    final lang = LanguageHelper.getLanguageCode(context);

    // resolveLocation handles permission + GPS dialog + coordinate fetch
    // in strict sequence. The SettingsClient dialog is shown inline via
    // MethodChannel — this Future does NOT return until the user responds.
    final result = await _locationService.resolveLocation(
      requestIfNeeded: true,
    );
    if (!mounted) return;

    // Fire API exactly once with whatever we resolved
    cubit.loadInitialData(
      lang,
      latitude: result.latitude,
      longitude: result.longitude,
      locationStatus: result.status,
      initialSearchQuery: widget.initialSearchQuery,
    );
  }

  Future<void> _retryLocation() async {
    if (!mounted) return;
    final cubit = context.read<MedicardNetworkCubit>();
    final lang = LanguageHelper.getLanguageCode(context);

    // retryWithPermissionRequest → resolveLocation(requestIfNeeded: true)
    // which also handles GPS dialog inline if needed
    final result = await _locationService.retryWithPermissionRequest();
    if (!mounted) return;

    if (result.hasCoordinates) {
      cubit.updateLocationAndRefresh(
        lang,
        latitude: result.latitude!,
        longitude: result.longitude!,
        locationStatus: result.status,
      );
    } else {
      cubit.applyLocationResult(lang, result);
    }
  }

  Future<void> _openAppSettingsFromBanner() async {
    await _locationService.openAppSettings();
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    final cubit = context.read<MedicardNetworkCubit>();
    final lang = LanguageHelper.getLanguageCode(context);

    // Silent check — no dialogs on pull-to-refresh
    final result = await _locationService.tryGetLocationSilently();
    if (!mounted) return;

    if (result.hasCoordinates) {
      cubit.updateLocationAndRefresh(
        lang,
        latitude: result.latitude!,
        longitude: result.longitude!,
        locationStatus: result.status,
      );
    } else {
      cubit.loadInitialData(
        lang,
        locationStatus: result.status,
        initialSearchQuery: _searchController.text.isEmpty
            ? null
            : _searchController.text,
      );
    }
  }

  void _triggerLoadMore(BuildContext ctx) {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ctx.read<MedicardNetworkCubit>().loadMore(
        LanguageHelper.getLanguageCode(context),
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _isLoadingMore = false;
      });
    });
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openMaps(double lat, double lng, String? url) async {
    if (lat == 0 && lng == 0) return;
    try {
      final nav = Uri.parse('google.navigation:q=$lat,$lng');
      if (await canLaunchUrl(nav)) {
        await launchUrl(nav);
        return;
      }
      final web = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
      if (await launchUrl(web, mode: LaunchMode.externalApplication)) return;
      if (url != null && url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Maps error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NC.bg,
      body: BlocBuilder<MedicardNetworkCubit, MedicardNetworkState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: NC.primaryMid,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                const NetworkAppBar(),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: NetworkSearchBarDelegate(
                    searchController: _searchController,
                    showDiscountToggle: state is MedicardNetworkLoaded,
                    orderByDiscounts: state is MedicardNetworkLoaded
                        ? (state).orderByDiscounts
                        : false,
                    isSearching: _isSearching,
                    onSearch: (v) {
                      _debounceTimer?.cancel();
                      setState(() => _isSearching = false);
                      context.read<MedicardNetworkCubit>().search(
                        v.isEmpty ? null : v,
                        LanguageHelper.getLanguageCode(context),
                      );
                    },
                    onClear: () {
                      _debounceTimer?.cancel();
                      _searchController.clear();
                    },
                    onToggleDiscount: () => context
                        .read<MedicardNetworkCubit>()
                        .toggleOrderByDiscounts(
                          LanguageHelper.getLanguageCode(context),
                        ),
                  ),
                ),

                if (state is MedicardNetworkLoading)
                  const SliverToBoxAdapter(child: NetworkShimmerList()),

                if (state is MedicardNetworkError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: NetworkErrorView(
                      message: state.message,
                      onRetry: _initLocationAndLoad,
                    ),
                  ),

                if (state is MedicardNetworkLoaded) ...[
                  if (state.locationStatus != null &&
                      state.locationStatus != LocationAccessStatus.granted)
                    SliverToBoxAdapter(
                      child: LocationStatusBanner(
                        status: state.locationStatus!,
                        onRetry: _retryLocation,
                        onOpenSettings: _openAppSettingsFromBanner,
                      ),
                    ),

                  if (state.isLocationLoading)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: NC.primaryLt.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: NC.primaryLt.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: NC.primaryMid,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'network.loading_providers'.tr(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: NC.primaryMid,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: NetworkStatsRibbon(
                      categoryCount: state.categories.length,
                    ),
                  ),

                  if (state.categories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: NetworkCategoriesRow(
                        categories: state.categories,
                        selectedId: state.selectedCategoryId,
                        onSelect: (id) =>
                            context.read<MedicardNetworkCubit>().selectCategory(
                              id,
                              LanguageHelper.getLanguageCode(context),
                            ),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: NetworkFiltersPanel(
                      state: state,
                      onClearFilters: () {
                        _searchController.removeListener(_onSearchChanged);
                        _searchController.clear();
                        context.read<MedicardNetworkCubit>().clearFilters(
                          LanguageHelper.getLanguageCode(context),
                        );
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) {
                            _searchController.addListener(_onSearchChanged);
                          }
                        });
                      },
                      onGovernmentChanged: (id) =>
                          context.read<MedicardNetworkCubit>().selectGovernment(
                            id,
                            LanguageHelper.getLanguageCode(context),
                          ),
                      onCityChanged: (id) =>
                          context.read<MedicardNetworkCubit>().selectCity(
                            id,
                            LanguageHelper.getLanguageCode(context),
                          ),
                    ),
                  ),

                  if (state.providers.isEmpty)
                    if (state.isLoading)
                      const SliverToBoxAdapter(child: NetworkShimmerList())
                    else
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: NetworkEmptyState(
                          searchTerm: _searchController.text.isEmpty
                              ? null
                              : _searchController.text,
                          onSuggestionTap: (suggestion) {
                            _debounceTimer?.cancel();
                            _searchController.text = suggestion;
                            _searchController.selection =
                                TextSelection.collapsed(
                                  offset: suggestion.length,
                                );
                            setState(() => _isSearching = false);
                            context.read<MedicardNetworkCubit>().search(
                              suggestion,
                              LanguageHelper.getLanguageCode(context),
                            );
                          },
                        ),
                      )
                  else ...[
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'network.results_count'.tr(
                            args: [state.providers.length.toString()],
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: NC.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= state.providers.length) {
                              _triggerLoadMore(context);
                              return Padding(
                                padding: EdgeInsets.all(20.h),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: NC.primaryMid,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            final provider = state.providers[index];
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                milliseconds: 250 + (index % 6) * 60,
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (_, v, child) => Opacity(
                                opacity: v,
                                child: Transform.translate(
                                  offset: Offset(0, 18 * (1 - v)),
                                  child: child,
                                ),
                              ),
                              child: ProviderCard(
                                provider: provider,
                                onCall: _call,
                                onMaps: _openMaps,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProviderDetailsScreen(
                                      provider: provider,
                                    ),
                                  ),
                                ),
                                onShowServices: () => ServicesDialog.show(
                                  context,
                                  providerName: provider.providerName,
                                  providerLogo: provider.providerLogo,
                                  categoryName: provider.categoryName,
                                  services: provider.services ?? [],
                                ),
                              ),
                            );
                          },
                          childCount:
                              state.providers.length + (state.hasMore ? 1 : 0),
                        ),
                      ),
                    ),
                  ],

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 32.h + MediaQuery.of(context).padding.bottom,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
