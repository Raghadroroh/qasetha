import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';

class CountdownTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onComplete;
  final Widget Function(int remainingSeconds)? builder;

  const CountdownTimer({
    super.key,
    required this.seconds,
    required this.onComplete,
    this.builder,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Ensure no previous timer is running
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          widget.onComplete();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return widget.builder!(_remainingSeconds);
    }

    return Text(
      '${context.l10n.resendIn} $_remainingSeconds ${context.l10n.seconds}',
      style: TextStyle(
        color: Theme.of(
          context,
        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        fontSize: 14,
      ),
    );
  }
}
