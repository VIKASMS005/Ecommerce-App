import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'products.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:uuid/uuid.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   'p1',
    //   'TShirt',
    //   'A Good looking TShirt with a perfect fit',
    //   599,
    //   'https://encrypted-tbn1.gstatic.com/shopping?q=tbn:ANd9GcQjq_BV6a9NO6TYIA48jKcJAgs15m9RyBIz_icvChc8rwVMHSTeQyqMdNyajOkdq3kDsckVM3fMtFls__-kZzl0wShDLKppgrCWa03cgQ-zJC14VSKmtjFUwA&usqp=CAc',
    //   false,
    // ),
    // Product(
    //   'p2',
    //   'Trousers',
    //   'A nice trouser with a great fit.',
    //   699,

    //   'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStlBdAnLWh-nvJ3CAy_WEBjuGZRwGWKxOi5Q&s',
    //   false,
    // ),
    // Product(
    //   'p3',
    //   'Scarf',
    //   'Warm and cozy - exactly what you need for the winter.',
    //   199,

    //   'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    //   false,
    // ),
    // Product(
    //   'p4',
    //   'A Pan',
    //   'Prepare any meal you want.',
    //   999,
    //   'https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcQ_a0DgfXIGXIQFOJbLl37DTP3kcjlO6eu0hi8AdNlxndKgwqYimcvx_adLVRYJI5PLBg4y1cskk_huoM37Bt3hKlGjt8K5W1N_ADYq_jVepthisAcEBeeI',
    //   false,
    // ),
  ];

  // var showFavoritesOnly = false;
  List<Product> _userItems = [];

  List<Product> get userItems {
    return [..._userItems];
  }

  List<Product> get items {
    // if (showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  // void showFavorites() {
  //   showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser
            ? 'orderBy="creatorId"&equalTo="${FirebaseAuth.instance.currentUser?.uid}"'
            : '';
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    var url = Uri.parse(
      'https://shopping-app-8c5f9-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$token&$filterString',
    );
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
        'https://shopping-app-8c5f9-default-rtdb.asia-southeast1.firebasedatabase.app/UserFavorites/$userId.json?auth=$token',
      );
      final favoriteResponse = await http.get(url);
      final favData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      (extractedData as Map<String, dynamic>).forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            prodId,
            prodData['title'],
            prodData['description'],
            (prodData['price'] as num).toDouble(),
            prodData['imageUrl'],
            favData == null ? false : favData[prodId] ?? false,
          ),
        );
      });
      if (filterByUser) {
        _userItems = loadedProducts;
      } else {
        _items = loadedProducts;
      }
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product, File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final userId = user.uid;
    final token = await user.getIdToken();

    final imageId = const Uuid().v4();
    final extension = p.extension(imageFile.path);

    final url = Uri.parse(
      'https://shopping-app-8c5f9-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$token',
    );
    try {
      final image = FirebaseStorage.instance
          .ref()
          .child('ProductImages')
          .child(userId)
          .child('$imageId$extension');
      await image.putFile(imageFile);
      final imageUrl = await image.getDownloadURL();
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': imageUrl,
          'price': product.price,
          'creatorId': FirebaseAuth.instance.currentUser?.uid,
        }),
      );
      if (response.statusCode >= 400) {
        await image.delete().catchError((_) {});
        throw HttpException('Could not add product.');
      }
      final newProduct = Product(
        json.decode(response.body)['name'],
        product.title,
        product.description,
        product.price,
        imageUrl,
        false,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(
    String id,
    Product editedProduct, {
    File? newImage,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final token = await user.getIdToken();

    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex < 0) {
      throw Exception('Product not found!!!');
    }

    var imageUrl = editedProduct.imageUrl;
    final oldImageUrl = _items[prodIndex].imageUrl;

    try {
      if (newImage != null) {
        final imageId = const Uuid().v4();
        final extension = p.extension(newImage.path);
        final imageRef = FirebaseStorage.instance
            .ref()
            .child('ProductImages')
            .child(user.uid)
            .child('$imageId$extension');

        await imageRef.putFile(newImage);
        imageUrl = await imageRef.getDownloadURL();
      }

      final url = Uri.parse(
        'https://shopping-app-8c5f9-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$token',
      );

      final response = await http.patch(
        url,
        body: json.encode({
          'title': editedProduct.title,
          'description': editedProduct.description,
          'price': editedProduct.price,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode >= 400) {
        throw HttpException('Could not update product.');
      }

      _items[prodIndex] = Product(
        id,
        editedProduct.title,
        editedProduct.description,
        editedProduct.price,
        imageUrl,
        editedProduct.isFavorite,
      );
      notifyListeners();

      if (newImage != null &&
          oldImageUrl.isNotEmpty &&
          oldImageUrl != imageUrl) {
        await FirebaseStorage.instance
            .refFromURL(oldImageUrl)
            .delete()
            .catchError((_) {});
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final url = Uri.parse(
      'https://shopping-app-8c5f9-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$token',
    );
    final existingProdIndex = _items.indexWhere((prod) => prod.id == id);
    if (existingProdIndex == -1) return;
    Product? existingProduct = _items[existingProdIndex];
    _items.removeAt(existingProdIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProdIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not Delete product.');
    }
    existingProduct = null;
  }
}
