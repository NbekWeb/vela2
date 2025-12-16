import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/widgets/stars_animation.dart';
import '../shared/widgets/full_width_track_shape.dart';
import '../core/stores/check_in_store.dart';
import '../core/stores/auth_store.dart';
import '../core/stores/meditation_store.dart';
import 'dashboard/main.dart';
import 'meditation_streaming_page.dart';

class DailyCheckInPage extends StatelessWidget {
  const DailyCheckInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const StarsAnimation(starCount: 50),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _CheckInAppBar(),
                SizedBox(height: 16),
                _CheckInForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInAppBar extends StatelessWidget {
  const _CheckInAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // растягивает на всю ширину
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Transform.translate(
                offset: const Offset(-10, 0), // -10 по оси X — сдвиг влево
                child: Image.asset(
                  'assets/img/logo.png',
                  height: 32,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.info_outline, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Daily Check-In',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Canela',
              fontSize: 36,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect with your inner journey today' ,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInForm extends StatefulWidget {
  const _CheckInForm();

  @override
  State<_CheckInForm> createState() => _CheckInFormState();
}

class _CheckInFormState extends State<_CheckInForm> {
  double _sliderValue = 0.5; // Default neutral position
  final TextEditingController _descriptionController = TextEditingController();
  bool _isGenerateButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Text controller'ga listener qo'shish - text o'zgarganda setState qilish
    _descriptionController.addListener(() {
      final hasText = _descriptionController.text.trim().isNotEmpty;
      print('🔄 [Check-In] Text changed: "${_descriptionController.text}", hasText: $hasText, current enabled: $_isGenerateButtonEnabled');
      if (hasText != _isGenerateButtonEnabled) {
        print('✅ [Check-In] Updating button state: $_isGenerateButtonEnabled -> $hasText');
        setState(() {
          _isGenerateButtonEnabled = hasText;
        });
      }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Klaviatura yopish uchun focus ni olib tashlash
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Satoshi',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedDate(),
                      style: const TextStyle(
                        color: Color(0xFFF2EFEA),
                        fontSize: 14,
                        fontFamily: 'Satoshi',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dynamic mood image
                    Image.asset(
                      _getMoodImage(_sliderValue),
                      width: 66,
                      height: 66,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getMoodText(_sliderValue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7.5,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 20,
                          ),
                          trackShape: const FullWidthTrackShape(),
                        ),
                        child: Slider(
                          value: _sliderValue,
                          onChanged: (v) {
                            setState(() {
                              _sliderValue = v;
                            });
                          },
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
                    const SizedBox(height: 36),
                    const Text(
                      'How can Vela support you in this exact moment?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Satoshi',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: TextFormField(
                        controller: _descriptionController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Satoshi',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'I\'m overwhelmed about my test — I need help calming down.',
                          hintStyle: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
                    const SizedBox(height: 32),
                    _CheckInButtons(
                      descriptionController: _descriptionController,
                      sliderValue: _sliderValue,
                      isGenerateButtonEnabled: _isGenerateButtonEnabled,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

class _CheckInButtons extends StatelessWidget {
  final TextEditingController descriptionController;
  final double sliderValue;
  final bool isGenerateButtonEnabled;

  const _CheckInButtons({
    required this.descriptionController,
    required this.sliderValue,
    required this.isGenerateButtonEnabled,
  });

  void _handleCheckIn(BuildContext context, CheckInStore checkInStore) {
    final checkInChoice = _getCheckInChoice(sliderValue);
    final description = descriptionController.text.trim();

    // if (description.isEmpty) {
    //   Fluttertoast.showToast(
    //     msg: 'Please enter a description',
    //     toastLength: Toast.LENGTH_LONG,
    //     gravity: ToastGravity.TOP,
    //     backgroundColor: const Color(0xFFF2EFEA),
    //     textColor: const Color(0xFF3B6EAA),
    //   );
    //   return;
    // }

    final authStore = Provider.of<AuthStore>(context, listen: false);

    checkInStore.submitCheckIn(
      checkInChoice: checkInChoice,
      description: description,
      authStore: authStore,
      onSuccess: () {
        // localStorage'dan initial ma'lumotlarni tozalash
        _clearInitialSettings(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardMainPage()),
        );
      },
    );
  }

  // localStorage'dan initial ma'lumotlarni tozalash
  Future<void> _clearInitialSettings(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('initial_ritual_type');
      await prefs.remove('initial_voice');
      await prefs.remove('initial_duration');
      print('✅ [Check-In] Cleared initial settings from localStorage');
    } catch (e) {
      print('⚠️ [Check-In] Error clearing initial settings: $e');
    }
  }

  // Generate New Meditation tugmasi bosilganda
  Future<void> _handleGenerateNewMeditation(BuildContext context, CheckInStore checkInStore) async {
    final checkInChoice = _getCheckInChoice(sliderValue);
    final description = descriptionController.text.trim();

    if (description.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter a description',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFFF2EFEA),
        textColor: const Color(0xFF3B6EAA),
      );
      return;
    }

    // Check-in POST API
    final authStore = Provider.of<AuthStore>(context, listen: false);
    
    try {
      // Check-in yuborish
      await checkInStore.submitCheckIn(
        checkInChoice: checkInChoice,
        description: description,
        authStore: authStore,
        onSuccess: () {
          print('✅ [Generate New Meditation] Check-in submitted successfully');
        },
      );

      // localStorage'dan initial ma'lumotlarni olish
      final prefs = await SharedPreferences.getInstance();
      final initialRitualType = prefs.getString('initial_ritual_type') ?? '1';
      final initialVoice = prefs.getString('initial_voice') ?? 'female';
      final initialDuration = prefs.getString('initial_duration') ?? '2';

      print('🔄 [Generate New Meditation] Using initial settings:');
      print('   - ritualType: $initialRitualType');
      print('   - voice: $initialVoice');
      print('   - duration: $initialDuration');

      // MeditationStore'ga saqlash
      final meditationStore = Provider.of<MeditationStore>(context, listen: false);
      await meditationStore.saveRitualSettings(
        ritualType: initialRitualType,
        tone: 'dreamy', // Default tone
        duration: initialDuration,
        planType: int.tryParse(initialRitualType) ?? 1,
        voice: initialVoice,
      );

      // localStorage'dan tozalash
      await _clearInitialSettings(context);

      // MeditationStreamingPage ga o'tish
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MeditationStreamingPage(),
        ),
      );
    } catch (e) {
      print('❌ [Generate New Meditation] Error: $e');
      Fluttertoast.showToast(
        msg: 'Error generating meditation. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  String _getCheckInChoice(double value) {
    if (value <= 0.20) {
      return 'struggling';
    } else if (value <= 0.80) {
      return 'neutral';
    } else {
      return 'excellent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckInStore>(
      builder: (context, checkInStore, child) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: checkInStore.isLoading
                    ? null
                    : () {
                        _handleCheckIn(context, checkInStore);
                      },
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
                        'Complete Check-In ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: (isGenerateButtonEnabled && !checkInStore.isLoading)
                    ? () {
                        _handleGenerateNewMeditation(context, checkInStore);
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  backgroundColor: isGenerateButtonEnabled
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Generate New Meditation ',
                      style: TextStyle(
                        color: isGenerateButtonEnabled
                            ? const Color(0xFF3B6EAA)
                            : const Color(0xFF3B6EAA).withOpacity(0.5),
                        fontSize: 16,
                        fontFamily: 'Satoshi',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.auto_awesome,
                      color: isGenerateButtonEnabled
                          ? const Color(0xFF3B6EAA)
                          : const Color(0xFF3B6EAA).withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
