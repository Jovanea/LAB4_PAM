import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/home_feed.dart';
import '../../domain/failure.dart';
import '../../domain/usecases/get_home_feed.dart';

// ======================= STARILE ecranului Home =======================
// `sealed` = starea poate fi DOAR una dintre cele trei clase de mai jos,
// iar `switch` din ecran e obligat sa le trateze pe toate.

sealed class HomeState {
  const HomeState();
}

/// Datele se descarca (se arata scheletul paginii).
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Datele au venit de la server.
class HomeLoaded extends HomeState {
  const HomeLoaded(this.feed);

  final HomeFeed feed;
}

/// Ceva n-a mers (se arata mesajul si butonul "Try again").
class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;
}

// ======================= CUBIT-ul ecranului Home =======================

/// Leaga ecranul de cazul de utilizare [GetHomeFeed].
/// Ecranul cere `load()`, Cubit-ul emite pe rand Loading -> Loaded / Error.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getHomeFeed) : super(const HomeLoading());

  final GetHomeFeed _getHomeFeed;

  /// Incarca (sau reincarca, la "trage in jos") datele de pe server.
  Future<void> load() async {
    // La reincarcare pastram pe ecran datele vechi, nu scheletul
    if (state is! HomeLoaded) emit(const HomeLoading());

    try {
      final HomeFeed feed = await _getHomeFeed(); // operatie asincrona
      if (!isClosed) emit(HomeLoaded(feed));
    } on Failure catch (e) {
      if (!isClosed) emit(HomeError(e.message));
    }
  }
}
