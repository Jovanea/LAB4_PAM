import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/course_details.dart';
import '../../domain/failure.dart';
import '../../domain/usecases/get_course_details.dart';

// =================== STARILE ecranului Course Overview ===================

sealed class CourseState {
  const CourseState();
}

class CourseLoading extends CourseState {
  const CourseLoading();
}

class CourseLoaded extends CourseState {
  const CourseLoaded(this.course);

  final CourseDetails course;
}

class CourseError extends CourseState {
  const CourseError(this.message);

  final String message;
}

// =================== CUBIT-ul ecranului Course Overview ===================

/// Leaga ecranul de detalii de cazul de utilizare [GetCourseDetails].
class CourseCubit extends Cubit<CourseState> {
  CourseCubit(this._getCourseDetails) : super(const CourseLoading());

  final GetCourseDetails _getCourseDetails;

  Future<void> load() async {
    emit(const CourseLoading());

    try {
      final CourseDetails course = await _getCourseDetails();
      // Utilizatorul poate iesi de pe ecran inainte sa vina raspunsul;
      // atunci Cubit-ul e deja inchis si nu mai are voie sa emita.
      if (!isClosed) emit(CourseLoaded(course));
    } on Failure catch (e) {
      if (!isClosed) emit(CourseError(e.message));
    }
  }
}
