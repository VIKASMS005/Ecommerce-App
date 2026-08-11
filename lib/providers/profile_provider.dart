import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/helpers/db_helpers.dart';
import '../models/profile.dart';
import 'dart:io';

class ProfileProvider with ChangeNotifier {
  Profile? _profile;
  File? _profileImage;

  File? get profileImage => _profileImage;

  Profile? get profile => _profile;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveProfile(Profile profile) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profile.toMap(), SetOptions(merge: true));

      _profile = profile;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadProfile() async {
    final user = _auth.currentUser;

    if (user == null) return;

    try {
      final document = await _firestore.collection('users').doc(user.uid).get();

      if (!document.exists) return;

      _profile = Profile.fromMap(document.data()!);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }

  Future<void> saveToDB(String id, String imagePath) async {
    await DbHelper.insertPic('profile_pic', {'id': id, 'image': imagePath});
    _profileImage = File(imagePath);
    notifyListeners();
  }

  Future<void> fetchAndSetPic() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final data = await DbHelper.fetchProfilePic('profile_pic');

    if (data == null || data['image'] == null) {
      return;
    }

    _profileImage = File(data['image']);
    notifyListeners();
  }
}
