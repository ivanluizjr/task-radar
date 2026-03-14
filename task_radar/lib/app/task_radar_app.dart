import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_radar/app/core/di/injection_container.dart';
import 'package:task_radar/app/core/routes/app_router.dart';
import 'package:task_radar/app/core/theme/app_theme.dart';
import 'package:task_radar/app/core/theme/theme_cubit.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/users/presentation/bloc/users_bloc.dart';

class TaskRadarApp extends StatefulWidget {
  const TaskRadarApp({super.key});

  @override
  State<TaskRadarApp> createState() => _TaskRadarAppState();
}

class _TaskRadarAppState extends State<TaskRadarApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _router = createRouter(_authBloc);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ThemeCubit>.value(value: sl<ThemeCubit>()),
        BlocProvider<TodosBloc>(create: (_) => sl<TodosBloc>()),
        BlocProvider<UsersBloc>(create: (_) => sl<UsersBloc>()),
        BlocProvider<DashboardCubit>(create: (_) => sl<DashboardCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Task Radar',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
