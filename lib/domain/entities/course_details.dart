/// STRATUL DOMAIN - datele ecranului "Course Overview".
class CourseDetails {
  const CourseDetails({
    required this.screenTitle,
    required this.id,
    required this.title,
    required this.duration,
    required this.lessonCount,
    required this.rating,
    required this.heroLabel,
    required this.heroImageUrl,
    required this.videoCount,
    required this.classCount,
    required this.lessonsTab,
    required this.descriptionTab,
    required this.lessons,
    required this.description,
    required this.priceLabel,
    required this.enrollLabel,
    required this.enrollEnabled,
  });

  final String screenTitle; // "Course Overview"

  // --- Cursul ---
  final String id;
  final String title;
  final String duration; // "6h 30min"
  final int lessonCount;
  final double rating;

  // --- Imaginea mare de sus ---
  final String heroLabel; // "SPOKEN ENGLISH"
  final String heroImageUrl;
  final int videoCount;
  final int classCount;

  // --- Tab-urile si continutul lor ---
  final String lessonsTab; // "Lessons"
  final String descriptionTab; // "Description"
  final List<Lesson> lessons;
  final String description;

  // --- Bara de jos ---
  final String priceLabel; // "Free"
  final String enrollLabel; // "Enroll Now"
  final bool enrollEnabled;
}

/// O lectie din lista cursului.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.completed,
    required this.locked,
  });

  final String id;
  final String title;
  final String duration; // "04:28"
  final bool completed;
  final bool locked;
}
