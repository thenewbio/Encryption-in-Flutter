import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String desc;
  final String uid;
  final String userName;
  final String postId;
  final DateTime dateTime;
  final String postUrl;

  Post(
      {required this.desc,
      required this.uid,
      required this.userName,
      required this.postId,
      required this.dateTime,
      required this.postUrl});

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
        desc: snapshot["desc"],
        uid: snapshot["uid"],
        userName: snapshot["userName"],
        postId: snapshot["postId"],
        dateTime: snapshot["dateTime"],
        postUrl: snapshot["postUrl"]);
  }

  Map<String, dynamic> toJson() => {
        "desc": desc,
        "uid": uid,
        "userName": userName,
        "postId": postId,
        "dateTime": dateTime,
        "postUrl": postUrl
      };
}
