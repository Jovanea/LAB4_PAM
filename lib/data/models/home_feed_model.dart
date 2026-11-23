import '../../domain/entities/home_feed.dart';

/// STRATUL DATA - entitatea [HomeFeed] + conversia din si in JSON.
///
/// JSON-ul de la `GET /feed` este imbricat (header, learnedToday, ...);
/// modelul il citeste si pune valorile in campurile simple ale entitatii.
/// Pentru ca extinde [HomeFeed], restul aplicatiei il vede ca pe o entitate.
class HomeFeedModel extends HomeFeed {
  const HomeFeedModel({
    required super.greeting,
    required super.subtitle,
    required super.avatarUrl,
    required super.learnedTitle,
    required super.learnedMinutes,
    required super.goalMinutes,
    required super.myCoursesLabel,
    required super.promoTitle,
    required super.promoAction,
    required super.promoImageUrl,
    required super.planTitle,
    required super.plan,
    required super.meetupTitle,
    required super.meetupSubtitle,
    required super.meetupImageUrl,
  });

  /// DESERIALIZARE: Map (rezultatul lui jsonDecode) -> obiect Dart.
  /// Daca lipseste un camp sau are alt tip, `as` arunca o eroare, pe care
  /// repository-ul o transforma in mesajul "unexpected data".
  factory HomeFeedModel.fromJson(Map<String, dynamic> json) {
    final header = json['header'] as Map<String, dynamic>;
    final learned = json['learnedToday'] as Map<String, dynamic>;
    final myCourses = json['myCourses'] as Map<String, dynamic>;
    final prompt = json['learningPrompt'] as Map<String, dynamic>;
    final plan = json['learningPlan'] as Map<String, dynamic>;
    final meetup = json['meetup'] as Map<String, dynamic>;

    return HomeFeedModel(
      greeting: header['greeting'] as String,
      subtitle: header['subtitle'] as String,
      avatarUrl: header['avatarUrl'] as String,
      learnedTitle: learned['title'] as String,
      learnedMinutes: learned['learnedMinutes'] as int,
      goalMinutes: learned['goalMinutes'] as int,
      myCoursesLabel: myCourses['actionLabel'] as String,
      promoTitle: prompt['title'] as String,
      promoAction: prompt['actionLabel'] as String,
      promoImageUrl: prompt['imageUrl'] as String,
      planTitle: plan['title'] as String,
      plan: (plan['items'] as List<dynamic>)
          .map((item) => _planItemFromJson(item as Map<String, dynamic>))
          .toList(),
      meetupTitle: meetup['title'] as String,
      meetupSubtitle: meetup['subtitle'] as String,
      meetupImageUrl: meetup['imageUrl'] as String,
    );
  }

  static PlanItem _planItemFromJson(Map<String, dynamic> json) => PlanItem(
        id: json['id'] as String,
        title: json['title'] as String,
        completed: json['completed'] as int,
        total: json['total'] as int,
      );

  /// SERIALIZARE: obiect Dart -> Map, cu aceeasi forma ca JSON-ul serverului
  /// (doar campurile folosite de aplicatie). `jsonEncode(toJson())` da textul.
  Map<String, dynamic> toJson() => {
        'header': {
          'greeting': greeting,
          'subtitle': subtitle,
          'avatarUrl': avatarUrl,
        },
        'learnedToday': {
          'title': learnedTitle,
          'learnedMinutes': learnedMinutes,
          'goalMinutes': goalMinutes,
        },
        'myCourses': {'actionLabel': myCoursesLabel},
        'learningPrompt': {
          'title': promoTitle,
          'actionLabel': promoAction,
          'imageUrl': promoImageUrl,
        },
        'learningPlan': {
          'title': planTitle,
          'items': [
            for (final item in plan)
              {
                'id': item.id,
                'title': item.title,
                'completed': item.completed,
                'total': item.total,
              },
          ],
        },
        'meetup': {
          'title': meetupTitle,
          'subtitle': meetupSubtitle,
          'imageUrl': meetupImageUrl,
        },
      };
}
