import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_radar/app/core/database/app_database.dart';
import 'package:task_radar/app/core/network/api_client.dart';
import 'package:task_radar/app/core/network/network_info.dart';
import 'package:task_radar/app/core/theme/theme_cubit.dart';
import 'package:task_radar/app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:task_radar/app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:task_radar/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:task_radar/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:task_radar/app/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:task_radar/app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:task_radar/app/features/auth/domain/usecases/login_usecase.dart';
import 'package:task_radar/app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:task_radar/app/features/quotes/data/datasources/quote_remote_datasource.dart';
import 'package:task_radar/app/features/quotes/data/repositories/quote_repository_impl.dart';
import 'package:task_radar/app/features/quotes/domain/repositories/quote_repository.dart';
import 'package:task_radar/app/features/quotes/domain/usecases/get_random_quote_usecase.dart';
import 'package:task_radar/app/features/todos/data/datasources/todo_local_datasource.dart';
import 'package:task_radar/app/features/todos/data/datasources/todo_remote_datasource.dart';
import 'package:task_radar/app/features/todos/data/repositories/todo_repository_impl.dart';
import 'package:task_radar/app/features/todos/domain/repositories/todo_repository.dart';
import 'package:task_radar/app/features/todos/domain/usecases/create_todo_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/delete_todo_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/get_todo_summary_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/get_todos_by_user_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/get_todos_usecase.dart';
import 'package:task_radar/app/features/todos/domain/usecases/update_todo_usecase.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/users/data/datasources/user_local_datasource.dart';
import 'package:task_radar/app/features/users/data/datasources/user_remote_datasource.dart';
import 'package:task_radar/app/features/users/data/repositories/user_repository_impl.dart';
import 'package:task_radar/app/features/users/domain/repositories/user_repository.dart';
import 'package:task_radar/app/features/users/domain/usecases/get_users_usecase.dart';
import 'package:task_radar/app/features/users/presentation/bloc/users_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  await _initExternal();
  await _initCore();
  _initDataSources();
  _initRepositories();
  _initUseCases();
  _initBlocs();
}

Future<void> _initExternal() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  sl.registerSingleton<Connectivity>(Connectivity());

  final database = await AppDatabase.database;
  sl.registerSingleton(database);
}

Future<void> _initCore() async {
  sl.registerSingleton<ApiClient>(ApiClient(sl<FlutterSecureStorage>()));
  sl.registerSingleton<NetworkInfo>(NetworkInfoImpl(sl<Connectivity>()));
  sl.registerSingleton<ThemeCubit>(ThemeCubit(sl<SharedPreferences>()));
}

void _initDataSources() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<QuoteRemoteDataSource>(
    () => QuoteRemoteDataSourceImpl(sl<ApiClient>()),
  );
}

void _initRepositories() {
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<AuthLocalDataSource>(),
      sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(
      sl<TodoRemoteDataSource>(),
      sl<TodoLocalDataSource>(),
      sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      sl<UserRemoteDataSource>(),
      sl<UserLocalDataSource>(),
      sl<NetworkInfo>(),
    ),
  );
  sl.registerLazySingleton<QuoteRepository>(
    () => QuoteRepositoryImpl(sl<QuoteRemoteDataSource>()),
  );
}

void _initUseCases() {
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));

  sl.registerLazySingleton(() => GetTodosUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => GetTodosByUserUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => CreateTodoUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => UpdateTodoUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => DeleteTodoUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => GetTodoSummaryUseCase(sl<TodoRepository>()));

  sl.registerLazySingleton(() => GetUsersUseCase(sl<UserRepository>()));

  sl.registerLazySingleton(() => GetRandomQuoteUseCase(sl<QuoteRepository>()));
}

void _initBlocs() {
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      checkAuthUseCase: sl<CheckAuthUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );
  sl.registerFactory(
    () => TodosBloc(
      getTodosUseCase: sl<GetTodosUseCase>(),
      getTodosByUserUseCase: sl<GetTodosByUserUseCase>(),
      createTodoUseCase: sl<CreateTodoUseCase>(),
      updateTodoUseCase: sl<UpdateTodoUseCase>(),
      deleteTodoUseCase: sl<DeleteTodoUseCase>(),
    ),
  );
  sl.registerFactory(() => UsersBloc(getUsersUseCase: sl<GetUsersUseCase>()));
  sl.registerFactory(
    () => DashboardCubit(
      getTodoSummaryUseCase: sl<GetTodoSummaryUseCase>(),
      getRandomQuoteUseCase: sl<GetRandomQuoteUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );
}
