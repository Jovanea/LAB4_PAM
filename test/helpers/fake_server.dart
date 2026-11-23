import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab_4_pam/data/datasources/course_api.dart';
import 'package:lab_4_pam/data/repositories/course_repository_impl.dart';

/// Raspunsurile reale ale serverului, salvate in `test/fixtures/`.
String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

/// Raspunsul pe care l-ar da API-ul real pentru cererea [request].
/// [status] permite simularea unei erori de server (ex. 500).
http.Response apiResponse(http.BaseRequest request, {int status = 200}) {
  final String file =
      request.url.path.endsWith('/feed/details') ? 'details.json' : 'feed.json';
  return http.Response.bytes(
    File('test/fixtures/$file').readAsBytesSync(),
    status,
  );
}

/// Un "server" fals: raspunde ca API-ul real, dar fara internet.
MockClient fakeServer({int status = 200}) =>
    MockClient((request) async => apiResponse(request, status: status));

/// Lantul complet din stratul Data, cu serverul fals in loc de internet.
CourseRepositoryImpl repositoryWith(http.Client client) =>
    CourseRepositoryImpl(CourseApi(client));
