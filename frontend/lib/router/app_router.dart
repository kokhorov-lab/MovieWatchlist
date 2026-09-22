import 'package:frontend/auth/auth_notifier.dart';
import 'package:frontend/model/movie_model.dart';
import 'package:frontend/screen/authScreen.dart';
import 'package:frontend/screen/movieScreen.dart';
import 'package:frontend/screen/movie_description.dart';
import 'package:go_router/go_router.dart';

final AuthNotifier authNotifier = AuthNotifier();

final GoRouter appRouter = GoRouter(
  initialLocation: '/movies',
  refreshListenable: authNotifier,

  //AuthGuard
  redirect: (context, state) {
    if (authNotifier.isLoading) return null;

    final isLoggedIn = authNotifier.isLoggedIn;
    final isLoggingIn = state.matchedLocation == '/login';

    // If not logged in and not on login page, redirect to /login
    if (!isLoggedIn && !isLoggingIn) return '/login';

    // If logged in and trying to go to /login, redirect to /movies
    if (isLoggedIn && isLoggingIn) return '/movies';

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => AuthScreen()),
    GoRoute(
      path: '/movies',
      builder: (context, state) => MovieListScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'details',
          builder: (context, state) {
            final movie = state.extra as Movie;
            return MovieDetailsScreen(movie: movie);
          },
        ),
      ],
    ),
  ],
);
