import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/stores/auth_store.dart';

class ExitConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String stayButtonText;
  final String exitButtonText;
  final VoidCallback? onExit;

  const ExitConfirmationDialog({
    super.key,
    this.title = 'Exit?',
    this.message = 'Are you sure you want to exit?',
    this.stayButtonText = 'Stay ',
    this.exitButtonText = 'Exit ',
    this.onExit,
  });

  static Future<bool?> show(
    BuildContext context, {
    String title = 'Exit?',
    String message = 'Are you sure you want to exit?',
    String stayButtonText = 'Stay',
    String exitButtonText = 'Exit ',
    VoidCallback? onExit,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ExitConfirmationDialog(
          title: title,
          message: message,
          stayButtonText: stayButtonText,
          exitButtonText: exitButtonText,
          onExit: onExit,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF2EFEA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF3B6EAA),
          fontSize: 20.sp,
          fontFamily: 'Satoshi',
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        message,
        style: TextStyle(
          color: const Color(0xFF3B6EAA),
          fontSize: 14.sp,
          fontFamily: 'Satoshi',
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Color(0xFF3B6EAA)),
                  ),
                ),
                child: Text(
                  stayButtonText,
                  style: TextStyle(
                    color: const Color(0xFF3B6EAA),
                    fontSize: 14.sp,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  
                  if (onExit != null) {
                    onExit!();
                  } else {
                    // Default behavior: logout and navigate to login
                    final authStore = context.read<AuthStore>();
                    await authStore.logout();
                    
                    if (context.mounted) {
                      // Navigate to login page and clear navigation stack
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B6EAB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  exitButtonText,
                  style: TextStyle(
                    color: const Color(0xFFF2EFEA),
                    fontSize: 14.sp,
                    fontFamily: 'Satoshi',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
