import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course_details_model.dart';
import '../models/home_feed_model.dart';

/// STRATUL DATA - sursa de date de la distanta (serviciul Web REST).
///
/// Singurul loc din aplicatie care stie adresa serverului si face cereri HTTP.
class CourseApi {
  CourseApi(this._client);

  static const String baseUrl = 'https://test-api-jlbn.onrender.com/lab2026/v4';

  /// Serverul gratuit (Render) "doarme" si la prima cerere porneste in
  /// 30-50 secunde, de aceea limita de asteptare e mai mare decat de obicei.
  static const Duration timeout = Duration(seconds: 60);

  final http.Client _client;

  /// GET /feed -> datele ecranului Home.
  Future<HomeFeedModel> getHomeFeed() async =>
      HomeFeedModel.fromJson(await _getJson('/feed'));

  /// GET /feed/details -> datele ecranului Course Overview.
  Future<CourseDetailsModel> getCourseDetails() async =>
      CourseDetailsModel.fromJson(await _getJson('/feed/details'));

  /// Trimite cererea GET si intoarce corpul raspunsului decodat din JSON.
  Future<Map<String, dynamic>> _getJson(String path) async {
    final http.Response response = await _client
        .get(
          Uri.parse('$baseUrl$path'),
          headers: const {'Accept': 'application/json'},
        )
        .timeout(timeout);

    if (response.statusCode != 200) {
      throw ServerException(response.statusCode);
    }

    // Decodam explicit ca UTF-8, ca "Let’s" sa nu apara cu caractere stricate
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }
}

/// Serverul a raspuns, dar cu un cod de eroare (404, 500 etc.).
class ServerException implements Exception {
  const ServerException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'ServerException($statusCode)';
}
