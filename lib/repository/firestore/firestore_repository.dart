import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gottask/repository/firestore/firestore_methods.dart';

class FirestoreRepository {
  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  /// [Firestore] methods
  Future<String> uploadFile(File file, {@required FileType type}) =>
      _firestoreMethods.uploadFile(file, type: type);
}
