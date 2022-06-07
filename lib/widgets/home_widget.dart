import 'package:flutter/material.dart';
import 'package:pass_man/providers/firestore_provider.dart';
import 'package:encrypt/encrypt.dart' as keys;
import 'package:pass_man/views/encrypt.dart';
import '../constants/colors.dart';

class HomeWidget extends StatefulWidget {
  final dynamic snap;
  const HomeWidget({Key? key, this.snap}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
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

  final key = keys.Key.fromSecureRandom(32);
  final iv = keys.IV.fromSecureRandom(16);

  decryptData() {
    final encrypter = keys.Encrypter(keys.AES(key));
    final encrypted =
        encrypter.decrypt(widget.snap['desc'], iv: iv) as keys.Encrypted;
    return encrypted;
  }

  @override
  void initState() {
    super.initState();
    decryptData();
  }

  @override
  Widget build(BuildContext context) {
    var plainText = EncryptData.decryptAES(widget.snap["desc"]);
    print(plainText);
    return Card(
      elevation: 10,
      // color: Colors.teal[400],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading:
            CircleAvatar(backgroundImage: NetworkImage(widget.snap["postUrl"])),
        title: Text(widget.snap['desc']),
        subtitle: Text(widget.snap["userName"]),
        trailing: IconButton(
            onPressed: () {
              deletePost(widget.snap["postId"]);
            },
            icon: const Icon(Icons.delete)),
      ),
    );
  }
}
