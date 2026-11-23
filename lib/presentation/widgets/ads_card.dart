import 'package:flutter/material.dart';

import '../theme/app_style.dart';
import 'net_image.dart';

/// O caseta din slider-ul de pe prima pagina (nodul 3:1594 "ads" din Figma).
///
/// In design: 249 x 154, colturi rotunjite 16, fundal #CEECFE.
/// Exista doua variante:
///  * [AdsCard.promo]  - textul, butonul si poza vin din API;
///  * [AdsCard.image]  - ilustratia decorativa din proiect (API-ul nu are
///    date pentru ea).
class AdsCard extends StatelessWidget {
  const AdsCard.promo({
    super.key,
    required this.width,
    required String this.title,
    required String this.actionLabel,
    required String imageUrl,
    VoidCallback? onGetStarted,
  })  : image = imageUrl,
        isPromo = true,
        onTap = onGetStarted;

  const AdsCard.image({
    super.key,
    required this.width,
    required String asset,
    this.onTap,
  })  : image = asset,
        title = null,
        actionLabel = null,
        isPromo = false;

  /// Latimea casetei (calculata proportional cu latimea ecranului).
  final double width;

  /// Adresa pozei (promo) sau calea ilustratiei din proiect.
  final String image;

  final String? title;
  final String? actionLabel;

  /// `true` pentru caseta cu text + buton.
  final bool isPromo;

  final VoidCallback? onTap;

  /// Inaltimea casetei, din design.
  static const double height = 154;

  /// Raza colturilor, din design.
  static const double radius = 16;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPromo ? null : onTap,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(radius)),
        child: Container(
          width: width,
          height: height,
          color: AppColors.adsBlue,
          child: isPromo ? _buildPromo() : _buildImage(),
        ),
      ),
    );
  }

  // ---------- Caseta 1: text + buton, poza din API in dreapta ----------
  Widget _buildPromo() {
    return Stack(
      children: [
        // Poza ocupa jumatatea din dreapta, ca ilustratia din design.
        // ShaderMask face marginea ei stanga transparenta, asa ca poza se
        // topeste in fundalul albastru si textul ramane lizibil.
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: width * 0.5,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const LinearGradient(
              colors: [Color(0x00000000), Color(0xFF000000)],
              stops: [0.0, 0.6],
            ).createShader(rect),
            child: NetImage(image),
          ),
        ),
        Positioned(
          left: 18,
          top: 19.5,
          // Textul ramane in partea libera din stanga, peste fundal
          width: width * 0.6,
          child: Text(
            title!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: AppColors.ink,
            ),
          ),
        ),
        Positioned(
          left: 18,
          top: 104.5,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 31,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Caseta 2: doar ilustratia ----------
  Widget _buildImage() {
    return Align(
      alignment: Alignment.center,
      child: Image.asset(image, height: height, fit: BoxFit.fitHeight),
    );
  }
}
