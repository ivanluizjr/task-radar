import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/core/di/injection_container.dart';
import 'package:task_radar/app/core/routes/app_router.dart';
import 'package:task_radar/app/core/theme/app_theme.dart';
import 'package:task_radar/app/core/theme/theme_cubit.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/users/presentation/bloc/users_bloc.dart';

class TaskRadarApp extends StatelessWidget {
  const TaskRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = sl<AuthBloc>();
    final router = createRouter(authBloc);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
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
            routerConfig: router,
          );
        },
      ),
    );
  }
}
