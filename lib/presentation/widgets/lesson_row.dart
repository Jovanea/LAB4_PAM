import 'package:flutter/material.dart';

import '../../domain/entities/course_details.dart';
import '../theme/app_style.dart';

/// Un rand din lista de lectii (nodurile 1641:458 ... 1641:488 din Figma).
///
/// In design: cerc de 42 px, titlul la 102 px de marginea ecranului,
/// sageata portocalie in dreapta. Primul rand are cercul plin cu portocaliu.
/// Lectiile blocate (`locked` din API) au lacat si culoare stinsa.
class LessonRow extends StatelessWidget {
  const LessonRow({
    super.key,
    required this.lesson,
    this.highlighted = false,
    this.onTap,
  });

  final Lesson lesson;

  /// `true` pentru lectia curenta (cerc portocaliu, iconita alba).
  final bool highlighted;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool locked = lesson.locked;
    final Color iconColor = locked ? AppColors.locked : AppColors.accent;

    return GestureDetector(
      // O lectie blocata nu se poate deschide
      onTap: locked ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            // Cercul cu iconita de redare
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: highlighted ? AppColors.accent : Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [AppShadows.smallPlay],
              ),
              child: Icon(
                locked
                    ? Icons.lock_rounded
                    : lesson.completed
                        ? Icons.check_rounded
                        : Icons.play_arrow_rounded,
                size: locked ? 18 : 22,
                color: highlighted ? Colors.white : iconColor,
              ),
            ),
            const SizedBox(width: 24),

            // Titlul lectiei si durata ei
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: kFontCourse,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.19,
                      color: AppColors.ink2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lesson.duration} min',
                    style: const TextStyle(
                      fontFamily: kFontCourse,
                      fontSize: 16,
                      height: 1.19,
                      color: AppColors.duration,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}
