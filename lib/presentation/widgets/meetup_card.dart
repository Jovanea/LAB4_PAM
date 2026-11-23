import 'package:flutter/material.dart';

import '../theme/app_style.dart';
import 'net_image.dart';

/// Cardul "Meetup" de pe prima pagina (335 x 120 in design).
///
/// La Lab 2 era o singura imagine exportata din Figma; acum titlul,
/// textul si poza vin din API, iar culorile si asezarea raman cele din design.
class MeetupCard extends StatelessWidget {
  const MeetupCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.only(left: 22, right: 14),
        decoration: const BoxDecoration(
          color: AppColors.meetupBg,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [AppShadows.card],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: AppColors.meetupInk,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.meetupInk,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Poza rotunda intr-un cerc deschis, ca ilustratia din design
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0x80FFFFFF),
                shape: BoxShape.circle,
              ),
              child: ClipOval(child: NetImage(imageUrl)),
            ),
          ],
        ),
      ),
    );
  }
}
