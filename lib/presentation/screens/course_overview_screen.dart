import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/course_details.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/usecases/get_course_details.dart';
import '../cubit/course_cubit.dart';
import '../theme/app_style.dart';
import '../widgets/lesson_row.dart';
import '../widgets/net_image.dart';
import '../widgets/status_views.dart';

/// ECRANUL 2 - "Course Overview" (frame-ul 1641:428 din Figma, varianta 4).
///
/// Designul este cel din Lab 2; datele vin din `GET /feed/details`,
/// prin [CourseCubit].
class CourseOverviewScreen extends StatefulWidget {
  const CourseOverviewScreen({super.key});

  /// Ruta spre acest ecran, impreuna cu Cubit-ul lui. Cubit-ul traieste
  /// cat timp ecranul e deschis si porneste imediat incarcarea datelor.
  static Route<void> route(CourseRepository repository) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => CourseCubit(GetCourseDetails(repository))..load(),
        child: const CourseOverviewScreen(),
      ),
    );
  }

  @override
  State<CourseOverviewScreen> createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen> {
  // --- Marginile din design (latimea artboard-ului Figma este 393 px) ---
  static const double _padLeft = 36;
  static const double _padRight = 22;

  /// Tab-ul activ: 0 = Lessons, 1 = Description (tine doar de interfata).
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Fundal deschis => iconitele barei de status sunt inchise la culoare
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBg,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<CourseCubit, CourseState>(
            builder: (context, state) => switch (state) {
              CourseLoading() => Column(
                  children: [
                    const SizedBox(height: 3),
                    _buildAppBar(''),
                    const Expanded(child: _CourseSkeleton()),
                  ],
                ),
              CourseError(:final message) => Column(
                  children: [
                    const SizedBox(height: 3),
                    _buildAppBar(''),
                    Expanded(
                      child: Center(
                        child: ErrorView(
                          title: 'Couldn\'t load the course',
                          message: message,
                          onRetry: context.read<CourseCubit>().load,
                        ),
                      ),
                    ),
                  ],
                ),
              CourseLoaded(:final course) => _buildContent(course),
            },
          ),
        ),
      ),
    );
  }

  /// Starea Loaded: pagina din Lab 2, completata cu datele din [course].
  Widget _buildContent(CourseDetails course) {
    final MediaQueryData mq = MediaQuery.of(context);
    // Inaltimea barei de jos (gradient + butoane), ca sa nu acopere continutul
    final double bottomBarHeight = 41 + 48 + 16 + mq.padding.bottom;

    return Stack(
      // Stack-ul ocupa tot ecranul, ca bara de jos sa stea lipita de jos
      // si cand continutul e scurt (tab-ul Description)
      fit: StackFit.expand,
      children: [
        // ===================== CONTINUTUL DERULABIL =====================
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: bottomBarHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 3),
              _buildAppBar(course.screenTitle),

              const SizedBox(height: 44),

              // -------- Imaginea cursului + butonul mare de "play" --------
              Padding(
                padding: const EdgeInsets.only(left: _padLeft, right: _padRight),
                child: AspectRatio(
                  aspectRatio: 335 / 207,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _HeroImage(course: course),
                      _buildBigPlayButton(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 34),

              // -------------------- Titlul cursului --------------------
              Padding(
                padding: const EdgeInsets.only(left: _padLeft, right: _padRight),
                child: Text(
                  course.title,
                  style: const TextStyle(
                    fontFamily: kFontCourse,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                    color: AppColors.ink2,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------- Durata, numarul de lectii, nota -------------
              Padding(
                padding: const EdgeInsets.only(left: _padLeft, right: _padRight),
                child: _MetaRow(course: course),
              ),

              const SizedBox(height: 22),

              // ------------------ Tab-urile + linia activa ------------------
              _buildTabs(course),

              const SizedBox(height: 26),

              // ------------------- Continutul tab-ului -------------------
              ..._buildTabContent(course),
            ],
          ),
        ),

        // ============ BARA DE JOS: gradient + butoanele de actiune ============
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomBar(course, mq.padding.bottom),
        ),
      ],
    );
  }

  /// Lista de widget-uri afisata sub tab-uri (lectii sau descriere).
  List<Widget> _buildTabContent(CourseDetails course) {
    if (_tab == 1) {
      // API-ul poate trimite descrierea goala
      final bool empty = course.description.trim().isEmpty;
      return [
        Padding(
          padding: const EdgeInsets.only(left: _padLeft, right: _padRight),
          child: Text(
            empty ? 'No description for this course yet.' : course.description,
            style: const TextStyle(
              fontFamily: kFontCourse,
              fontSize: 16,
              height: 1.6,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ];
    }

    final List<Widget> rows = [];
    for (int i = 0; i < course.lessons.length; i++) {
      final Lesson lesson = course.lessons[i];
      if (i > 0) rows.add(const SizedBox(height: 28));
      rows.add(
        Padding(
          // sageata din dreapta se opreste la x=361 in design (393 - 32)
          padding: const EdgeInsets.only(left: _padLeft, right: 32),
          child: LessonRow(
            key: ValueKey(lesson.id),
            lesson: lesson,
            highlighted: i == 0 && !lesson.locked,
            onTap: () {},
          ),
        ),
      );
    }
    return rows;
  }

  // --------------------------- Bara de sus ---------------------------
  Widget _buildAppBar(String title) {
    return SizedBox(
      height: 40,
      child: Stack(
        children: [
          // Sageata de intoarcere (cadru de 40x40 la x=11 in design)
          Positioned(
            left: 11,
            top: 0,
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 21,
                color: Colors.black,
              ),
            ),
          ),
          // Titlul incepe la x=42 in design
          Positioned(
            left: 42,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: kFontCourse,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ Butonul mare de "play" de pe imagine ------------------
  Widget _buildBigPlayButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [AppShadows.bigPlay],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          size: 30,
          color: AppColors.accent,
        ),
      ),
    );
  }

  // ------------------------ Tab-urile Lessons / Description ------------------------
  Widget _buildTabs(CourseDetails course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 21,
          child: Row(
            children: [
              const SizedBox(width: 113),
              _tabLabel(course.lessonsTab, 0),
              const SizedBox(width: 36),
              _tabLabel(course.descriptionTab, 1),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Linia portocalie de sub tab-ul activ (100 x 2 in design)
        SizedBox(
          height: 2,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                left: _tab == 0 ? 97 : 213.5,
                top: 0,
                child: Container(
                  width: 100,
                  height: 2,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.all(Radius.circular(1)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabLabel(String text, int index) {
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: kFontCourse,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.17,
          color: _tab == index ? AppColors.accent : AppColors.tabOff,
        ),
      ),
    );
  }

  // ------------------------ Bara de jos cu butoane ------------------------
  Widget _buildBottomBar(CourseDetails course, double safeBottom) {
    return Container(
      padding: EdgeInsets.only(
        left: _padLeft,
        right: _padRight,
        top: 41,
        bottom: 16 + safeBottom,
      ),
      decoration: const BoxDecoration(
        // Estompeaza lista de lectii pe sub butoane, exact ca in design
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCEF9FBFF), AppColors.pageBg],
          stops: [0.05, 0.575],
        ),
      ),
      child: Row(
        children: [
          // Pretul ("Free")
          Container(
            constraints: const BoxConstraints(minWidth: 70),
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: const BorderRadius.all(Radius.circular(14)),
            ),
            child: Text(
              course.priceLabel,
              style: const TextStyle(
                fontFamily: kFontCourse,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Butonul "Enroll Now" (gri daca serverul spune ca e inactiv)
          Expanded(
            child: GestureDetector(
              onTap: course.enrollEnabled ? () {} : null,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: course.enrollEnabled
                      ? AppColors.accent
                      : AppColors.tabOff,
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                ),
                child: Text(
                  course.enrollLabel,
                  style: const TextStyle(
                    fontFamily: kFontCourse,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Imaginea mare a cursului. La Lab 2 textele erau "lipite" in imagine;
/// acum poza, eticheta ("SPOKEN ENGLISH") si cifrele vin din API.
class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.course});

  final CourseDetails course;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(
            course.heroImageUrl,
            // Poza e verticala: aratam partea de sus, ca fata sa nu fie
            // acoperita de butonul "play" din mijloc
            alignment: const Alignment(0, -0.45),
            semanticLabel: course.title,
          ),
          // Nuanta mov din design, ca eticheta alba sa fie lizibila
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xD95B3FE0), Color(0x005B3FE0)],
                stops: [0.0, 0.5],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Text(
              course.heroLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HeroPill(
                  icon: Icons.ondemand_video_rounded,
                  text: '${course.videoCount} Videos',
                ),
                const SizedBox(width: 6),
                _HeroPill(
                  icon: Icons.cast_for_education_rounded,
                  text: '${course.classCount} Class',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Eticheta alba de jos ("75 Videos", "35 Class").
class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Randul cu durata cursului, numarul de lectii si nota.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.course});

  final CourseDetails course;

  @override
  Widget build(BuildContext context) {
    const TextStyle metaStyle = TextStyle(
      fontFamily: kFontCourse,
      fontSize: 14.28,
      height: 1.19,
      color: AppColors.meta,
    );

    return SizedBox(
      height: 24,
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded, size: 14.28, color: AppColors.meta),
          const SizedBox(width: 4),
          Text(course.duration, style: metaStyle),
          const SizedBox(width: 8),
          Container(
            width: 2,
            height: 2,
            decoration: const BoxDecoration(
              color: AppColors.meta,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('${course.lessonCount} lessons', style: metaStyle),
          const Spacer(),
          // Eticheta cu nota
          Container(
            width: 54,
            height: 24,
            padding: const EdgeInsets.only(left: 6, right: 5),
            decoration: const BoxDecoration(
              color: AppColors.pillBg,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 20, color: AppColors.star),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    course.rating.toStringAsFixed(1),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontFamily: kFontCourse,
                      fontSize: 14.28,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
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

/// Starea Loading a ecranului de detalii: scheletul imaginii, titlului
/// si al listei de lectii.
class _CourseSkeleton extends StatelessWidget {
  const _CourseSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 36, right: 22, top: 44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AspectRatio(
              aspectRatio: 335 / 207,
              child: SkeletonBox(height: double.infinity, radius: 14),
            ),
            const SizedBox(height: 34),
            const SkeletonBox(width: 200, height: 22),
            const SizedBox(height: 14),
            const SkeletonBox(width: 160, height: 16),
            const SizedBox(height: 50),
            for (int i = 0; i < 4; i++) ...[
              const Row(
                children: [
                  SkeletonBox(width: 42, height: 42, radius: 21),
                  SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 170, height: 16),
                      SizedBox(height: 6),
                      SkeletonBox(width: 80, height: 14),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
          ],
        ),
      ),
    );
  }
}
