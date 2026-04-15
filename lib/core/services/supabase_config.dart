class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_SUPABASE_PROJECT_REF.supabase.co',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static bool get isConfigured =>
      !url.contains('YOUR_SUPABASE_PROJECT_REF') &&
      !anonKey.contains('YOUR_SUPABASE_ANON_KEY') &&
      url.isNotEmpty &&
      anonKey.isNotEmpty;
}
