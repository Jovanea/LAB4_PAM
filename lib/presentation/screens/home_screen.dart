import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/home_feed.dart';
import '../../domain/repositories/course_repository.dart';
import '../cubit/home_cubit.dart';
import '../theme/app_style.dart';
import '../widgets/ads_card.dart';
import '../widgets/learned_today_card.dart';
import '../widgets/learning_plan_card.dart';
import '../widgets/meetup_card.dart';
import '../widgets/net_image.dart';
import '../widgets/status_views.dart';
import 'course_overview_screen.dart';

/// ECRANUL 1 - "Home" (frame-ul 3:1402 din Figma, varianta 4).
///
/// Designul este cel din Lab 2; datele vin acum din `GET /feed`, prin
/// [HomeCubit]. Ecranul doar deseneaza starea curenta a Cubit-ului.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Dimensiunile din design (latimea artboard-ului Figma este 375 px) ---
  static const double _pagePad = 20; // marginea laterala a continutului
  static const double _designContent = 335; // 375 - 2 * 20
  static const double _designCardW = 249; // latimea unei casete din slider
  static const double _designGap = 12; // spatiul dintre casete
  static const double _adsHeight = 154; // inaltimea casetelor din slider

  // --- Starea slider-ului de casete (tine doar de interfata) ---
  PageController? _adsController;
  double _adsFraction = 0;
  int _adsPage = 0;

  /// Dimensiunile slider-ului, proportionale cu latimea ecranului (ca la
  /// Lab 2). Latimea e limitata inferior, pentru ca la primul frame Android
  /// poate raporta 0x0 si `PageView` ar primi un padding negativ.
  ({double cardW, double gap, double fraction}) _adsMetrics(double rawWidth) {
    final double screenW = rawWidth < 2 * _pagePad + 1 ? 375 : rawWidth;
    final double contentW = screenW - 2 * _pagePad;
    final double cardW = contentW * _designCardW / _designContent;
    final double gap = contentW * _designGap / _designContent;
    final double fraction =
        ((cardW + gap) / (screenW - _pagePad)).clamp(0.1, 1.0);
    return (cardW: cardW, gap: gap, fraction: fraction);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double fraction =
        _adsMetrics(MediaQuery.of(context).size.width).fraction;

    if (_adsController == null || (fraction - _adsFraction).abs() > 0.001) {
      _adsController?.dispose();
      _adsFraction = fraction;
      _adsController = PageController(viewportFraction: fraction);
    }
  }

  @override
  void dispose() {
    _adsController?.dispose();
    super.dispose();
  }

  /// Navigheaza spre ecranul al doilea (Course Overview).
  void _openCourse() {
    Navigator.of(context).push(
      CourseOverviewScreen.route(context.read<CourseRepository>()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Iconitele barei de status sunt albe peste header-ul albastru
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ---------- Fundalul albastru al header-ului (375 x 183) ----------
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: mq.padding.top + 139, // 183 - 44 (bara de status) = 139
              child: const ColoredBox(color: AppColors.blue),
            ),

            SafeArea(
              bottom: false,
              // BlocBuilder redeseneaza ecranul la fiecare stare noua
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) => switch (state) {
                  HomeLoading() => const _HomeSkeleton(),
                  HomeError(:final message) => Center(
                      child: ErrorView(
                        title: 'Couldn\'t load the page',
                        message: message,
                        onRetry: context.read<HomeCubit>().load,
                      ),
                    ),
                  HomeLoaded(:final feed) => _buildContent(feed, mq),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Starea Loaded: pagina din Lab 2, completata cu datele din [feed].
  Widget _buildContent(HomeFeed feed, MediaQueryData mq) {
    final metrics = _adsMetrics(mq.size.width);
    final double cardW = metrics.cardW;
    final double gap = metrics.gap;

    // "Trage in jos" cere din nou datele de la server
    return RefreshIndicator(
      onRefresh: context.read<HomeCubit>().load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= HEADER: salut + avatar =================
            SizedBox(
              height: 93, // de la y=44 la y=137 in design
              child: Stack(
                children: [
                  Positioned(
                    left: _pagePad,
                    right: 76,
                    top: 17,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed.greeting,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          feed.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 21,
                    top: 24,
                    width: 40,
                    height: 40,
                    child: ClipOval(
                      child: NetImage(
                        feed.avatarUrl,
                        semanticLabel: 'Profile photo',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ========== CARD: "Learned today" + bara de progres ==========
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _pagePad),
              child: LearnedTodayCard(
                title: feed.learnedTitle,
                minutes: feed.learnedMinutes,
                goalMinutes: feed.goalMinutes,
                actionLabel: feed.myCoursesLabel,
                onMyCourses: _openCourse,
              ),
            ),

            const SizedBox(height: 17),

            // ================= SLIDER-UL DE CASETE (ads) =================
            SizedBox(
              height: _adsHeight,
              child: PageView(
                controller: _adsController,
                padEnds: false,
                onPageChanged: (i) => setState(() => _adsPage = i),
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: _pagePad, right: gap),
                    child: AdsCard.promo(
                      width: cardW,
                      title: feed.promoTitle,
                      actionLabel: feed.promoAction,
                      imageUrl: feed.promoImageUrl,
                      onGetStarted: _openCourse,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: gap),
                    child: AdsCard.image(
                      width: cardW,
                      asset: 'assets/images/ads_2.png',
                      onTap: _openCourse,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= SECTIUNEA "Learning Plan" =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _pagePad),
              child: Text(
                feed.planTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _pagePad),
              child: LearningPlanCard(items: feed.plan, onTap: _openCourse),
            ),

            const SizedBox(height: 14),

            // ===================== CARDUL "Meetup" =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _pagePad),
              child: MeetupCard(
                title: feed.meetupTitle,
                subtitle: feed.meetupSubtitle,
                imageUrl: feed.meetupImageUrl,
                onTap: _openCourse,
              ),
            ),

            // Punctele slider-ului (ajutor vizual, in afara zonei din Figma)
            const SizedBox(height: 24),
            _AdsDots(count: 2, current: _adsPage),
            SizedBox(height: 24 + mq.padding.bottom),
          ],
        ),
      ),
    );
  }
}

/// Starea Loading: "scheletul" paginii, cu aceleasi blocuri ca pagina reala,
/// ca ecranul sa nu sara cand vin datele.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  // Pe fundalul albastru blocurile sunt albe semi-transparente
  static const Color _onBlue = Color(0x33FFFFFF);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 93,
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 150, height: 26, color: _onBlue),
                      SizedBox(height: 8),
                      SkeletonBox(width: 120, height: 14, color: _onBlue),
                    ],
                  ),
                  Spacer(),
                  SkeletonBox(width: 40, height: 40, radius: 20, color: _onBlue),
                ],
              ),
            ),
            // Cardul "Learned today"
            Container(
              height: 96,
              padding: const EdgeInsets.fromLTRB(16, 20, 15, 17),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                boxShadow: [AppShadows.card],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 90, height: 12),
                  SizedBox(height: 10),
                  SkeletonBox(width: 120, height: 18),
                  Spacer(),
                  SkeletonBox(height: 6),
                ],
              ),
            ),
            const SizedBox(height: 17),
            const SkeletonBox(width: 249, height: 154, radius: 16),
            const SizedBox(height: 25),
            const SkeletonBox(width: 130, height: 20),
            const SizedBox(height: 10),
            const SkeletonBox(height: 133, radius: 12),
            const SizedBox(height: 14),
            const SkeletonBox(height: 120, radius: 12),
          ],
        ),
      ),
    );
  }
}

/// Punctele care arata la ce caseta din slider ne aflam.
class _AdsDots extends StatelessWidget {
  const _AdsDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.blue : AppColors.greyLight,
            borderRadius: const BorderRadius.all(Radius.circular(3)),
          ),
        );
      }),
    );
  }
}
