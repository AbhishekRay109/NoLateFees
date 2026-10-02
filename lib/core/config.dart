/// Build-time settings, passed with --dart-define (see README).
/// With no Supabase values the app runs fully offline with no account.
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  /// The project's publishable (formerly "anon") key. Safe to ship in the app.
  static const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get cloudEnabled => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}
