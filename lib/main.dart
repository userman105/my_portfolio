import 'dart:ui';

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/image_warmup.dart';
import 'features/home/home_page.dart';

void main() {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // Hold the first frame so the HTML loader stays visible while the critical
  // images are fetched and decoded. ImageWarmup calls allowFirstFrame().
  binding.deferFirstFrame();

  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Portfolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.aero,
      home: const _WarmupGate(child: HomePage()),
      scrollBehavior: const _WebScrollBehavior(),
    );
  }
}

/// Sits below MaterialApp (so precacheImage has a valid context) and kicks
/// off image warm-up exactly once.
class _WarmupGate extends StatefulWidget {
  final Widget child;
  const _WarmupGate({required this.child});

  @override
  State<_WarmupGate> createState() => _WarmupGateState();
}

class _WarmupGateState extends State<_WarmupGate> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    ImageWarmup.run(context);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _WebScrollBehavior extends ScrollBehavior {
  const _WebScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };
}
