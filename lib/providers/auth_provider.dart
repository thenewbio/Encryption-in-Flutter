import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pass_man/model/user.dart' as model;

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snapshot);
  }

  Future<String> signUp(
      {required String email,
      required String password,
      required String userName}) async {
    String res = "Some error Occured";
    try {
      _firebaseFirestore
          .collection('users')
          .where('user', isEqualTo: 'user')
          .get();
      if (email.isNotEmpty || password.isNotEmpty || userName.isNotEmpty) {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        model.User user = model.User(
          username: userName,
          uid: credential.user!.uid,
          email: email,
        );
        // adding user in our database
        await _firebaseFirestore
            .collection("users")
            .doc(credential.user!.uid)
            .set(user.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }
}
