import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FirestoreMethods {
  Future<String> uploadImageFile(
    FirebaseUser user,
    File imageFile,
    Map<String, String> fileInfo,
  ) async {
    final StorageReference ref = FirebaseStorage.instance.ref().child(
        '${user.uid}/todos/images/${fileInfo["name"]}.${fileInfo["format"]}');

    final StorageUploadTask uploadTask = ref.putFile(imageFile);

    try {
      var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
      return dowurl.toString();
    } catch (e) {
      return null;
    }
  }

  Future<void> uploadAudioFile(FirebaseUser user, File audioFile) async {
    final StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('${user.uid}/')
        .child('/todos')
        .child('/audio');

    final StorageUploadTask uploadTask = ref.putFile(audioFile);

    dynamic res;

    await uploadTask.onComplete.then((value) {
      res = value.ref.getDownloadURL();
      print(res);
    });
    // return res;
  }

  Future<void> downloadAudioFile(
    StorageReference ref,
    String fileName,
  ) async {
    final String url = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(url);
    Directory appDocDirectory;
    if (Platform.isIOS) {
      appDocDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDocDirectory = await getExternalStorageDirectory();
    }
    final File tempFile = File('${appDocDirectory.path}/$fileName');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    assert(await tempFile.readAsString() == "");
    final String tempFileContents = await tempFile.readAsString();

    final String fileContents = downloadData.body;
    final String name = await ref.getName();
    final String bucket = await ref.getBucket();
    final String path = await ref.getPath();
    print('Success!\n Downloaded $name \n from url: $url @ bucket: $bucket\n '
        'at path: $path \n\nFile contents: "$fileContents" \n'
        'Wrote "$tempFileContents" to tmp.txt');
  }
}
