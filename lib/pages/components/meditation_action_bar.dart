import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MeditationActionBar extends StatelessWidget {
  final bool isMuted;
  final bool isLiked;
  final VoidCallback onMuteToggle;
  final VoidCallback onLikeToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback onShare;
  final bool showLikeText;

  const MeditationActionBar({
    super.key,
    required this.isMuted,
    required this.isLiked,
    required this.onMuteToggle,
    required this.onLikeToggle,
    this.onDelete,
    this.onEdit,
    required this.onShare,
    this.showLikeText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Mute icon
          IconButton(
            icon: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
            ),
            onPressed: onMuteToggle,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.05),
          // Delete button - only show if onDelete is provided
          if (onDelete != null)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF), // #FFFFFF1A
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: onDelete,
              ),
            ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          // Like button - conditional width based on showLikeText
          if (showLikeText)
            // Full width for library meditations
            Expanded(
              child: GestureDetector(
                onTap: onLikeToggle,
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Resonating?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Satoshi',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // Small width for my meditations (like edit/delete buttons)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF), // #FFFFFF1A
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: onLikeToggle,
              ),
            ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          // Edit button - only show if onEdit is provided
          if (onEdit != null)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF), // #FFFFFF1A
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: onEdit,
              ),
            ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          // Right (share) icon
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: onShare,
          ),
        ],
      ),
    );
  }
}
