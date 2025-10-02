import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/widgets/full_width_track_shape.dart';
import '../../../core/stores/check_in_store.dart';
import '../../generator/direct_ritual_page.dart';

class CheckInFormWidget extends StatefulWidget {
  final double sliderValue;
  final ValueChanged<double> onSliderChanged;
  final TextEditingController descriptionController;
  final VoidCallback onCheckIn;

  const CheckInFormWidget({
    super.key,
    required this.sliderValue,
    required this.onSliderChanged,
    required this.descriptionController,
    required this.onCheckIn,
  });

  @override
  State<CheckInFormWidget> createState() => _CheckInFormWidgetState();
}

class _CheckInFormWidgetState extends State<CheckInFormWidget> {
  String _getMoodText(double value) {
    if (value <= 0.20) {
      return 'Bad';
    } else if (value <= 0.40) {
      return 'Not Great';
    } else if (value <= 0.60) {
      return 'Neutral';
    } else if (value <= 0.80) {
      return 'Good';
    } else {
      return 'Excellent';
    }
  }

  String _getMoodImage(double value) {
    if (value <= 0.20) {
      return 'assets/img/struggling.png'; // Bad
    } else if (value <= 0.40) {
      return 'assets/img/notgreat.png'; // Not Great
    } else if (value <= 0.60) {
      return 'assets/img/planet.png'; // Neutral
    } else if (value <= 0.80) {
      return 'assets/img/good.png'; // Good
    } else {
      return 'assets/img/excellent.png'; // Excellent
    }
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Returns a string in the format 'Weekday, MM/DD/YYYY'.
  ///
  /// Example: 'Wednesday, 07/28/2021'
  ///
  /// This function is used to format the current date.
  /*******  3375ecac-11cc-4e5f-b5d8-959f78918899  *******/
  static String _formattedDate() {
    final now = DateTime.now();
    return '${_weekday(now.weekday)}, ${now.month}/${now.day}/${now.year}';
  }

  static String _weekday(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Check-in form
        const Text(
          'How are you feeling today?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formattedDate(),
          style: const TextStyle(
            color: Color(0xFFDCE6F0),
            fontSize: 14,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Dynamic mood image
        Image.asset(_getMoodImage(widget.sliderValue), width: 48, height: 48),
        const SizedBox(height: 8),
        Text(
          _getMoodText(widget.sliderValue),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Satoshi',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Slider
        SizedBox(
          width: double.infinity,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: Color(0xFFC9DFF4),
              inactiveTrackColor: Color(0xFFC9DFF4),
              thumbColor: Color(0xFF3B6EAA),
              overlayColor: Colors.white24,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              trackShape: const FullWidthTrackShape(),
            ),
            child: Slider(
              value: widget.sliderValue,
              onChanged: widget.onSliderChanged,
              min: 0,
              max: 1,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Bad',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Satoshi',
                fontSize: 12,
              ),
            ),
            Text(
              'Not Great',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Satoshi',
                fontSize: 12,
              ),
            ),
            Text(
              'Neutral',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Satoshi',
                fontSize: 12,
              ),
            ),
            Text(
              'Good',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Satoshi',
                fontSize: 12,
              ),
            ),
            Text(
              'Excellent',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Satoshi',
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'How can Vela support you in this exact moment?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontFamily: 'Satoshi',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 100,
          child: TextFormField(
            controller: widget.descriptionController,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontFamily: 'Satoshi',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'I\'m overwhelmed about my test — I need help calming down.',
              hintStyle: TextStyle(color: Colors.white70, fontSize: 12.sp),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Color.fromRGBO(21, 43, 86, 0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Color.fromRGBO(21, 43, 86, 0.3),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              fillColor: Color.fromRGBO(21, 43, 86, 0.1),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Complete Check-In Button
        Consumer<CheckInStore>(
          builder: (context, checkInStore, child) {
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: checkInStore.isLoading ? null : widget.onCheckIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B6EAA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: checkInStore.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Complete Check-In',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Satoshi',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Generate New Meditation Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const DirectRitualPage(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Generate New Meditation',
                  style: TextStyle(
                    color: Color(0xFF3B6EAA),
                    fontSize: 16,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.auto_awesome, color: Color(0xFF3B6EAA)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
