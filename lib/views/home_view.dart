import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:igodo/igodo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pass_man/main.dart';
import 'package:pass_man/providers/auth_provider.dart';
import 'package:pass_man/providers/firestore_provider.dart';
import 'package:pass_man/providers/user_provider.dart';
import 'package:pass_man/widgets/home_widget.dart';
import 'package:pass_man/widgets/selectable.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/theme_provider.dart';

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
  bool ishidden = false;
  int dropdownValue = 0;
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());
    if (size == null) {
      // print('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
        adUnitId:
            Platform.isAndroid ? 'ca-app-pub-3940256099942544/6300978111' : '',
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (Ad ad) {
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        }, onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        }));
    return _anchoredAdaptiveAd!.load();
  }

  changeEye() {
    setState(() {
      ishidden = !ishidden;
    });
  }

  change(value) async {
    await DynamicTheme.of(context)!.setTheme(value);
    setState(() {
      dropdownValue = value;
    });
  }

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
        // ignore: use_build_context_synchronously
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      } else {
        // ignore: use_build_context_synchronously
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
    _anchoredAdaptiveAd!.dispose();
  }

  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
  }

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('data')
      .where("uid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    dropdownValue = DynamicTheme.of(context)!.themeId;
    Widget slideLeftBackground() {
      return Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
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
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      );
    }

    Widget slideRightBackground() {
      return Container(
        color: Colors.green,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const <Widget>[
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
                changeEye();
              },
              icon: ishidden
                  ? const Icon(Icons.visibility)
                  : const Icon(Icons.visibility_off),
            ),
            PopupMenuButton(
              onSelected: (value) {
                change(value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: AppThemes.lightRed, child: Text('Light mode')),
                const PopupMenuItem(
                    value: AppThemes.dark, child: Text('Dark mode'))
              ],
            ),
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
                  physics: const BouncingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final desc = snapshot.data!.docs[index].get('desc');
                    final pass = snapshot.data!.docs[index].get('userName');
                    String name =
                        IgodoEncryption.decryptSymmetric(desc, ENCRYPTION_KEY);
                    String pass1 =
                        IgodoEncryption.decryptSymmetric(pass, ENCRYPTION_KEY);
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Dismissible(
                              key: const Key(''),
                              background: slideRightBackground(),
                              secondaryBackground: slideLeftBackground(),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  final bool res = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text(
                                              "Are you sure you want to delete $name?"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              onPressed: () {
                                                FireStoreMethod().deletePost(
                                                    snapshot.data!.docs[index]
                                                        .get("postId"));
                                                setState(() {});
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                  return res;
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => HomeWidget(
                                            name: desc,
                                            desc: pass,
                                            img: snapshot.data!.docs[index]
                                                .get('postUrl'),
                                          )));
                                }
                              },
                              child: Card(
                                elevation: 10,
                                // color: Colors.teal[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                      backgroundImage: NetworkImage((snapshot
                                          .data!.docs[index]
                                          .get('postUrl')))),
                                  title: ishidden
                                      ? Selectable(
                                          name: name,
                                          align: TextAlign.center,
                                        )
                                      : Text(desc),
                                  subtitle: ishidden
                                      ? Selectable(
                                          name: pass1,
                                          align: TextAlign.start,
                                        )
                                      : Text(pass),
                                ),
                              )),
                          // ignore: unnecessary_null_comparison
                          if (_anchoredAdaptiveAd != null && _isLoaded)
                            Container(
                                color: Colors.green,
                                width:
                                    _anchoredAdaptiveAd!.size.width.toDouble(),
                                height:
                                    _anchoredAdaptiveAd!.size.height.toDouble(),
                                child: AdWidget(ad: _anchoredAdaptiveAd!)),
                        ],
                      ),
                    );
                  });
            }),
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
