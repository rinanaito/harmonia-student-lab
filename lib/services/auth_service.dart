import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class AuthService extends ChangeNotifier {
  static const scopes = [drive.DriveApi.driveReadonlyScope];

  final _signIn = GoogleSignIn.instance;

  GoogleSignInAccount? currentUser;
  String? errorMessage;
  bool initialized = false;
  var token = "";

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _signIn.initialize(
        // On web, clientId is read from the <meta> tag, but you can also
        // pass it explicitly here as a fallback:
        // clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com',
      );

      _signIn.authenticationEvents.listen(_onSignIn).onError(_onSignInError);

      // Attempt silent restore — on web this may show a floating card
      _signIn.attemptLightweightAuthentication();

      initialized = true;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _onSignIn(GoogleSignInAuthenticationEvent event) {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      currentUser = event.user;
      errorMessage = null;
    } else if (event is GoogleSignInAuthenticationEventSignOut) {
      currentUser = null;
      token = "";
    }
    notifyListeners();
  }

  void _onSignInError(Object error) {
    if (error is GoogleSignInException && error.code == GoogleSignInExceptionCode.canceled) {
      return; // user dismissed — not an error
    }

    token = "";
    errorMessage = error.toString();
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
    token = "";
    notifyListeners();
  }

  /// Returns a valid access token for Drive scopes, requesting auth if needed.
  /// Must be called from a user gesture on platforms where
  /// authorizationRequiresUserInteraction() == true (which includes web).
  Future<String?> getAccessToken() async {
    final user = currentUser;
    if (user == null) return null;
    if (token.isEmpty) {
      // Silent first — no popup if already authorized
      GoogleSignInClientAuthorization? auth = await user.authorizationClient.authorizationForScopes(scopes);

      // Only show the consent popup if silent failed
      auth ??= await user.authorizationClient.authorizeScopes(scopes);
      token = auth.accessToken;
    }
    return token;
  }
}
