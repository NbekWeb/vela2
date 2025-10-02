import 'package:flutter/material.dart';
import 'package:vela/shared/widgets/stars_animation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/stores/auth_store.dart';

class ZeroGenerator extends StatefulWidget {
  final VoidCallback? onNext;
  const ZeroGenerator({super.key, this.onNext});

  @override
  State<ZeroGenerator> createState() => _ZeroGeneratorState();
}

class _ZeroGeneratorState extends State<ZeroGenerator> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authStore = Provider.of<AuthStore>(context, listen: false);

    // Clear access token from secure storage
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');

    // Reset saved tab index to 0
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_tab_index', 0);

    // Call authStore logout to clear all auth data
    await authStore.logout();

    if (context.mounted) {
      // Clear all routes and navigate to login
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  //  void initState() {
  //   super.initState();
  //  if (widget.onNext != null) {
  //     Future.delayed(const Duration(seconds: 3), () {
  //       if (mounted) widget.onNext!();
  //     });
  //   }
  //  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const StarsAnimation(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Take a quiet moment to connect with yourself',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Canela',
                      fontWeight: FontWeight.w300,
                      fontSize: 36.sp,
                      height: 1.15,
                      letterSpacing: -0.5,
                      color: Color(0xFFF2EFEA),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'These questions activate the parts of your brain responsible for vision, clarity, and motivation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      letterSpacing: -0.1,
                      height: 1.5,
                      color: Color(0xFFF2EFEA),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    "You're about to build a blueprint for your dream life.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      letterSpacing: -0.1,
                      height: 1.5,
                      color: Color(0xFFF2EFEA),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width * 0.9,

                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.disabled)) {
                          return const Color(0xFF3B6EAA).withOpacity(0.5);
                        }
                        return const Color(0xFF3B6EAA);
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.white.withOpacity(0.7);
                        }
                        return Colors.white;
                      }),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    onPressed: () {
                      widget.onNext!();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF2EFEA),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Logout button at the very bottom
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _handleLogout(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color.fromRGBO(59, 110, 170, .2),
                  ),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
