import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/svg_icon.dart';
import '../../../shared/widgets/profile_edit_modal.dart';

// Keep the old class for backwards compatibility but create new one
class NeuroplasticityButton extends StatefulWidget {
  const NeuroplasticityButton({super.key});

  @override
  State<NeuroplasticityButton> createState() => _NeuroplasticityButtonState();
}

class _NeuroplasticityButtonState extends State<NeuroplasticityButton> {
  bool _showCard = false;
  String _neuroplasticityContent =
      'Each time you reflect, reframe, and affirm your goals, you strengthen synaptic connections in the prefrontal cortex and reinforce identity-based neural pathways.You\'re literally reshaping your brain toward your dream life.';

  @override
  void initState() {
    super.initState();
    _loadNeuroplasticityState();
  }

  // Load neuroplasticity state from SharedPreferences
  Future<void> _loadNeuroplasticityState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showCard = prefs.getBool('neuroplasticity_active') ?? false;
      _neuroplasticityContent =
          prefs.getString('neuroplasticity_content') ?? _neuroplasticityContent;
    });
  }

  // Save neuroplasticity state to SharedPreferences
  Future<void> _saveNeuroplasticityState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('neuroplasticity_active', _showCard);
    await prefs.setString('neuroplasticity_content', _neuroplasticityContent);
  }


  void _showNeuroplasticityModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ProfileEditModal(
            title: 'Edit Neuroplasticity',
            prompt:
                'Describe how neuroplasticity is helping you transform your brain and achieve your goals.',
            hintText:
                'Each time you reflect, reframe, and affirm your goals, you strengthen synaptic connections in the prefrontal cortex and reinforce identity-based neural pathways. You\'re literally reshaping your brain toward your dream life.',
            initialValue: _neuroplasticityContent,
            onSave: (String newContent) async {
              setState(() {
                _neuroplasticityContent = newContent;
              });
              await _saveNeuroplasticityState();
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showCard) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title outside the card
          Row(
            children: [
              Text(
                'Neuroplasticity Activated',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontFamily: 'Satoshi',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showNeuroplasticityModal,
                child: const SvgIcon(
                  assetName: 'assets/icons/edit.svg',
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Card with internal title
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(164, 199, 234, 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Internal title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You just sparked change in your brain',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Satoshi',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Content
                Center(
                  child: Text(
                    _neuroplasticityContent,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Satoshi',
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () async {
        setState(() {
          _showCard = true;
        });
        await _saveNeuroplasticityState();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF3B6EAA),
          borderRadius: BorderRadius.circular(200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(
              assetName: 'assets/icons/brain.svg',
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              'Neuroplasticity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New always-visible Neuroplasticity card
class NeuroplasticityCard extends StatefulWidget {
  const NeuroplasticityCard({super.key});

  @override
  State<NeuroplasticityCard> createState() => _NeuroplasticityCardState();
}

class _NeuroplasticityCardState extends State<NeuroplasticityCard> {
  String _neuroplasticityContent =
      'Embarking on a journey to realize my dreams has been transformative. I feel most alive when I chase my aspirations and stay true to who I am.';

  @override
  void initState() {
    super.initState();
    _loadNeuroplasticityState();
  }

  // Load neuroplasticity state from SharedPreferences
  Future<void> _loadNeuroplasticityState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _neuroplasticityContent =
          prefs.getString('neuroplasticity_content') ?? _neuroplasticityContent;
    });
  }

  void _showNeuroplasticityModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ProfileEditModal(
            title: 'Neuroplasticity',
            prompt:
                'Describe how neuroplasticity is helping you transform your brain and achieve your goals.',
            hintText:
                'Embarking on a journey to realize my dreams has been transformative. I feel most alive when I chase my aspirations and stay true to who I am.',
            initialValue: _neuroplasticityContent,
            onSave: (String newContent) async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('neuroplasticity_content', newContent);
              setState(() {
                _neuroplasticityContent = newContent;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title outside the card
        Row(
          children: [
            Text(
              'Neuroplasticity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontFamily: 'Satoshi',
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _showNeuroplasticityModal,
              child: const SvgIcon(
                assetName: 'assets/icons/edit.svg',
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Card
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(164, 199, 234, 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              Center(
                child: Text(
                  _neuroplasticityContent,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Satoshi',
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
