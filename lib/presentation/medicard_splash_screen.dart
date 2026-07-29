import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/constants.dart';
import '../core/helpers/shared_pref_helper.dart';

class MedicardSplashScreen extends StatefulWidget {
  const MedicardSplashScreen({super.key});

  @override
  State<MedicardSplashScreen> createState() => _MedicardSplashScreenState();
}

class _MedicardSplashScreenState extends State<MedicardSplashScreen> {
  late final VideoPlayerController _videoController;
  Timer? _fallbackTimer;
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      AppAssets.medicardSplashVideo,
    )..addListener(_handleVideoProgress);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      await _videoController.setLooping(false);
      await _videoController.play();
      if (mounted) setState(() {});
      _fallbackTimer = Timer(const Duration(seconds: 4), _navigate);
    } catch (_) {
      _fallbackTimer = Timer(const Duration(seconds: 2), _navigate);
    }
  }

  void _handleVideoProgress() {
    if (!_videoController.value.isInitialized ||
        !_videoController.value.isCompleted) {
      return;
    }
    _navigate();
  }

  Future<void> _navigate() async {
    if (_didNavigate) return;
    _didNavigate = true;
    _fallbackTimer?.cancel();

    final cardNo = await SharedPrefHelper.getString(
      SharedPrefKeys.medicardCardNo,
    );

    if (!mounted) return;
    if (cardNo.isNotEmpty) {
      context.go('/medicard-home?cardNo=$cardNo');
    } else {
      context.go('/medicard');
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _videoController
      ..removeListener(_handleVideoProgress)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: _videoController.value.isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              )
            : Center(
                child: Image.asset(
                  AppAssets.mediLogo,
                  width: 120,
                  fit: BoxFit.contain,
                ),
              ),
      ),
    );
  }
}
