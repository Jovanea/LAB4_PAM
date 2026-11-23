import '../entities/course_details.dart';
import '../entities/home_feed.dart';

/// Contractul dintre Domain si Data: CE date poate cere aplicatia.
///
/// Domain spune doar "am nevoie de feed si de detaliile cursului";
/// CUM se aduc (HTTP, cache, fisier) decide implementarea din stratul Data.
/// Ambele metode arunca un [Failure] daca datele nu pot fi aduse.
abstract interface class CourseRepository {
  Future<HomeFeed> getHomeFeed();

  Future<CourseDetails> getCourseDetails();
}
