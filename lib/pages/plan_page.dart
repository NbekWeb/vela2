import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../styles/pages/plan_page_styles.dart';
import 'components/plan_switch.dart';
import 'components/plan_info_card.dart';
import '../shared/widgets/auth.dart';
import '../shared/widgets/exit_confirmation_dialog.dart';
import '../core/stores/auth_store.dart';
import '../core/services/superwall_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum PlanStep { choosePlan, dreamLifeIntro }

enum PlanType { annual, monthly }

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  PlanStep _currentStep = PlanStep.choosePlan;
  PlanType _selectedPlan = PlanType.annual;

  void _goToNextStep() {
    setState(() {
      _currentStep = PlanStep.dreamLifeIntro;
    });
  }

  void _showExitDialog() {
    ExitConfirmationDialog.show(
      context,
      title: 'Exit Plan Selection?',
      message: 'Are you sure you want to exit? You can always come back to select your plan later.',
    );
  }

  @override
  Widget build(BuildContext context) {
    String title;
    Widget? subtitle;
    Widget child;
    VoidCallback? onBack;

    switch (_currentStep) {
      case PlanStep.choosePlan:
        title = 'Choose your plan';
        subtitle = Column(
          children: [
            Text(
              _selectedPlan == PlanType.annual
                  ? 'First 3 days free, then \$49/year (\$4.08/month)'
                  : 'First 3 days free, then \$9.99/month (\$120/year)',
              style: PlanPageStyles.priceSub,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: PlanSwitch(
                  selected: _selectedPlan,
                  onChanged: (plan) => setState(() => _selectedPlan = plan),
                ),
              ),
            ),
          ],
        );
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            PlanInfoCard(),
            const SizedBox(height: 20),
            // Timeline, matnlar, stepper va h.k.
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedPlan == PlanType.annual
                        ? '\$49/year'
                        : '\$9.99/month',
                    style: PlanPageStyles.price,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _selectedPlan == PlanType.annual
                        ? '(\$4.08/month)'
                        : '(\$120/year)',
                    style: PlanPageStyles.priceSub,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C6EAB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final authStore = context.read<AuthStore>();
                  
                  print('🔵 ========== START MY FREE TRIAL BUTTON PRESSED ==========');
                  print('🔵 Current user: ${authStore.user?.id ?? "not logged in"}');
                  
                  // Call API to assign free trial
                  print('🔵 ========== Assigning free trial via API ==========');
                  await authStore.assignFreeTrial();
                  
                  if (!authStore.isLoading && authStore.error == null) {
                    print('✅ Free trial assigned successfully via API');
                    print('🔵 Going to next step');
                    _goToNextStep();
                  } else {
                    print('⚠️ Free trial assignment failed or still loading');
                    print('⚠️ Error: ${authStore.error}');
                  }
                },
                child: const Text(
                  'Start my free trial ',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF2EFEA),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        );
        onBack = _showExitDialog;
        break;
      case PlanStep.dreamLifeIntro:
        title = '';
        subtitle = null;
        child = LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            final headerHeight = 200.0; // Header balandligi (logo + padding)
            final bottomPadding = 40.0; // Pastki padding (Terms uchun)
            final contentHeight = screenHeight - headerHeight - bottomPadding;
            final topPadding =
                contentHeight / 2 - 220; // Content balandligi taxminan 300px

            return Center(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, topPadding, 10, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Set sail to your dream life',

                      style: PlanPageStyles.pageTitle.copyWith(
                        fontSize: 34.sp,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      child: Text(
                        'We will set up your profile based on your answers to generate your customized manifesting meditation experience, grounded in neuroscience, and tailored to you.',

                        style: PlanPageStyles.cardBody.copyWith(
                          fontSize: 15.sp,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3C6EAB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/generator');
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue to Dream Life Intake',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Satoshi',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFF2EFEA),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
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
        onBack = _showExitDialog;
        break;
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _showExitDialog();
        }
      },
      child: AuthScaffold(
        title: title,
        subtitle: subtitle,
        onBack: onBack,
        showTerms: _currentStep == PlanStep.choosePlan,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 50),
        child: child,
      ),
    );
  }
}
