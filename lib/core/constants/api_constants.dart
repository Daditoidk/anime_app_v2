class ApiConstants {
  static const String baseUrl = 'https://kitsu.io/api/edge';
  static const Duration timeout = Duration(seconds: 30);
  static const int pageSize = 20;

  static const String getAnimeUrl = '/anime';

  static const String requestCancelledMessage = 'Request cancelled';
}

class KeyConstants {
  static const String animeSearchTextField = 'animeSearchTextField';
  static const String searchButton = 'searchButton';
  static const String clearButton = 'clearButton';
  static const String backButton = 'backButton';
}
