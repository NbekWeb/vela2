import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/stars_animation.dart';
import '../../core/stores/auth_store.dart';
import 'components/profile_header.dart';
import 'components/profile_picture_section.dart';
import 'components/profile_content_sections.dart';
import 'components/neuroplasticity_button.dart';

class DashboardProfilePage extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const DashboardProfilePage({this.onBackPressed, super.key});

  @override
  State<DashboardProfilePage> createState() => _DashboardProfilePageState();
}

class _DashboardProfilePageState extends State<DashboardProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load user details when profile page mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      authStore.getUserDetails();
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final authStore = Provider.of<AuthStore>(context, listen: false);
    await authStore.getProfileDataWithLifeVisions();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStore>(
      builder: (context, authStore, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: Scaffold(
            body: Stack(
              children: [
                // Star animation background
                const StarsAnimation(
                  starCount: 20,
                  topColor: const Color(0xFF3C6EAB),
                  bottomColor: const Color(0xFFA4C6EB),
                ),

                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16.sp, // left
                      8.sp, // top
                      16.sp, // right
                      0.sp, // bottom
                    ),
                    child: Column(
                      children: [
                        // Header
                        ProfileHeader(onBackPressed: widget.onBackPressed),

                        const SizedBox(height: 30),

                        // Profile picture and name
                        const ProfilePictureSection(),

                        const SizedBox(height: 40),

                        // User details section

                        // Content sections
                        const ProfileContentSections(),

                        const SizedBox(height: 30),

                        // Neuroplasticity - always visible
                        const NeuroplasticityCard(),

                        const SizedBox(
                          height: 25,
                        ), // Space for bottom navigation
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
