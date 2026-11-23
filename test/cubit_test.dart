// Teste pentru Cubit-uri: starile Loading -> Loaded / Error.
// Lantul e cel real (Cubit -> use case -> repository -> API), doar
// serverul este fals, ca testele sa mearga fara internet.

import 'package:flutter_test/flutter_test.dart';
import 'package:lab_4_pam/domain/usecases/get_course_details.dart';
import 'package:lab_4_pam/domain/usecases/get_home_feed.dart';
import 'package:lab_4_pam/presentation/cubit/course_cubit.dart';
import 'package:lab_4_pam/presentation/cubit/home_cubit.dart';

import 'helpers/fake_server.dart';

void main() {
  test('HomeCubit: Loading, apoi Loaded cu datele serverului', () async {
    final cubit = HomeCubit(GetHomeFeed(repositoryWith(fakeServer())));
    expect(cubit.state, isA<HomeLoading>());

    await cubit.load();

    final state = cubit.state as HomeLoaded;
    expect(state.feed.greeting, 'Hi, Kristin');
    await cubit.close();
  });

  test('HomeCubit: Error cand serverul nu raspunde corect', () async {
    final cubit = HomeCubit(GetHomeFeed(repositoryWith(fakeServer(status: 503))));

    await cubit.load();

    expect(cubit.state, isA<HomeError>());
    expect((cubit.state as HomeError).message, contains('503'));
    await cubit.close();
  });

  test('CourseCubit: Loaded cu lectiile cursului', () async {
    final cubit = CourseCubit(GetCourseDetails(repositoryWith(fakeServer())));

    await cubit.load();

    final state = cubit.state as CourseLoaded;
    expect(state.course.lessons.first.title, 'Introduction to React');
    await cubit.close();
  });

  test('CourseCubit inchis inainte de raspuns nu arunca eroare', () async {
    final cubit = CourseCubit(GetCourseDetails(repositoryWith(fakeServer())));

    final Future<void> loading = cubit.load();
    await cubit.close(); // utilizatorul a iesit de pe ecran

    await expectLater(loading, completes);
  });
}
