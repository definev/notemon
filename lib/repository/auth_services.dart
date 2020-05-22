import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  ///
  /// Declare instance [firebase]
  ///

  // Firebase authentication
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Firestore
  Firestore _firestore = Firestore.instance;

  // Sign in with google
  GoogleSignIn _googleSignIn = GoogleSignIn();

  ///
  /// [sign in] and [sign out] method
  ///
  Future<FirebaseUser> get getUser => _firebaseAuth.currentUser();

  Stream<FirebaseUser> get user => _firebaseAuth.onAuthStateChanged;

  Future<FirebaseUser> anonLogin() async {
    AuthResult _authResult = await _firebaseAuth.signInAnonymously();
    FirebaseUser _user = _authResult.user;
    updateUserData(_user);
    return _user;
  }

  Future<FirebaseUser> googleSignIn() async {
    try {
      // Request for google sign in
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();

      // Check authentical account
      GoogleSignInAuthentication authentication =
          await googleSignInAccount.authentication;

      // Get credential for FirebaseAuth lib
      AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );

      // Result sign in
      AuthResult _authResult =
          await _firebaseAuth.signInWithCredential(credential);

      // Return current user
      FirebaseUser _user = _authResult.user;
      return _user;
    } catch (e) {
      print(e);
      throw Exception("Failed to connect with google :(");
    }
  }

  Future<void> updateUserData(FirebaseUser user) {
    // Save time when user sign in in to the app
    DocumentReference historyRef =
        _firestore.collection('history').document(user.uid);
    return historyRef.setData(
      {'uid': user.uid, 'lastActive': DateTime.now()},
      merge: true,
    );
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
