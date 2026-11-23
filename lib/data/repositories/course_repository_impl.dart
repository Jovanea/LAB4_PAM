import 'dart:async';

import 'package:http/http.dart' as http;

import '../../domain/entities/course_details.dart';
import '../../domain/entities/home_feed.dart';
import '../../domain/failure.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_api.dart';

/// STRATUL DATA - implementarea contractului [CourseRepository] din Domain.
///
/// Ia datele de la [CourseApi] si transforma orice eroare tehnica intr-un
/// [Failure] cu un mesaj clar. Astfel interfata nu vede niciodata
/// exceptii de retea sau de JSON.
class CourseRepositoryImpl implements CourseRepository {
  const CourseRepositoryImpl(this._api);

  final CourseApi _api;

  @override
  Future<HomeFeed> getHomeFeed() => _guard(_api.getHomeFeed);

  @override
  Future<CourseDetails> getCourseDetails() => _guard(_api.getCourseDetails);

  /// Ruleaza cererea si traduce erorile in mesaje pentru utilizator.
  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on TimeoutException {
      throw const Failure(
        'The server is taking too long to respond. Please try again.',
      );
    } on http.ClientException {
      // Fara internet, serverul nu poate fi gasit, conexiune intrerupta
      throw const Failure(
        'No internet connection. Check your network and try again.',
      );
    } on ServerException catch (e) {
      throw Failure('The server returned an error (${e.statusCode}). '
          'Please try again later.');
    } on FormatException {
      throw const Failure('The server sent data in an unexpected format.');
    } catch (_) {
      // De ex. un camp lipsa din JSON (eroare de tip la `as`)
      throw const Failure('Could not read the data. Please try again.');
    }
  }
}
