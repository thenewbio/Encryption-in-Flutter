import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pass_man/model/user.dart' as model;
import 'package:pass_man/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../providers/firestore_provider.dart';

class PostCard extends StatefulWidget {
  final dynamic snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLoading = false;

  var userData = {};

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      // get post lENGTH
      var userSnap = await FirebaseFirestore.instance
          .collection('data')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethod().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
        // boundary needed for web
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: mobileBackgroundColor,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Card(
          elevation: 10,
          // color: Colors.teal[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.snap['postUrl'])),
            title: Text(widget.snap['userName']),
            subtitle: Text(widget.snap['desc']),
            // trailing: IconButton(
            //   onPressed: () {
            //     changeEye();
            //   },
            //   icon: ishidden
            //       ? const Icon(Icons.visibility)
            //       : const Icon(Icons.visibility_off),
            // ),
          ),
        ));
  }
}
