import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart' show globalMeditationId, shouldNavigateToProfile;
import '../../core/services/app_lifecycle_service.dart';
import 'home.dart';
import 'vault.dart';
import 'check_in.dart';
import 'profile.dart';
import 'settings_page.dart';
import 'components/home_icon.dart';
import 'components/vault_icon.dart';
import '../../shared/widgets/svg_icon.dart';
import 'components/check_icon.dart';
import 'components/profile_icon.dart';
import 'components/dashboard_audio_player.dart';
import '../generator/direct_ritual_page.dart';

class DashboardMainPage extends StatefulWidget {
  const DashboardMainPage({super.key});

  @override
  State<DashboardMainPage> createState() => DashboardMainPageState();
}

class DashboardMainPageState extends State<DashboardMainPage> {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  String? _currentAudioId;
  static const String _selectedTabKey = 'selected_tab_index';
  static const String _previousTabKey = 'previous_tab_index';

  void navigateToSettings() {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = 4;
    });
    _saveSelectedIndex();
  }

  void navigateToProfile() {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = 3;
    });
    _saveSelectedIndex();
  }

  void navigateToEditInfo() {
    Navigator.pushNamed(context, '/edit-info');
  }

  void navigateToReminders() {
    Navigator.pushNamed(context, '/reminders');
  }

  void navigateBack() {
    setState(() {
      _selectedIndex = _previousIndex;
    });
    _saveSelectedIndex();
  }

  void navigateToHome() {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = 0; // Home page index
    });
    _saveSelectedIndex();
  }

  // Public getters to access private fields
  int get previousIndex => _previousIndex;
  int get selectedIndex => _selectedIndex;

  Future<void> _saveSelectedIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_selectedTabKey, _selectedIndex);
      await prefs.setInt(_previousTabKey, _previousIndex);
    } catch (e) {
      // Error saving selected index
    }
  }

  Future<void> _loadSelectedIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt(_selectedTabKey);
      final savedPreviousIndex = prefs.getInt(_previousTabKey);

      if (savedIndex != null && savedIndex >= 0 && savedIndex < _pages.length) {
        setState(() {
          _selectedIndex = savedIndex;
          _previousIndex = savedPreviousIndex ?? 0;
        });
      } else {
        // Set default to 0 if savedIndex is invalid
        setState(() {
          _selectedIndex = 0;
          _previousIndex = 0;
        });
        await _saveSelectedIndex();
      }
    } catch (e) {
      // Error loading selected index, set default to 0
      setState(() {
        _selectedIndex = 0;
        _previousIndex = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Check if should navigate to profile first
    if (shouldNavigateToProfile) {
      print(
        'Dashboard: shouldNavigateToProfile is true, navigating to profile',
      );
      setState(() {
        _selectedIndex = 3; // Profile index
        _previousIndex = 0;
      });
      shouldNavigateToProfile = false; // Clear the global variable
      _saveSelectedIndex();
    } else {
      // Load saved selected index only if not navigating to profile
      _loadSelectedIndex();
    }
    
    // Update last active time for uninstall detection
    AppLifecycleService().updateLastActiveTime();

    // Check if there's a global meditation ID to play
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalMeditationId != null) {
        showAudioPlayer(globalMeditationId!);
        globalMeditationId = null; // Clear the global variable
      }
    });
  }

  List<Widget> get _pages => [
    DashboardHomePage(),
    DashboardVaultPage(
      onAudioPlay: (meditationId) {
        setState(() {
          _currentAudioId = meditationId;
          _selectedIndex = 5; // Audio player is now at index 5
        });
      },
    ),
    DashboardCheckInPage(),
    DashboardProfilePage(),
    SettingsPage(),
    if (_currentAudioId != null)
      DashboardAudioPlayer(meditationId: _currentAudioId!),
  ];

  void showAudioPlayer(String meditationId) {
    setState(() {
      _previousIndex = _selectedIndex;
      _currentAudioId = meditationId;
      _selectedIndex = 5; // Audio player is now at index 5
    });
    _saveSelectedIndex();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back button behavior
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Handle back button press
          if (_selectedIndex == 0) {
            // If on home page, show exit confirmation or minimize app
            _showExitConfirmation(context);
          } else {
            // Navigate back to home page
            navigateToHome();
          }
        }
      },
      child: Stack(
        children: [
          Container(color: Color(0xFFA4C6EB)),

          Scaffold(
            body: _pages[_selectedIndex],
            backgroundColor: _selectedIndex == 0
                ? Color(0xFF5799D6)
                : Colors
                      .transparent, // Home page uchun rang, boshqalari uchun transparent
            bottomNavigationBar: _selectedIndex == 7
                ? null
                : Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    padding:
                        !kIsWeb &&
                            (Theme.of(context).platform == TargetPlatform.iOS)
                        ? EdgeInsets.only(
                            top: 10,
                            bottom:
                                5 + MediaQuery.of(context).viewPadding.bottom,
                            left: 8,
                            right: 8,
                          )
                        : const EdgeInsets.only(
                            top: 10,
                            bottom: 20,
                            left: 10,
                            right: 10,
                          ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32.r),
                        topRight: Radius.circular(32.r),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _NavItem(
                          icon: HomeIcon(
                            filled: _selectedIndex == 0,
                            opacity: _selectedIndex == 0 ? 1.0 : 0.5,
                          ),
                          label: 'Home',
                          selected: _selectedIndex == 0,
                          onTap: () {
                            setState(() {
                              _previousIndex = _selectedIndex;
                              _selectedIndex = 0;
                            });
                            _saveSelectedIndex();
                          },
                        ),
                        _NavItem(
                          icon: VaultIcon(
                            filled: _selectedIndex == 1,
                            opacity: _selectedIndex == 1 ? 1.0 : 0.5,
                          ),
                          label: 'Vault',
                          selected: _selectedIndex == 1,
                          onTap: () {
                            setState(() {
                              _previousIndex = _selectedIndex;
                              _selectedIndex = 1;
                            });
                            _saveSelectedIndex();
                          },
                        ),
                        // Center star button
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                          ), // ← 20px слева и справа
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DirectRitualPage(),
                                ),
                              );
                            },
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromRGBO(60, 110, 171, 1),
                                    Color.fromRGBO(164, 198, 235, 1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: SvgIcon(
                                  assetName: 'assets/menu/star.svg',
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        _NavItem(
                          icon: CheckIcon(
                            filled: _selectedIndex == 2,
                            opacity: _selectedIndex == 2 ? 1.0 : 0.5,
                          ),
                          label: 'Check-in',
                          selected: _selectedIndex == 2,
                          onTap: () {
                            setState(() {
                              _previousIndex = _selectedIndex;
                              _selectedIndex = 2;
                            });
                            _saveSelectedIndex();
                          },
                        ),
                        _NavItem(
                          icon: ProfileIcon(
                            filled: _selectedIndex == 3 || _selectedIndex == 4,
                            opacity:
                                (_selectedIndex == 3 || _selectedIndex == 4)
                                ? 1.0
                                : 0.5,
                          ),
                          label: 'Profile',
                          selected: _selectedIndex == 3 || _selectedIndex == 4,
                          onTap: () {
                            setState(() {
                              _previousIndex = _selectedIndex;
                              _selectedIndex = 3;
                            });
                            _saveSelectedIndex();
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Exit the app
                SystemNavigator.pop();
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
      ), // ← Расширяем зону нажатия
      child: GestureDetector(
        behavior: HitTestBehavior
            .translucent, // ← Улавливает касания даже в прозрачных зонах
        onTap: onTap,
        child: Container(
          width:
              60, // Можно оставить, это визуальный размер, не влияет на зону касания
          margin: const EdgeInsets.only(top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.sp,
                  letterSpacing: -0.1.sp,
                  color: selected
                      ? const Color(0xFF3B6EAA)
                      : const Color(0xFF3B6EAA).withAlpha(128), // 0.5 opacity
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
