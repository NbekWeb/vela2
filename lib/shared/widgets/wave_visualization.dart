import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../pages/meditation_streaming/helpers.dart';

/// Wave visualization widget
class WaveVisualization extends StatefulWidget {
  final List<Uint8List> pcmChunks;
  final double height;
  final Duration? duration;
  final Duration? position;

  const WaveVisualization({
    super.key,
    required this.pcmChunks,
    this.height = 120,
    this.duration,
    this.position,
  });

  @override
  State<WaveVisualization> createState() => _WaveVisualizationState();
}

class _WaveVisualizationState extends State<WaveVisualization> {
  List<double> _amplitudes = [];
  Timer? _updateTimer;
  Duration? _lastPosition;
  Duration? _lastDuration;

  @override
  void initState() {
    super.initState();
    _updateAmplitudes();
    _lastPosition = widget.position;
    _lastDuration = widget.duration;
    // Update amplitudes and check position periodically to reflect real-time audio changes
    _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
        // Update amplitudes if chunks changed
        _updateAmplitudes();
        // Force repaint if position or duration changed (for real-time waveform progress)
        if (_lastPosition != widget.position || _lastDuration != widget.duration) {
          _lastPosition = widget.position;
          _lastDuration = widget.duration;
          setState(() {
            // Force CustomPaint to repaint with new position/duration
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(WaveVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update amplitudes if chunks changed
    if (oldWidget.pcmChunks.length != widget.pcmChunks.length) {
      _updateAmplitudes();
    }
    // Force repaint if position or duration changed (for waveform progress visualization)
    if (oldWidget.duration != widget.duration ||
        oldWidget.position != widget.position) {
      // Trigger rebuild to update waveform progress visualization
      if (mounted) {
        setState(() {
          // Force CustomPaint to repaint with new position/duration
        });
      }
    }
  }

  void _updateAmplitudes() {
    final newAmplitudes = extractAmplitudes(widget.pcmChunks, 100);
    if (mounted && newAmplitudes.isNotEmpty) {
      setState(() {
        _amplitudes = newAmplitudes;
      });
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_amplitudes.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.pink],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      );
    }

    return CustomPaint(
      size: Size(double.infinity, widget.height),
      painter: WavePainter(
        amplitudes: _amplitudes,
        duration: widget.duration,
        position: widget.position,
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final List<double> amplitudes;
  final Duration? duration;
  final Duration? position;

  WavePainter({
    required this.amplitudes,
    this.duration,
    this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final centerY = size.height / 2;
    final barWidth = size.width / amplitudes.length;
    final spacing = math.max(0.5, barWidth * 0.15); // Minimal spacing for clean look
    final actualBarWidth = math.max(1.5, barWidth - spacing);

    // Calculate playback progress (0.0 to 1.0)
    double progress = 0.0;
    if (duration != null && position != null && duration!.inMilliseconds > 0) {
      progress = (position!.inMilliseconds / duration!.inMilliseconds).clamp(0.0, 1.0);
    }
    final playbackX = size.width * progress;

    // Colors - uchinchi rasmdagiday
    final playedColor = const Color(0xFFF2EFEA); // O'qilgan qism rangi
    final unplayedColor = const Color(0x4DF2EFEA); // O'qilmagan qism rangi (alpha 4D = 77/255 ≈ 0.3)

    // Start point indicator olib tashlandi

    // Draw symmetrical vertical bars based on actual audio amplitude
    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * barWidth;
      final baseAmplitude = amplitudes[i];
      
      // Use actual audio amplitude directly (no animation, just real audio dynamics)
      // Ensure minimum height for visibility, max 90% of container height
      // Chiziqchalar balandligini 2x ga kattalashtirish
      final maxBarHeight = size.height * 0.9;
      final minBarHeight = 2.0;
      final barHeight = math.max(minBarHeight, baseAmplitude * maxBarHeight * 3.0).clamp(minBarHeight, maxBarHeight);
      
      // Determine if this bar is played or unplayed
      final barCenterX = x + barWidth / 2;
      final isPlayed = barCenterX <= playbackX;
      
      // Choose color based on playback position
      final barColor = isPlayed ? playedColor : unplayedColor;
      
      // Draw symmetrical vertical bar (extends equally above and below center)
      final paint = Paint()
        ..color = barColor
        ..style = PaintingStyle.fill;
      
      // Symmetrical bar - half height above, half below center
      final halfHeight = barHeight / 2;
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          barCenterX - actualBarWidth / 2,
          centerY - halfHeight,
          actualBarWidth,
          barHeight,
        ),
        Radius.circular(actualBarWidth / 2), // Fully rounded ends
      );
      
      canvas.drawRRect(barRect, paint);
      
      // Playback head (uzun tayoqcha) olib tashlandi
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes ||
        oldDelegate.duration != duration ||
        oldDelegate.position != position;
  }
}
