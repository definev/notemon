import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gottask/utils/utils.dart';

enum FileType { image, audio }

class FirestoreMethods {
  Future<String> uploadFile(
    File file, {
    @required FileType type,
  }) async {
    final String _imagePath =
        '${type == FileType.image ? "images" : "audio"}/${file.name}';
    print('image path: $_imagePath');
    final StorageReference _ref =
        FirebaseStorage.instance.ref().child(_imagePath);
    final StorageUploadTask uploadTask = _ref.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    print('URL is $url');

    return '$url';
  }

  Future<void> deleteFile(String downloadUrl) async {
    String filePath = downloadUrl
        .replaceAll(
            RegExp(
                r'https://firebasestorage.googleapis.com/v0/b/dial-in-21c50.appspot.com/o/default_images%2F'),
            '')
        .split('?')[0];

    await FirebaseStorage.instance.ref().child(filePath).delete();
  }
}
