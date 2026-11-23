/// STRATUL DOMAIN - datele ecranului "Home", asa cum le foloseste aplicatia.
///
/// Entitatea este o clasa Dart simpla: nu stie nimic despre JSON, HTTP
/// sau Flutter. Forma JSON-ului de la server o cunoaste doar stratul Data.
class HomeFeed {
  const HomeFeed({
    required this.greeting,
    required this.subtitle,
    required this.avatarUrl,
    required this.learnedTitle,
    required this.learnedMinutes,
    required this.goalMinutes,
    required this.myCoursesLabel,
    required this.promoTitle,
    required this.promoAction,
    required this.promoImageUrl,
    required this.planTitle,
    required this.plan,
    required this.meetupTitle,
    required this.meetupSubtitle,
    required this.meetupImageUrl,
  });

  // --- Header-ul albastru ---
  final String greeting; // "Hi, Kristin"
  final String subtitle; // "Let's start learning"
  final String avatarUrl;

  // --- Cardul "Learned today" ---
  final String learnedTitle;
  final int learnedMinutes;
  final int goalMinutes;
  final String myCoursesLabel;

  // --- Caseta "What do you want to learn today?" ---
  final String promoTitle;
  final String promoAction; // "Get Started"
  final String promoImageUrl;

  // --- Sectiunea "Learning Plan" ---
  final String planTitle;
  final List<PlanItem> plan;

  // --- Cardul "Meetup" ---
  final String meetupTitle;
  final String meetupSubtitle;
  final String meetupImageUrl;
}

/// O linie din planul de invatare: cursul si cate lectii sunt parcurse.
class PlanItem {
  const PlanItem({
    required this.id,
    required this.title,
    required this.completed,
    required this.total,
  });

  final String id;
  final String title;
  final int completed;
  final int total;

  /// Cat din curs e parcurs (0..1), pentru inelul de progres.
  double get progress => total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);
}
