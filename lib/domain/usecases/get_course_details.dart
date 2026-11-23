import '../entities/course_details.dart';
import '../repositories/course_repository.dart';

/// Cazul de utilizare "Deschide detaliile cursului".
class GetCourseDetails {
  const GetCourseDetails(this._repository);

  final CourseRepository _repository;

  Future<CourseDetails> call() => _repository.getCourseDetails();
}
