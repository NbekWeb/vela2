import 'package:flutter/material.dart';

/// Audio playback controls (Play/Pause/Resume/Stop)
class AudioControls extends StatelessWidget {
  final bool isPlaying;
  final bool isPaused;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onStop;

  const AudioControls({
    super.key,
    required this.isPlaying,
    required this.isPaused,
    this.onPlay,
    this.onPause,
    this.onResume,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isPlaying && !isPaused)
          ElevatedButton.icon(
            onPressed: onPlay,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.purple,
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text("Play"),
          )
        else if (isPaused)
          ElevatedButton.icon(
            onPressed: onResume,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.purple,
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text("Resume"),
          )
        else
          ElevatedButton.icon(
            onPressed: onPause,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.orange,
            ),
            icon: const Icon(Icons.pause),
            label: const Text("Pause"),
          ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onStop,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(120, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.stop),
          label: const Text("Stop"),
        ),
      ],
    );
  }
}
