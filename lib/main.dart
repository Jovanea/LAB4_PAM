import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'data/datasources/course_api.dart';
import 'data/repositories/course_repository_impl.dart';
import 'domain/repositories/course_repository.dart';
import 'domain/usecases/get_home_feed.dart';
import 'presentation/cubit/home_cubit.dart';
import 'presentation/screens/home_screen.dart';

// Punctul de intrare in aplicatie.
// Aici se "leaga" straturile intre ele, de jos in sus:
//   http.Client -> CourseApi (Data) -> CourseRepositoryImpl (Data)
//   -> use case-uri (Domain) -> Cubit-uri (Presentation) -> ecrane
void main() {
  final CourseRepository repository = CourseRepositoryImpl(
    CourseApi(http.Client()),
  );
  runApp(OnlineCourseApp(repository: repository));
}

/// Configurarea generala a aplicatiei (tema, fontul, ecranul de start).
class OnlineCourseApp extends StatelessWidget {
  const OnlineCourseApp({super.key, required this.repository});

  /// Tipul este contractul abstract din Domain, nu implementarea HTTP:
  /// testele pot pune aici un repository fals, fara internet.
  final CourseRepository repository;

  @override
  Widget build(BuildContext context) {
    // RepositoryProvider face repository-ul accesibil oricarui ecran
    // (ecranul Home il ia de aici cand deschide Course Overview).
    return RepositoryProvider<CourseRepository>.value(
      value: repository,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Online Course App',
        theme: ThemeData(
          useMaterial3: true,
          // Fontul din design-ul Figma
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5CFF)),
        ),
        // Cubit-ul paginii principale porneste imediat cererea `GET /feed`
        home: BlocProvider(
          create: (_) => HomeCubit(GetHomeFeed(repository))..load(),
          child: const HomeScreen(),
        ),
      ),
    );
  }
}
