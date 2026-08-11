import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/place_model.dart';

class Places with ChangeNotifier {
  List<PlaceModel> _places = [];
  bool _isLoading = false;
  List<PlaceModel> get places => _places;
  bool get isLoading => _isLoading;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveAddress(PlaceModel place) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .add(place.toMap());
      await loadAddress();
    } catch (error) {
      rethrow;
    }
  }

  Future<List<PlaceModel>> loadAddress() async {
    final user = _auth.currentUser;

    if (user == null) return [];

    _isLoading = true;
    notifyListeners();

    try {
      final document =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('addresses')
              .get();

      _places =
          document.docs
              .map((doc) => PlaceModel.fromMap(doc.data(), id: doc.id))
              .toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _places;
  }

  Future<void> updateAddress(PlaceModel places) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(places.id)
          .update(places.toMap());
      final index = _places.indexWhere((p) => p.id == places.id);
      if (index != -1) {
        _places[index] = places;
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(addressId)
          .delete();
      _places.removeWhere((places) => places.id == addressId);
    } catch (error) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearAllAddress() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('addresses')
            .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    _places.clear();
    notifyListeners();
  }
}
