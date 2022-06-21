import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:igodo/igodo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pass_man/main.dart';
import 'package:pass_man/model/user.dart' as model;
import 'package:pass_man/providers/storage_provider.dart';
import 'package:pass_man/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';

class HomeWidget extends StatefulWidget {
  final String name;
  final String desc;
  final String img;
  const HomeWidget(
      {Key? key, required this.name, required this.desc, required this.img})
      : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  Uint8List? _file;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  _file != null
                      ? CircleAvatar(
                          radius: 70,
                          backgroundImage: MemoryImage(_file!),
                          backgroundColor: Colors.red,
                        )
                      : CircleAvatar(
                          radius: 70,
                          // backgroundImage: NetworkImage(widget.img),
                          backgroundColor: Colors.red,
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
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
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: widget.desc,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              TextField(
                controller: _passController,
                decoration: InputDecoration(
                    labelText: 'name',
                    hintText: widget.name,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: editPost, child: const Text('Update Post'))
            ],
          ),
        ),
      ),
    );
  }

  selectImage() {
    Uint8List img = pickImage(ImageSource.gallery);
    setState(() {
      _file = img;
    });
  }

  void editPost() async {
    String name =
        IgodoEncryption.encryptSymmetric(_descController.text, ENCRYPTION_KEY);
    String pass1 =
        IgodoEncryption.encryptSymmetric(_passController.text, ENCRYPTION_KEY);
    final model.User user =
        Provider.of<UserProvider>(context, listen: false).getUser;
    Map<String, dynamic> snap = {};
    if (_file != null) {
      String url = await StorageMethods().uploadImage('data', _file!, false);
      snap["postUrl"] = url;
    }
    snap['desc'] = name;
    snap['userName'] = pass1;
    FirebaseFirestore.instance
        .collection('data')
        .doc(user.uid)
        .update(snap)
        .then((value) {
      Navigator.of(context).pop();
    });
  }
}
