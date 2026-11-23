// Teste pentru stratul Data: JSON <-> modele si tratarea erorilor.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab_4_pam/data/models/course_details_model.dart';
import 'package:lab_4_pam/data/models/home_feed_model.dart';
import 'package:lab_4_pam/domain/failure.dart';

import 'helpers/fake_server.dart';

void main() {
  group('Deserializare (JSON -> obiect)', () {
    test('feed-ul real de la /feed', () {
      final feed = HomeFeedModel.fromJson(
        jsonDecode(fixture('feed.json')) as Map<String, dynamic>,
      );

      expect(feed.greeting, 'Hi, Kristin');
      expect(feed.subtitle, 'Let’s start learning');
      expect(feed.learnedMinutes, 46);
      expect(feed.goalMinutes, 60);
      expect(feed.promoAction, 'Get Started');
      expect(feed.plan.map((p) => p.title), ['Packaging Design', 'Product Design']);
      expect(feed.plan.first.completed, 40);
      expect(feed.plan.first.total, 48);
      expect(feed.meetupTitle, 'Meetup');
    });

    test('detaliile reale de la /feed/details', () {
      final course = CourseDetailsModel.fromJson(
        jsonDecode(fixture('details.json')) as Map<String, dynamic>,
      );

      expect(course.screenTitle, 'Course Overview');
      expect(course.title, 'React Front To back');
      expect(course.rating, 4.9);
      expect(course.lessonCount, 7);
      expect(course.heroLabel, 'SPOKEN ENGLISH');
      expect(course.lessonsTab, 'Lessons');
      expect(course.lessons, hasLength(4));
      expect(course.lessons.last.locked, isTrue);
      expect(course.description, isEmpty);
      expect(course.priceLabel, 'Free');
      expect(course.enrollEnabled, isTrue);
    });

    test('JSON fara un camp obligatoriu arunca eroare', () {
      final Map<String, dynamic> json =
          jsonDecode(fixture('feed.json')) as Map<String, dynamic>;
      json.remove('header');

      expect(() => HomeFeedModel.fromJson(json), throwsA(isA<TypeError>()));
    });
  });

  group('Serializare (obiect -> JSON)', () {
    test('toJson + fromJson dau inapoi aceleasi date', () {
      final original = HomeFeedModel.fromJson(
        jsonDecode(fixture('feed.json')) as Map<String, dynamic>,
      );
      final String text = jsonEncode(original.toJson());
      final copy = HomeFeedModel.fromJson(jsonDecode(text) as Map<String, dynamic>);

      expect(copy.toJson(), original.toJson());
    });

    test('la fel pentru detaliile cursului', () {
      final original = CourseDetailsModel.fromJson(
        jsonDecode(fixture('details.json')) as Map<String, dynamic>,
      );
      final copy = CourseDetailsModel.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>,
      );

      expect(copy.toJson(), original.toJson());
    });
  });

  group('Repository: cererea HTTP si erorile', () {
    test('cere adresa corecta si intoarce datele', () async {
      Uri? asked;
      final client = MockClient((request) async {
        asked = request.url;
        return apiResponse(request);
      });

      final feed = await repositoryWith(client).getHomeFeed();

      expect(asked.toString(), 'https://test-api-jlbn.onrender.com/lab2026/v4/feed');
      expect(feed.greeting, 'Hi, Kristin');
    });

    test('serverul raspunde 500 -> Failure cu mesaj clar', () {
      expect(
        repositoryWith(fakeServer(status: 500)).getHomeFeed(),
        throwsA(isA<Failure>().having((f) => f.message, 'message', contains('500'))),
      );
    });

    test('fara internet -> Failure', () {
      final offline = MockClient((_) => throw http.ClientException('offline'));

      expect(
        repositoryWith(offline).getCourseDetails(),
        throwsA(isA<Failure>().having(
          (f) => f.message,
          'message',
          contains('No internet'),
        )),
      );
    });

    test('raspuns care nu e JSON -> Failure', () {
      final broken = MockClient((_) async => http.Response('<html>', 200));

      expect(repositoryWith(broken).getHomeFeed(), throwsA(isA<Failure>()));
    });
  });
}
