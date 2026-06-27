import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:bagdja_wallet/core/network/api_client.dart';
import 'package:bagdja_wallet/features/auth/models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthRepository {
  static const String clientId = 'wallet-app';
  static const String redirectUrl = 'com.bagdja.wallet:/oauthredirect';
  static const String logoutCallbackUrl = 'com.bagdja.wallet:/logout-callback';
  static const String authorizationEndpoint =
      'https://login.bagdja.com/oauth/authorize';
  static const String tokenEndpoint = 'https://auth.bagdja.com/oauth/token';
  static const String logoutEndpoint = 'https://login.bagdja.com/logout';

  static const _verifierKey = 'oauth_code_verifier';
  static const _stateKey = 'oauth_state';
  static const _forceReauthKey = 'force_reauth';

  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSubscription;
  Completer<UserModel>? _loginCompleter;
  Completer<void>? _logoutCompleter;
  bool _isProcessingCallback = false;

  AuthRepository({required this.apiClient});

  Future<void> initDeepLinks() async {
    await _linkSubscription?.cancel();
    _linkSubscription = _appLinks.uriLinkStream.listen(_handleIncomingLink);

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _handleIncomingLink(initialUri);
    }
  }

  Future<void> disposeDeepLinks() async {
    await _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  Future<UserModel> login() async {
    if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
      throw Exception('Login sedang berlangsung');
    }

    _loginCompleter = Completer<UserModel>();

    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);
    final state = _generateCodeVerifier();

    await secureStorage.write(key: _verifierKey, value: codeVerifier);
    await secureStorage.write(key: _stateKey, value: state);

    final queryParams = {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUrl,
      'state': state,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'scope': 'openid profile email',
    };

    final authUri = Uri.parse(authorizationEndpoint).replace(
      queryParameters: queryParams,
    );

    final launched = await launchUrl(
      authUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      await _clearOAuthSession();
      _loginCompleter = null;
      throw Exception('Tidak bisa membuka browser untuk login');
    }

    try {
      return await _loginCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw TimeoutException('Login timeout. Silakan coba lagi.');
        },
      );
    } on TimeoutException {
      await _clearOAuthSession();
      rethrow;
    } finally {
      if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
        _loginCompleter = null;
      }
    }
  }

  Future<void> logout() async {
    if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
      _loginCompleter!.completeError(StateError('Logout'));
    }
    _loginCompleter = null;
    _isProcessingCallback = false;

    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
    await _clearOAuthSession();
    await secureStorage.write(key: _forceReauthKey, value: 'true');

    _logoutCompleter = Completer<void>();

    final logoutUri = Uri.parse(logoutEndpoint).replace(
      queryParameters: {
        'redirect_uri': logoutCallbackUrl,
      },
    );

    final launched = await launchUrl(
      logoutUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      _logoutCompleter = null;
      return;
    }

    try {
      await _logoutCompleter!.future.timeout(const Duration(seconds: 15));
    } on TimeoutException {
      // Endpoint belum deploy atau user menutup browser — logout lokal tetap aktif.
    } finally {
      _logoutCompleter = null;
    }
  }

  Future<void> _handleIncomingLink(Uri uri) async {
    if (_isLogoutCallback(uri)) {
      _logoutCompleter?.complete();
      return;
    }

    if (_isOAuthCallback(uri)) {
      await _handleOAuthCallback(uri);
    }
  }

  Future<void> _handleOAuthCallback(Uri uri) async {
    if (_isProcessingCallback) {
      return;
    }

    _isProcessingCallback = true;
    try {
      final user = await _completeOAuth(uri);
      if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
        _loginCompleter!.complete(user);
      }
    } catch (e) {
      if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
        _loginCompleter!.completeError(e);
      }
    } finally {
      _isProcessingCallback = false;
      _loginCompleter = null;
    }
  }

  Future<UserModel> _completeOAuth(Uri uri) async {
    final error = uri.queryParameters['error'];
    if (error != null) {
      await _clearOAuthSession();
      throw Exception(
        uri.queryParameters['error_description'] ?? error,
      );
    }

    final code = uri.queryParameters['code'];
    final returnedState = uri.queryParameters['state'];

    if (code == null || returnedState == null) {
      throw Exception('Callback OAuth tidak valid');
    }

    final savedState = await secureStorage.read(key: _stateKey);
    final codeVerifier = await secureStorage.read(key: _verifierKey);

    if (savedState == null || codeVerifier == null) {
      if (await isLoggedIn()) {
        final token = await getAccessToken();
        if (token != null) {
          return UserModel.fromToken(token);
        }
      }
      throw Exception('Sesi login tidak ditemukan. Silakan login ulang.');
    }

    if (savedState != returnedState) {
      await _clearOAuthSession();
      throw Exception('State OAuth tidak cocok');
    }

    await _clearOAuthSession();

    final tokenResponse = await Dio().post<Map<String, dynamic>>(
      tokenEndpoint,
      data: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUrl,
        'client_id': clientId,
        'code_verifier': codeVerifier,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.json,
      ),
    );

    final data = tokenResponse.data;
    final accessToken = data?['access_token'] as String?;

    if (accessToken == null) {
      throw Exception('Token tidak diterima dari server');
    }

    await secureStorage.write(key: 'access_token', value: accessToken);

    final refreshToken = data?['refresh_token'] as String?;
    if (refreshToken != null) {
      await secureStorage.write(key: 'refresh_token', value: refreshToken);
    }

    await secureStorage.delete(key: _forceReauthKey);

    // Buat UserModel dari token JWT
    final user = UserModel.fromToken(accessToken);
    
    // Simpan data user ke secure storage
    await secureStorage.write(key: 'user_data', value: user.toJson().toString());

    return user;
  }

  Future<bool> isLoggedIn() async {
    final token = await secureStorage.read(key: 'access_token');
    return token != null;
  }

  Future<String?> getAccessToken() async {
    return secureStorage.read(key: 'access_token');
  }

  Future<void> _clearOAuthSession() async {
    await secureStorage.delete(key: _verifierKey);
    await secureStorage.delete(key: _stateKey);
  }

  bool _isOAuthCallback(Uri uri) {
    return uri.scheme == 'com.bagdja.wallet' &&
        uri.queryParameters.containsKey('code');
  }

  bool _isLogoutCallback(Uri uri) {
    if (uri.scheme != 'com.bagdja.wallet') {
      return false;
    }

    return uri.path == '/logout-callback' ||
        uri.host == 'logout-callback' ||
        uri.path.startsWith('/logout-callback');
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}
