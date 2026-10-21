import 'dart:async';

import 'package:flutter/widgets.dart';

import '../constants/assets.dart';

/// Loads + decodes images into Flutter's ImageCache ahead of time so they
/// appear instantly instead of popping in while the user scrolls.
///
/// Phase 1 (critical): runs while the first frame is deferred, so the HTML
///   loader in web/index.html stays on screen until these are ready.
///   Capped by [criticalTimeout] so a slow network can never hang the page.
/// Phase 2 (deferred): runs one image at a time after the first frame.
class ImageWarmup {
  ImageWarmup._();

  static bool _started = false;

  static const Duration criticalTimeout = Duration(seconds: 5);

  static Future<void> _precache(BuildContext context, String path) async {
    try {
      await precacheImage(AssetImage(path), context);
    } catch (_) {
      // A missing/failed image must never block startup.
    }
  }

  /// Call once, from a widget that sits below MaterialApp.
  static Future<void> run(BuildContext context) async {
    if (_started) return;
    _started = true;

    // ---- Phase 1: critical, in parallel, with a timeout ---------------
    try {
      await Future.wait(
        AppAssets.critical.map((p) => _precache(context, p)),
      ).timeout(criticalTimeout);
    } catch (_) {
      // timeout -> carry on; remaining images will load normally.
    }

    // Let the first frame through -> the HTML loader fades out.
    WidgetsBinding.instance.allowFirstFrame();

    // ---- Phase 2: everything else, gently, after the first paint ------
    await Future<void>.delayed(const Duration(milliseconds: 600));
    for (final path in AppAssets.deferred) {
      if (!context.mounted) return;
      await _precache(context, path);
      // Small gap keeps the main thread free for scrolling/animations.
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }
}
