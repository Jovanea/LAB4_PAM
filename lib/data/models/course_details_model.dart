import '../../domain/entities/course_details.dart';

/// STRATUL DATA - entitatea [CourseDetails] + conversia din si in JSON
/// (raspunsul de la `GET /feed/details`).
class CourseDetailsModel extends CourseDetails {
  const CourseDetailsModel({
    required super.screenTitle,
    required super.id,
    required super.title,
    required super.duration,
    required super.lessonCount,
    required super.rating,
    required super.heroLabel,
    required super.heroImageUrl,
    required super.videoCount,
    required super.classCount,
    required super.lessonsTab,
    required super.descriptionTab,
    required super.lessons,
    required super.description,
    required super.priceLabel,
    required super.enrollLabel,
    required super.enrollEnabled,
  });

  /// DESERIALIZARE: Map -> obiect Dart.
  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) {
    final navigation = json['navigation'] as Map<String, dynamic>;
    final course = json['course'] as Map<String, dynamic>;
    final hero = course['hero'] as Map<String, dynamic>;
    final actions = json['actions'] as Map<String, dynamic>;
    final price = actions['price'] as Map<String, dynamic>;
    final enroll = actions['enroll'] as Map<String, dynamic>;

    // Tab-urile vin ca lista [{id, label}]; le cautam dupa id
    final tabItems = (course['tabs'] as Map<String, dynamic>)['items'] as List<dynamic>;
    final Map<String, String> tabs = {
      for (final tab in tabItems.cast<Map<String, dynamic>>())
        tab['id'] as String: tab['label'] as String,
    };

    return CourseDetailsModel(
      screenTitle: navigation['title'] as String,
      id: course['id'] as String,
      title: course['title'] as String,
      duration: course['duration'] as String,
      lessonCount: course['lessonCount'] as int,
      // JSON nu deosebeste 5 de 5.0, deci citim ca `num`
      rating: (course['rating'] as num).toDouble(),
      heroLabel: hero['label'] as String,
      heroImageUrl: hero['imageUrl'] as String,
      videoCount: hero['videoCount'] as int,
      classCount: hero['classCount'] as int,
      lessonsTab: tabs['lessons'] ?? 'Lessons',
      descriptionTab: tabs['description'] ?? 'Description',
      lessons: (course['lessons'] as List<dynamic>)
          .map((item) => _lessonFromJson(item as Map<String, dynamic>))
          .toList(),
      description:
          (course['description'] as Map<String, dynamic>)['text'] as String,
      priceLabel: price['label'] as String,
      enrollLabel: enroll['label'] as String,
      enrollEnabled: enroll['enabled'] as bool,
    );
  }

  static Lesson _lessonFromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String,
        duration: json['duration'] as String,
        completed: json['completed'] as bool,
        locked: json['locked'] as bool,
      );

  /// SERIALIZARE: obiect Dart -> Map, cu forma JSON-ului de la server.
  Map<String, dynamic> toJson() => {
        'navigation': {'title': screenTitle},
        'course': {
          'id': id,
          'title': title,
          'duration': duration,
          'lessonCount': lessonCount,
          'rating': rating,
          'hero': {
            'label': heroLabel,
            'imageUrl': heroImageUrl,
            'videoCount': videoCount,
            'classCount': classCount,
          },
          'tabs': {
            'items': [
              {'id': 'lessons', 'label': lessonsTab},
              {'id': 'description', 'label': descriptionTab},
            ],
          },
          'lessons': [
            for (final lesson in lessons)
              {
                'id': lesson.id,
                'title': lesson.title,
                'duration': lesson.duration,
                'completed': lesson.completed,
                'locked': lesson.locked,
              },
          ],
          'description': {'text': description},
        },
        'actions': {
          'price': {'label': priceLabel},
          'enroll': {'label': enrollLabel, 'enabled': enrollEnabled},
        },
      };
}
