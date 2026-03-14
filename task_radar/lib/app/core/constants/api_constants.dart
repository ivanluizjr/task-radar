class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';

  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String currentUser = '/auth/me';

  static const String todos = '/todos';
  static String todoById(int id) => '/todos/$id';
  static const String addTodo = '/todos/add';
  static String todosByUser(int userId) => '/todos/user/$userId';

  static const String users = '/users';
  static String userById(int id) => '/users/$id';
  static const String searchUsers = '/users/search';
  static const String filterUsers = '/users/filter';

  static const String quotes = '/quotes';
  static const String randomQuote = '/quotes/random';
}
