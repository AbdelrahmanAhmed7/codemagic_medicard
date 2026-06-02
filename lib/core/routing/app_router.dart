import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../medicard_network/logic/medicard_network_cubit.dart';
import '../../medicard_network/presentation/medicard_network_screen.dart';
import '../../presentation/logic/medicard_activation_cubit.dart';
import '../../presentation/logic/medicard_edit_profile_cubit.dart';
import '../../presentation/logic/medicard_home_cubit.dart';
import '../../presentation/logic/medicard_login_cubit.dart';
import '../../presentation/logic/medicard_support_cubit.dart';
import '../../presentation/medicard_edit_profile_screen.dart';
import '../../presentation/medicard_home_screen.dart';
import '../../presentation/medicard_login_screen.dart';
import '../../presentation/medicard_my_card_screen.dart';
import '../../presentation/medicard_selection_screen.dart';
import '../../presentation/medicard_signup_screen.dart';
import '../../presentation/medicard_splash_screen.dart';
import '../../presentation/medicard_support_screen.dart';
import '../di/service_locator.dart';

class AppRouter {
  static Future<String> getInitialLocation() async {
    return '/splash';
  }

  static GoRouter createRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const MedicardSplashScreen(),
        ),
        GoRoute(
          path: '/medicard',
          builder: (context, state) {
            return const MedicardSelectionScreen();
          },
        ),
        GoRoute(
          path: '/medicard-activation',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => sl<MedicardActivationCubit>(),
              child: const MediCardSignupScreen(),
            );
          },
        ),
        GoRoute(
          path: '/medicard-login',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => sl<MedicardLoginCubit>(),
              child: const MediCardLoginScreen(),
            );
          },
        ),
        GoRoute(
          path: '/medicard-home',
          builder: (context, state) {
            final cardNo = state.uri.queryParameters['cardNo'];
            return BlocProvider(
              create: (context) => sl<MedicardHomeCubit>(),
              child: MediCardHomeScreen(cardNo: cardNo),
            );
          },
        ),
        GoRoute(
          path: '/medicard-edit-profile',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final personalData = extra?['personalData'];
            final cardNo = extra?['cardNo'] as String?;
            if (personalData == null || cardNo == null) {
              return const Scaffold(
                body: Center(child: Text('Invalid parameters')),
              );
            }
            return BlocProvider(
              create: (context) => sl<MedicardEditProfileCubit>(),
              child: MedicardEditProfileScreen(
                personalData: personalData,
                cardNo: cardNo,
              ),
            );
          },
        ),
        GoRoute(
          path: '/medicard-my-card',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final personalData = extra?['personalData'];
            final cardNo = extra?['cardNo'] as String?;
            if (personalData == null || cardNo == null) {
              return const Scaffold(
                body: Center(child: Text('Invalid parameters')),
              );
            }
            return BlocProvider(
              create: (context) => sl<MedicardHomeCubit>(),
              child: MedicardMyCardScreen(
                personalData: personalData,
                cardNo: cardNo,
              ),
            );
          },
        ),
        GoRoute(
          path: '/medicard-network',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final searchQuery = extra?['searchQuery'] as String?;
            return BlocProvider(
              create: (context) => sl<MedicardNetworkCubit>(),
              child: MedicardNetworkScreen(initialSearchQuery: searchQuery),
            );
          },
        ),
        GoRoute(
          path: '/medicard-support',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => sl<MedicardSupportCubit>(),
              child: const MediCardSupportScreen(),
            );
          },
        ),
      ],
    );
  }
}
