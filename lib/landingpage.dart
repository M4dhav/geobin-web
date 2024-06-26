import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geobin/collections.dart';
import 'package:geobin/homepage.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:geobin/nav.dart';
import 'package:geobin/profilepage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LandingPage extends StatefulWidget {
  LandingPage({super.key});

  String? error;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      // TODO
      print('exception->$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    return SafeArea(
        child: Stack(children: [
      Container(
        color: Color(0xffd6f1cf),
        height: double.infinity,
        width: double.infinity,
      ),
      Image.asset(
        "assets/images/bg.jpg",
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                SizedBox(
                  height: Get.height * 0.0715102975,
                ),
                Column(
                  children: [
                    Center(
                      child: Text(
                        "Welcome to",
                        style: GoogleFonts.averiaGruesaLibre(
                            fontSize: 45, color: Colors.white),
                      ),
                    ),
                    Center(
                      child: Text(
                        "GeoBin",
                        style: GoogleFonts.cutive(
                            fontSize: 60, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                // 1536*699.2
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: Get.width * 0.6510416667,
                        child: TextField(
                          cursorColor: Colors.white,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                            ),
                            iconColor: Colors.white,
                            focusColor: Colors.white,
                            hoverColor: Colors.white,
                            suffixIconColor: Colors.white,
                            hintText: 'Enter Email Address',
                            suffixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: Get.width * 0.6510416667,
                        child: TextField(
                          cursorColor: Colors.white,
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                            ),
                            iconColor: Colors.white,
                            focusColor: Colors.white,
                            hoverColor: Colors.white,
                            suffixIconColor: Colors.white,
                            hintText: 'Enter Password',
                            suffixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final credential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => navBar()));
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            print('No user found for that email.');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("User Not Found! Please Sign Up!"),
                            ));
                            widget.error = "User Not Found! Please Sign Up!";
                          } else if (e.code == 'wrong-password') {
                            print('Wrong password provided for that user.');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("Wrong Password! Please Try Again!"),
                            ));
                            widget.error = "Wrong Password! Please Try Again!";
                          } else if (e.code == 'invalid-credential') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Please Login using Google!"),
                            ));
                            widget.error = "Please Login using Google!";
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Error! Please Try Again!"),
                            ));
                            widget.error = "Error! Please Try Again!";
                          }
                          setState(() {});
                        }
                      },
                      child: Image.asset(
                        "assets/images/login.png",
                        width: MediaQuery.of(context).size.width * 0.3,
                        fit: BoxFit.cover,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final credential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text);
                          User user = FirebaseAuth.instance.currentUser!;
                          print(user.displayName);
                          var doc =
                              await FBCollections.users.doc(user.uid).get();
                          if (doc.data() == null) {
                            var data = {
                              "name": user.displayName,
                              "email": user.email,
                              "pic": user.photoURL,
                              "uid": user.uid,
                              "posts": []
                            };
                            await FBCollections.users.doc(user.uid).set(data);
                          }
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => navBar()));
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'email-already-in-use') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text("User Already Exists! Please Login!"),
                            ));
                            widget.error = "User Already Exists! Please Login!";
                            setState(() {});
                            print(e.toString());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Error! Please Try Again!"),
                            ));
                            widget.error = "Error! Please Try Again!";
                            setState(() {});
                            print(e.toString());
                          }
                        }
                      },
                      child: Image.asset(
                        "assets/images/signup.png",
                        width: MediaQuery.of(context).size.width * 0.3,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.error ?? "",
                      style: GoogleFonts.averiaGruesaLibre(
                          fontSize: 25, color: Colors.red),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Row(children: <Widget>[
                          Expanded(
                              child: Divider(
                            thickness: 2,
                            color: Color(0xffd6f1cf),
                          )),
                          Text(
                            "OR",
                            style: GoogleFonts.averiaGruesaLibre(
                                fontSize: 20, color: Colors.white),
                          ),
                          Expanded(
                              child: Divider(
                            thickness: 2,
                            color: Color(0xffd6f1cf),
                          )),
                        ])),
                    SizedBox(
                      height: 20,
                    ),
                    GoogleAuthButton(
                      onPressed: () async {
                        try {
                          await signInWithGoogle();
                          User user = FirebaseAuth.instance.currentUser!;
                          print(user.displayName);
                          var doc =
                              await FBCollections.users.doc(user.uid).get();
                          if (doc.data() == null) {
                            var data = {
                              "name": user.displayName,
                              "email": user.email,
                              "pic": user.photoURL,
                              "uid": user.uid,
                              "posts": []
                            };
                            await FBCollections.users.doc(user.uid).set(data);
                          }
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => navBar(
                                        selectedIndex: 0,
                                      )));
                        } catch (e) {
                          print('exception->$e');
                        }
                      },
                      style: AuthButtonStyle(
                        buttonType: AuthButtonType.icon,
                      ),
                    ),
                  ],
                )
              ])),
        ),
      ),
    ]));
  }
}
//206 bla 1:30 - 3:30