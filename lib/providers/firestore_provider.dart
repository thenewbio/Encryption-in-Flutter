import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pass_man/model/post.dart';
import 'package:pass_man/providers/storage_provider.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addPost(
      String desc, Uint8List file, String uid, String pass) async {
    String res = "Some error Ocurred";

    try {
      String imageUrl = await StorageMethods().uploadImage('data', file, true);
      String postId = const Uuid().v1();
      Post post = Post(
          desc: desc,
          uid: uid,
          userName: pass,
          postId: postId,
          dateTime: DateTime.now(),
          postUrl: imageUrl);
      _firestore.collection('data').doc(postId).set(post.toJson());
      res = "Success";
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  Future<String> deletePost(String postId) async {
    String res = "Some error Occurred";
    try {
      await _firestore.collection('data').doc(postId).delete();
    } catch (e) {
      return e.toString();
    }
    return res;
  }
}
