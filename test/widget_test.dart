// Teste pentru ecrane, cu serverul fals in loc de internet.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab_4_pam/main.dart';

import 'helpers/fake_server.dart';
import 'helpers/load_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  // Ecran de telefon (393 x 852, ca in design), nu 800 x 600 cat e implicit
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(393 * 3, 852 * 3);
    view.devicePixelRatio = 3;
  });
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset());

  testWidgets('Home arata datele din API si deschide Course Overview',
      (tester) async {
    await tester.pumpWidget(
      OnlineCourseApp(repository: repositoryWith(fakeServer())),
    );

    // Inainte de raspuns: scheletul paginii (starea Loading)
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);

    await tester.pumpAndSettle();

    // Datele de la GET /feed
    expect(find.text('Hi, Kristin'), findsOneWidget);
    expect(find.text('46min'), findsOneWidget);
    expect(find.text('Packaging Design'), findsOneWidget);
    expect(find.text('Meetup'), findsOneWidget);

    // Navigarea spre ecranul 2, care face cererea GET /feed/details
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Course Overview'), findsOneWidget);
    expect(find.text('React Front To back'), findsOneWidget);
    expect(find.text('Introduction to React'), findsOneWidget);
    expect(find.text('Enroll Now'), findsOneWidget);

    // Descrierea goala din API are un mesaj, nu un spatiu gol
    await tester.tap(find.text('Description'));
    await tester.pumpAndSettle();
    expect(find.text('No description for this course yet.'), findsOneWidget);
  });

  testWidgets('Eroare de retea: mesaj + "Try again" care reincearca',
      (tester) async {
    int calls = 0;
    final server = MockClient((request) async {
      calls++;
      // Prima cerere pica, a doua merge
      if (calls == 1) throw http.ClientException('offline');
      return apiResponse(request);
    });

    await tester.pumpWidget(OnlineCourseApp(repository: repositoryWith(server)));
    await tester.pumpAndSettle();

    expect(find.text('Couldn\'t load the page'), findsOneWidget);
    expect(find.textContaining('No internet'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Kristin'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('Pe un ecran ingust pagina nu iese din chenar', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      OnlineCourseApp(repository: repositoryWith(fakeServer())),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
