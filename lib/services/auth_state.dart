import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show ClientException;
import 'package:myportofolio_mobile/services/api_client.dart';

/// Holds the in-memory authentication token for the current session.
class AuthState extends ChangeNotifier {
  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  final ApiClient _apiClient;
  String? _token;
  Future<void>? _logoutRequest;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  Future<void> logout() async {
    final current = _token;
    if (current == null) return;
    await (_logoutRequest ??= _logout(current));
  }

  Future<void> _logout(String token) async {
    try {
      await _apiClient.logout(token: token);
    } on ApiException {
      // A rejected request still ends the local session.
    } on ClientException {
      // The local session can end even if the server is unreachable.
    } finally {
      _logoutRequest = null;
      _token = null;
      notifyListeners();
    }
  }
}
