import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/stars_animation.dart';
import '../../shared/widgets/info_dashboard_modal.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../vault/vault_ritual_card.dart';
import '../vault/vault_stat_card.dart';
import '../dashboard/components/dashboard_audio_player.dart';
import '../../core/stores/meditation_store.dart';
import 'main.dart';

class DashboardVaultPage extends StatefulWidget {
  final Function(String)? onAudioPlay;
  final VoidCallback? onBackPressed;

  const DashboardVaultPage({this.onAudioPlay, this.onBackPressed, super.key});

  @override
  State<DashboardVaultPage> createState() => _DashboardVaultPageState();
}

class _DashboardVaultPageState extends State<DashboardVaultPage> {
  @override
  void initState() {
    super.initState();
    // Fetch meditations when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final meditationStore = Provider.of<MeditationStore>(
        context,
        listen: false,
      );
      meditationStore.fetchMyMeditations();
      meditationStore.fetchMeditationLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const StarsAnimation(starCount: 50),
          SafeArea(
            child: Column(
              children: [
                // Fixed header
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.sp, // left
                    8, // top
                    16.sp, // right
                    0.sp, // bottom
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back arrow in a circle, size 24x24
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Center(
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {
                              if (widget.onBackPressed != null) {
                                widget.onBackPressed!();
                              } else {
                                // Check if there's a previous page to go back to
                                final dashboardState = context
                                    .findAncestorStateOfType<
                                      DashboardMainPageState
                                    >();
                                if (dashboardState != null) {
                                  // If previous index is the same as current (no previous page), go to home
                                  if (dashboardState.previousIndex ==
                                      dashboardState.selectedIndex) {
                                    dashboardState.navigateToHome();
                                  } else {
                                    // Go back to previous page
                                    dashboardState.navigateBack();
                                  }
                                } else {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/dashboard');
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(3, 0),
                        child: Image.asset(
                          'assets/img/logo.png',
                          width: 60,
                          height: 39,
                        ),
                      ),
                      // Info icon on the right, size 24x24
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return const InfoDashboardModal();
                            },
                          );
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ), // Add bottom padding for navbar
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Center all children horizontally
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Your Dream Vault',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Canela',
                              fontSize: 36.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your personal vault of meditations — made for you and ready anytime.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFDCE6F0),
                              fontFamily: 'Satoshi',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Consumer<MeditationStore>(
                              builder: (context, meditationStore, child) {
                                final myMeditations =
                                    meditationStore.myMeditations;
                                final meditationCount =
                                    myMeditations?.length ?? 0;

                                // Calculate total duration from all meditations
                                int totalDuration = 0;
                                if (myMeditations != null) {
                                  for (final meditation in myMeditations) {
                                    final details = meditation['details'];
                                    if (details != null &&
                                        details['duration'] != null) {
                                      final duration =
                                          int.tryParse(
                                            details['duration'].toString(),
                                          ) ??
                                          0;
                                      totalDuration += duration;
                                    }
                                  }
                                }

                                return Row(
                                  children: [
                                    Expanded(
                                      child: VaultStatCard(
                                        value: meditationCount
                                            .toString()
                                            .padLeft(2, '0'),
                                        label: 'Meditations\nCreated',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: VaultStatCard(
                                        value: totalDuration.toString(),
                                        unit: '',
                                        label: 'Total\ntime (min)',
                                        unitBelow: true,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          Consumer<MeditationStore>(
                            builder: (context, meditationStore, child) {
                              final myMeditations =
                                  meditationStore.myMeditations;
                              final meditationCount =
                                  myMeditations?.length ?? 0;

                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/my-meditations',
                                          );
                                        },
                                        child: Text(
                                          'My Meditations ($meditationCount)',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 36.sp,
                                            letterSpacing: -0.5,
                                            fontWeight: FontWeight.w300,
                                            fontFamily: 'Canela',
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/my-meditations',
                                          );
                                        },
                                        child: const Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (myMeditations != null &&
                                      myMeditations.isNotEmpty) ...[
                                    SizedBox(
                                      height: 100,
                                      child: Swiper(
                                        itemCount: meditationCount,
                                        loop: false,
                                        itemBuilder: (context, index) {
                                          final meditation =
                                              myMeditations[index];
                                          final details = meditation['details'];
                                          final name =
                                              details?['name'] ??
                                              'Sleep Stream';
                                          final meditationId = meditation['id']
                                              ?.toString();

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                            ),
                                            child: VaultRitualCard(
                                              name: name,
                                              meditationId: meditationId,
                                              onAudioPlay: widget.onAudioPlay,
                                            ),
                                          );
                                        },
                                        viewportFraction: 1,
                                        scale: 1,
                                      ),
                                    ),
                                  ] else ...[
                                    VaultRitualCard(
                                      isEmpty: true,
                                      emptyText: 'No meditations created',
                                      onAudioPlay: widget.onAudioPlay,
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Consumer<MeditationStore>(
                            builder: (context, meditationStore, child) {
                              final libraryDatas = meditationStore.libraryDatas;
                              final libraryCount = libraryDatas?.length ?? 0;

                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/archive',
                                          );
                                        },
                                        child: Text(
                                          'Meditation Library ($libraryCount)',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 36.sp,
                                            letterSpacing: -0.5,
                                            fontWeight: FontWeight.w300,
                                            fontFamily: 'Canela',
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/archive',
                                          );
                                        },
                                        child: const Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (libraryDatas != null &&
                                      libraryDatas.isNotEmpty) ...[
                                    SizedBox(
                                      height: 100,
                                      child: Swiper(
                                        itemCount: libraryCount,
                                        loop: false,
                                        itemBuilder: (context, index) {
                                          final meditation =
                                              libraryDatas[index];
                                          final name =
                                              meditation['name'] ??
                                              'Library Meditation';
                                          final meditationId = meditation['id']
                                              ?.toString();
                                          final file = meditation['file']
                                              ?.toString();
                                          final title = meditation['name']
                                              ?.toString();
                                          final description =
                                              meditation['description']
                                                  ?.toString();
                                          final imageUrl = meditation['image']
                                              ?.toString();

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                            ),
                                            child: VaultRitualCard(
                                              name: name,
                                              meditationId: meditationId,
                                              file: file,
                                              title: title,
                                              description: description,
                                              imageUrl: imageUrl,
                                              onAudioPlay: (id) {
                                                // Navigate to audio player with proper parameters like in home page
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DashboardAudioPlayer(
                                                          meditationId: id,
                                                          title: title,
                                                          description:
                                                              description,
                                                          imageUrl: imageUrl,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        viewportFraction: 1,
                                        scale: 1,
                                      ),
                                    ),
                                  ] else ...[
                                    VaultRitualCard(
                                      isEmpty: true,
                                      emptyText: 'Archive is empty',
                                      onAudioPlay: widget.onAudioPlay,
                                      showButton: false,
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
