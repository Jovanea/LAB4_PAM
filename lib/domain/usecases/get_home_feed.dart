import '../entities/home_feed.dart';
import '../repositories/course_repository.dart';

/// Cazul de utilizare "Afiseaza pagina principala": cere feed-ul.
///
/// Cubit-ul nu vorbeste direct cu repository-ul, ci prin aceasta clasa,
/// ca fiecare actiune a utilizatorului sa aiba un nume clar in cod.
class GetHomeFeed {
  const GetHomeFeed(this._repository);

  final CourseRepository _repository;

  /// `call` permite apelul ca pe o functie: `await getHomeFeed()`.
  Future<HomeFeed> call() => _repository.getHomeFeed();
}
