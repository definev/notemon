import 'package:gottask/repository/auth/auth_services.dart';
import 'package:gottask/repository/firebase/firebase_repository.dart';
import 'package:gottask/repository/firestore/firestore_repository.dart';

class FirebaseApi {
  FirebaseRepository firebase = FirebaseRepository();
  FirestoreRepository firestore = FirestoreRepository();
  AuthServices authServices = AuthServices();
}
