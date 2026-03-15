import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_response_model.dart';
import 'auth_remote_datasource.dart';

class SupabaseAuthDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _toModel(response);
  }

  @override
  Future<AuthResponseModel> register(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return _toModel(response);
  }

  AuthResponseModel _toModel(AuthResponse response) {
    if (response.session == null || response.user == null) {
      throw Exception("Auth failed: Session or User is null");
    }

    return AuthResponseModel(
      userId: response.user!.id,
      token: response.session!.accessToken,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        response.session!.expiresAt! * 1000,
      ),
    );
  }
}
