import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

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
    if (!kIsWeb) {
      try {
        final result = await InternetAddress.lookup('google.com');
        FirebaseUser _user;

        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          try {
            // Request for google sign in
            _googleSignIn.signIn().then(
              (value) async {
                // Check authentical account
                GoogleSignInAuthentication authentication =
                    await value.authentication;

                // Get credential for FirebaseAuth lib
                AuthCredential credential = GoogleAuthProvider.getCredential(
                  idToken: authentication.idToken,
                  accessToken: authentication.accessToken,
                );

                // Result sign in
                AuthResult _authResult =
                    await _firebaseAuth.signInWithCredential(credential);

                // Return current user
                updateUserData(_user);
                _user = _authResult.user;
                return value;
              },
              onError: () {
                _user = null;
                return null;
              },
            );
            return _user;
          } catch (e) {
            print(e);
            return null;
          }
        } else {
          return null;
        }
      } on SocketException catch (_) {
        return null;
      }
    } else {
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
        updateUserData(_user);
        return _user;
      } catch (e) {
        print(e);
        return null;
      }
    }
  }

  Future<void> updateUserData(FirebaseUser user) async {
    // Save time when user sign in in to the app
    await _firestore.collection('users').document(user.uid).setData(
      {
        'uid': user.uid,
        'email': user.email,
        'photoUrl': user.photoUrl,
      },
      merge: true,
    );
    await _firestore.collection('history').document(user.uid).setData(
      {
        'uid': user.uid,
        'lastActive': DateTime.now(),
      },
      merge: true,
    );
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
