import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as sign_in;

class LogInWithGoogleFailure implements Exception {
  const LogInWithGoogleFailure(
      [this.message = 'An unknown exception occurred.']);

  /// The associated error message.
  final String message;
}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

typedef User = sign_in.GoogleSignInAccount;

class AuthenticationRepository {
  AuthenticationRepository()
      : _googleSignIn = sign_in.GoogleSignIn.standard(
            scopes: [drive.DriveApi.driveAppdataScope]);
  final sign_in.GoogleSignIn _googleSignIn;

  sign_in.GoogleSignIn get googleSignIn => _googleSignIn;

  Future<void> loginWithGoogleSliently() async {
    try {
      await _googleSignIn.signInSilently();
      // if (account == null) {
      //   throw const LogInWithGoogleFailure('No valid google account');
      // }
    } catch (_) {
      // throw const LogInWithGoogleFailure();
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final sign_in.GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        throw const LogInWithGoogleFailure('No valid google account');
      }
    } catch (e) {
      throw LogInWithGoogleFailure(e.toString());
    }
  }

  sign_in.GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Stream<sign_in.GoogleSignInAccount?> get user =>
      _googleSignIn.onCurrentUserChanged;

  /// Signs out the current user which will emit
  /// [null] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await Future.wait([
        // _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }
}
