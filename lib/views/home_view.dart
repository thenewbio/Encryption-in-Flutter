import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:igodo/igodo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pass_man/main.dart';
import 'package:pass_man/providers/auth_provider.dart';
import 'package:pass_man/providers/firestore_provider.dart';
import 'package:pass_man/providers/user_provider.dart';
import 'package:pass_man/views/add_data.dart';
import 'package:encrypt/encrypt.dart' as keys;
import 'package:pass_man/views/encrypt.dart';
import 'package:pass_man/widgets/home_widget.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../model/user.dart' as model;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _file = im;
    });
    // print(i);
  }

  void postImage() async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      String encryptedWord = IgodoEncryption.encryptSymmetric(
        _userController.text,
        ENCRYPTION_KEY,
      );
      String encryptedPass = IgodoEncryption.encryptSymmetric(
        _passwordController.text,
        ENCRYPTION_KEY,
      );
      String res = await FireStoreMethod().addPost(
        encryptedWord,
        _file!,
        FirebaseAuth.instance.currentUser!.uid,
        encryptedPass,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      } else {
        showSnackBar(context, res);
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userController.dispose();
    _passwordController.dispose();
  }

  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await _userProvider.refreshUser();
  }

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('data')
      .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    Widget slideLeftBackground() {
      return Container(
        color: Colors.red,
        child: Align(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
              ),
              Text(
                " Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          alignment: Alignment.centerRight,
        ),
      );
    }

    Widget slideRightBackground() {
      return Container(
        color: Colors.green,
        child: Align(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 20,
              ),
              Icon(
                Icons.edit,
                color: Colors.white,
              ),
              Text(
                " Edit",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          alignment: Alignment.centerLeft,
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Pass Man'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  AuthProvider().logOut();
                },
                icon: const Icon(Icons.logout))
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final desc = snapshot.data!.docs[index].get('desc');
                    final pass = snapshot.data!.docs[index].get('userName');
                    String name =
                        IgodoEncryption.decryptSymmetric(desc, ENCRYPTION_KEY);
                    String pass1 =
                        IgodoEncryption.decryptSymmetric(pass, ENCRYPTION_KEY);
                    return Dismissible(
                      background: slideLeftBackground(),
                      secondaryBackground: slideRightBackground(),
                      key: Key(snapshot.data!.docs[index].get('postId')),
                      child: Card(
                        elevation: 10,
                        // color: Colors.teal[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  (snapshot.data!.docs[index].get('postUrl')))),
                          title: Text(name),
                          subtitle: Text(pass1),
                          trailing: IconButton(
                              onPressed: () {
                                FireStoreMethod().deletePost(
                                    snapshot.data!.docs[index].get("postId"));
                              },
                              icon: const Icon(Icons.delete)),
                        ),
                      ),
                    );
                  });
            }),
        //       children: snapshot.data!.docs.map((DocumentSnapshot document) {

        //     );
        //   },
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                      height: MediaQuery.of(context).size.height * .5,
                      child: Center(
                          child: StatefulBuilder(builder: (context, state) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Stack(
                                children: [
                                  _file != null
                                      ? CircleAvatar(
                                          radius: 64,
                                          backgroundImage: MemoryImage(_file!),
                                          // backgroundColor: Colors.red,
                                        )
                                      : const CircleAvatar(
                                          radius: 50,
                                          backgroundImage: NetworkImage(
                                              'https://i.stack.imgur.com/l60Hf.png'),
                                          backgroundColor: Colors.black,
                                        ),
                                  Positioned(
                                    bottom: -10,
                                    left: 65,
                                    child: IconButton(
                                      onPressed: selectImage,
                                      icon: const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.black38,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: TextField(
                                controller: _userController,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'username or email'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter password to Save'),
                              ),
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.redAccent)),
                                onPressed: () {
                                  isLoading = true;
                                  postImage();
                                },
                                child: const Text('Save'))
                          ],
                        );
                      })));
                });
          },
          child: const Icon(Icons.add_circle),
        ));
  }
}
