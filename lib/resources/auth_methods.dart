import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';
import 'package:instagram_flutter/models/user.dart' as model;

class AuthMethods {
  // get user details
  static Future<model.User> getUserDetails() async {
    User currentUser = FirebaseAuth.instance.currentUser!;

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    return model.User.fromSnap(documentSnapshot);
  }

  // Sign up user
  static Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        // register user
        UserCredential cred =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String photoUrl = await StorageMethods.uploadImageToStorage(
          childName: "profilePics",
          file: file,
          isPost: false,
        );

        // Add user to database
        await FirebaseFirestore.instance
            .collection("users")
            .doc(cred.user!.uid)
            .set({
          "username": username,
          "uid": cred.user!.uid,
          "email": email,
          "bio": bio,
          "followers": [],
          "following": [],
          "photoUrl": photoUrl,
        });
        res = "success";
      } else {
        res = "Please fill all the fields";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        res = "The email is badly formatted";
      } else if (e.code == "email-already-in-use") {
        res = "This email is already registered";
      } else {
        res = "Authentication error!";
      }
    } catch (e) {
      res = "Some other error!";
    }
    return res;
  }

  static Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        res = "success";
      } else {
        res = "Please fill all the fields";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        res = "The email is badly formatted";
      } else if (e.code == "user-not-found" || e.code == "wrong-password") {
        res = "Incorrect credentials";
      } else {
        res = "Authentication error";
      }
    } catch (e) {
      res = "Some other error";
    }

    return res;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
