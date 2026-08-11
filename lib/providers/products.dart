import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
    this.id,
    this.title,
    this.description,
    this.price,
    this.imageUrl,
    this.isFavorite,
  );

  void _setFavStatus(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
      'https://shopping-app-8c5f9-default-rtdb.asia-southeast1.firebasedatabase.app/UserFavorites/$userId/$id.json?auth=$token',
    );
    try {
      final response = await http.put(url, body: json.encode(isFavorite));

      if (response.statusCode >= 400) {
        _setFavStatus(oldStatus);
      }
    } catch (error) {
      _setFavStatus(oldStatus);
    }
  }
}
