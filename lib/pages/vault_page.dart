import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:provider/provider.dart';
import '../shared/widgets/stars_animation.dart';
import '../shared/widgets/personalized_meditation_modal.dart';
import '../core/stores/meditation_store.dart';
import 'sleep_stream_meditation_page.dart';
import 'vault/vault_buttons.dart';
import 'vault/vault_ritual_card.dart';
import 'vault/vault_stat_card.dart';
import 'check_in_page.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
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
      meditationStore
          .fetchMeditationLibrary(); // Changed from restoreMeditation to fetchMeditationLibrary
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SleepStreamMeditationPage(
                                          isDirectRitual: false,
                                        ),
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/img/logo.png',
                                height: 32,
                                color: Colors.white,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (BuildContext context) {
                                      return const PersonalizedMeditationModal();
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your Dream Vault',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Canela',
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Your personal vault of meditations — made for you and ready anytime.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                      value: meditationCount.toString().padLeft(
                                        2,
                                        '0',
                                      ),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer<MeditationStore>(
                            builder: (context, meditationStore, child) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/my-meditations');
                                    },
                                    child: Text(
                                      'My Meditations (${meditationStore.myMeditations?.length ?? 0})',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Canela',
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/my-meditations');
                                    },
                                    child: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Consumer<MeditationStore>(
                          builder: (context, meditationStore, child) {
                            final myMeditations = meditationStore.myMeditations;

                            // Show loader while data is being fetched
                            if (myMeditations == null) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }

                            if (myMeditations.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            final meditationCount = myMeditations.length;

                            if (meditationCount == 1) {
                              final meditation = myMeditations.first;
                              final details = meditation['details'];
                              final name = details?['name'] ?? 'Sleep Stream';
                              final meditationId = meditation['id']?.toString();
                              final file = details?['file']?.toString();

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: VaultRitualCard(
                                  name: name,
                                  meditationId: meditationId,
                                  file: file,
                                ),
                              );
                            } else {
                              return SizedBox(
                                height: 100,
                                child: Swiper(
                                  itemCount: meditationCount,
                                  loop: false,
                                  itemBuilder: (context, index) {
                                    final meditation = myMeditations[index];
                                    final details = meditation['details'];
                                    final name =
                                        details?['name'] ?? 'Sleep Stream';
                                    final meditationId = meditation['id']
                                        ?.toString();
                                    final file = details?['file']?.toString();

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: VaultRitualCard(
                                        name: name,
                                        meditationId: meditationId,
                                        file: file,
                                      ),
                                    );
                                  },
                                  viewportFraction: 1,
                                  scale: 1,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer<MeditationStore>(
                            builder: (context, meditationStore, child) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/archive');
                                    },
                                    child: Text(
                                      'Meditation Library (${meditationStore.libraryDatas?.length ?? 0})',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w300,
                                        fontFamily: 'Canela',
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed('/archive');
                                    },
                                    child: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Consumer<MeditationStore>(
                          builder: (context, meditationStore, child) {
                            final libraryDatas = meditationStore.libraryDatas;

                            // Show loader while data is being fetched
                            if (libraryDatas == null) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }

                            final libraryCount = libraryDatas.length;

                            if (libraryCount == 1) {
                              final meditation = libraryDatas.first;
                              final name =
                                  meditation['name'] ?? 'Archive Meditation';
                              final meditationId = meditation['id']?.toString();
                              final file = meditation['file']?.toString();
                              final title = meditation['name']?.toString();
                              final description = meditation['description']
                                  ?.toString();
                              final imageUrl = meditation['image']?.toString();

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: VaultRitualCard(
                                  name: name,
                                  meditationId: meditationId,
                                  file: file,
                                  title: title,
                                  description: description,
                                  imageUrl: imageUrl,
                                ),
                              );
                            } else {
                              return SizedBox(
                                height: 100,
                                child: Swiper(
                                  itemCount: libraryCount,
                                  loop: false,
                                  itemBuilder: (context, index) {
                                    final meditation = libraryDatas[index];
                                    final name =
                                        meditation['name'] ??
                                        'Archive Meditation';
                                    final meditationId = meditation['id']
                                        ?.toString();
                                    final file = meditation['file']?.toString();
                                    final title = meditation['name']
                                        ?.toString();
                                    final description =
                                        meditation['description']?.toString();
                                    final imageUrl = meditation['image']
                                        ?.toString();

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: VaultRitualCard(
                                        name: name,
                                        meditationId: meditationId,
                                        file: file,
                                        title: title,
                                        description: description,
                                        imageUrl: imageUrl,
                                      ),
                                    );
                                  },
                                  viewportFraction: 1,
                                  scale: 1,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: VaultButtons(
                    onContinue: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DailyCheckInPage(),
                        ),
                      );
                    },
                    onHome: () {
                      Navigator.of(context).pushReplacementNamed('/dashboard');
                    },
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
