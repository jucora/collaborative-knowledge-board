import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized configuration flag to toggle between Fake Data and Real API (Supabase)
/// Change this to 'false' to use the real Supabase implementation globally.
const bool useFakeData = false;

/// Provider to access the global configuration
final configProvider = Provider<bool>((ref) => useFakeData);
