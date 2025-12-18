/// Supabase Configuration
/// Project: Pakebun App
/// Created: December 15, 2025

class SupabaseConfig {
  // Project URL
  static const String supabaseUrl = 'https://yyigwhtjidkbvpedctwt.supabase.co';

  // Publishable (anon) Key - Safe to use in client apps
  static const String supabaseAnonKey =
      'sb_publishable_7xcNNZdWVLqKNO9XDnh45Q_StJCD7rQ';

  // Storage buckets
  static const String greenhouseImagesBucket = 'greenhouse-images';

  // Helper method to get public image URL
  static String getPublicImageUrl(String fileName) {
    return '$supabaseUrl/storage/v1/object/public/$greenhouseImagesBucket/$fileName';
  }
}
