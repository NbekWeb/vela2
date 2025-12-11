import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/widgets/video_background_wrapper.dart';
import '../../styles/components/button_styles.dart';
import '../../styles/components/text_styles.dart';
import '../../styles/components/spacing_styles.dart';

class OnboardingPage4 extends StatefulWidget {
  const OnboardingPage4({super.key});

  @override
  State<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<OnboardingPage4> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackgroundWrapper(
      topOffset: 0,
      showControls: true,
      isMuted: false,
      showBackButton: true,
      onBack: () => Navigator.pop(context),
      child: Column(
        children: [
          // Main content
          Expanded(child: Container()),

          // Bottom content container
          Container(
            padding: SpacingStyles.paddingHorizontal,
            child: Column(
              children: [
                Text(
                  'Set sail to your dream life, with Vela',
                  textAlign: TextAlign.center,
                  style: TextStyles.headingLarge.copyWith(fontSize: 46.sp),
                ),

                const SizedBox(height: 30),

                Text(
                  'Vela is designed to rewire your inner world — and reshape your outer one. Your vision, on repeat. Your dream life, in motion.',
                  textAlign: TextAlign.center,
                  style: TextStyles.bodyLarge,
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ButtonStyles.primary,
                  child: Text('Get Started', style: ButtonStyles.primaryText),
                ),

                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFFF2EFEA),
                          fontFamily: 'Satoshi',
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontFamily: 'Satoshi',
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
