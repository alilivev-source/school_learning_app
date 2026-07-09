import 'package:flutter/material.dart';
import 'dart:async';
import '../app_colors.dart';

/// مؤقّت تقدّم دائري يُستخدم في التمارين محدودة الوقت
class ProgressTimer extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback? onComplete;
  final Color color;
  final double size;
  final bool autoStart;

  const ProgressTimer({
    super.key,
    this.durationSeconds = 30,
    this.onComplete,
    this.color = AppColors.primary,
    this.size = 60,
    this.autoStart = true,
  });

  @override
  State<ProgressTimer> createState() => ProgressTimerState();
}

class ProgressTimerState extends State<ProgressTimer> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    if (widget.autoStart) start();
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _isRunning = false;
        widget.onComplete?.call();
        return;
      }
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void pause() {
    _timer?.cancel();
    _isRunning = false;
  }

  void reset() {
    _timer?.cancel();
    _isRunning = false;
    setState(() {
      _remainingSeconds = widget.durationSeconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.durationSeconds == 0
        ? 0.0
        : _remainingSeconds / widget.durationSeconds;
    final isLow = _remainingSeconds <= 5;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 5,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isLow ? Colors.red : widget.color,
              ),
            ),
          ),
          Text(
            '$_remainingSeconds',
            style: TextStyle(
              fontSize: widget.size * 0.3,
              fontWeight: FontWeight.bold,
              color: isLow ? Colors.red : widget.color,
            ),
          ),
        ],
      ),
    );
  }
}
