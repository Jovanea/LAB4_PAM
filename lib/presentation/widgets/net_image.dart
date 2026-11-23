import 'package:flutter/material.dart';

import '../theme/app_style.dart';

/// Imagine descarcata de pe internet (adresa vine din API), cu doua stari:
///  * cat se descarca: fundal gri deschis in locul ei;
///  * daca nu poate fi descarcata: o iconita, in loc de eroare pe ecran.
///
/// Parintele trebuie sa-i dea o marime fixa (SizedBox, Positioned.fill ...).
class NetImage extends StatelessWidget {
  const NetImage(
    this.url, {
    super.key,
    this.alignment = Alignment.center,
    this.semanticLabel,
  });

  final String url;
  final Alignment alignment;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      alignment: alignment,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const ColoredBox(color: AppColors.trackGrey),
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: AppColors.trackGrey,
        child: Center(
          child: Icon(Icons.image_not_supported_outlined, color: AppColors.grey),
        ),
      ),
    );
  }
}
