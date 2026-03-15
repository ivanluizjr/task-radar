import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_radar/app/core/widgets/main_shell.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_radar/app/features/auth/presentation/pages/login_page.dart';
import 'package:task_radar/app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:task_radar/app/features/profile/presentation/pages/profile_page.dart';
import 'package:task_radar/app/features/splash/presentation/pages/splash_page.dart';
import 'package:task_radar/app/features/todos/presentation/pages/todo_detail_page.dart';
import 'package:task_radar/app/features/todos/presentation/pages/todo_form_page.dart';
import 'package:task_radar/app/features/todos/presentation/pages/todos_list_page.dart';
import 'package:task_radar/app/features/users/presentation/pages/user_todos_page.dart';
import 'package:task_radar/app/features/users/presentation/pages/users_list_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: _AuthNotifier(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnSplash = state.matchedLocation == '/splash';
      final isOnLogin = state.matchedLocation == '/login';

      if (authState is AuthInitial) {
        return isOnSplash ? null : '/splash';
      }

      if (authState is AuthUnauthenticated) {
        return isOnLogin ? null : '/login';
      }

      if (authState is AuthAuthenticated) {
        if (isOnSplash || isOnLogin) return '/dashboard';

        final isAdminRoute = state.matchedLocation.startsWith('/users');
        if (isAdminRoute && !authState.user.isAdmin) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/todos',
            builder: (context, state) => const TodosListPage(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersListPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/todos/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TodoDetailPage(todoId: id);
        },
      ),
      GoRoute(
        path: '/todos/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TodoFormPage(todoId: id);
        },
      ),
      GoRoute(
        path: '/users/:userId/todos',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final userId = int.parse(state.pathParameters['userId']!);
          final userName = state.uri.queryParameters['name'] ?? 'Usuário';
          final userImage = state.uri.queryParameters['image'];
          return UserTodosPage(
            userId: userId,
            userName: userName,
            userImage: userImage,
          );
        },
      ),
    ],
  );
}

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthBloc authBloc) {
    authBloc.stream.listen((_) => notifyListeners());
  }
}
