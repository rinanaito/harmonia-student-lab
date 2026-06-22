import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;
import 'package:googleapis/drive/v3.dart' as drive;

class AuthService extends ChangeNotifier {
  static const scopes = [drive.DriveApi.driveReadonlyScope];

  final _signIn = GoogleSignIn.instance;

  GoogleSignInAccount? currentUser;
  String? errorMessage;
  bool initialized = false;
  String? accessToken = null;

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    await _signIn.initialize();

    _signIn.authenticationEvents.listen(_onAuthEvent, onError: _onAuthError);

    // Attempt silent restore on page load
    _signIn.attemptLightweightAuthentication();

    initialized = true;
    notifyListeners();
  }

  Future<void> _onAuthEvent(GoogleSignInAuthenticationEvent event) async {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      currentUser = event.user;
      errorMessage = null;

      // Immediately request Drive scope right after sign-in
      // Silent first — no popup if already granted before
      GoogleSignInClientAuthorization? auth = await currentUser!.authorizationClient.authorizationForScopes(scopes);

      // If not yet authorized, show the consent popup
      // NOTE: must be called from a user-gesture context.
      // On first sign-in this fires immediately after the GIS button tap,
      // so it's still within the gesture chain — popup will not be blocked.
      auth ??= await currentUser!.authorizationClient.authorizeScopes(scopes);

      accessToken = auth.accessToken;
    } else if (event is GoogleSignInAuthenticationEventSignOut) {
      currentUser = null;
      accessToken = null;
    }

    notifyListeners();
  }

  void _onAuthError(Object err) {
    if (err is GoogleSignInException && err.code == GoogleSignInExceptionCode.canceled) return;
    errorMessage = err.toString();
    notifyListeners();
  }

  // Only used on non-web platforms
  Future<void> signIn() async {
    try {
      await _signIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  Future<void> signOut() async {
    await _signIn.signOut();
    currentUser = null;
    accessToken = null;
    notifyListeners();
  }

  Future<String?> refreshAccessToken() async {
    if (currentUser == null) return null;

    GoogleSignInClientAuthorization? auth = await currentUser!.authorizationClient.authorizationForScopes(scopes);

    // Expired — need user gesture to re-authorize
    if (auth == null) {
      accessToken = null;
      notifyListeners();
      return null;
    }

    accessToken = auth.accessToken;
    notifyListeners();
    return accessToken;
  }
}
