import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shopping_app/providers/products.dart';
import 'package:shopping_app/providers/products_provider.dart';
import 'package:provider/provider.dart';
import '/widgets/product_image.dart';

class EditProductsScreen extends StatefulWidget {
  const EditProductsScreen({super.key});
  static const routeName = '/editproducts';

  @override
  State<EditProductsScreen> createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFoucsNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editedProduct = Product('', '', '', 0, '', false);
  File? _pickedImage;

  var initValues = {'title': '', 'description': '', 'price': ''};
  var isInit = true;

  var isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String?;
      if (productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(
          context,
        ).findById(productId);
        initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
        };
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFoucsNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    if (_pickedImage == null && _editedProduct.imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a product image.')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });

    try {
      if (_editedProduct.id != '') {
        await Provider.of<ProductsProvider>(
          context,
          listen: false,
        ).updateProduct(
          _editedProduct.id,
          _editedProduct,
          newImage: _pickedImage,
        );
      } else {
        await Provider.of<ProductsProvider>(
          context,
          listen: false,
        ).addProduct(_editedProduct, _pickedImage!);
      }
    } catch (error) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('An error occurred!'),
            content: const Text('Something went wrong.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Okay'),
              ),
            ],
          );
        },
      );
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Products')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: initValues['title'],
                          decoration: InputDecoration(
                            labelText: 'Title',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a value. ';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_priceFocusNode);
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                              _editedProduct.id,
                              value ?? '',
                              _editedProduct.description,
                              _editedProduct.price,
                              _editedProduct.imageUrl,
                              _editedProduct.isFavorite,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: initValues['price'],
                          decoration: InputDecoration(
                            labelText: 'Price',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (value) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_descriptionFoucsNode);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the price.';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number.';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Please enter a number greater than zero.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                              _editedProduct.id,
                              _editedProduct.title,
                              _editedProduct.description,
                              double.parse(value ?? ''),
                              _editedProduct.imageUrl,
                              _editedProduct.isFavorite,
                            );
                          },
                        ),
                        TextFormField(
                          initialValue: initValues['description'],
                          decoration: InputDecoration(
                            labelText: 'Description',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                            ),
                          ),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionFoucsNode,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a description.';
                            }
                            if (value.length < 20) {
                              return 'Description should be atleast 20 characters long.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                              _editedProduct.id,
                              _editedProduct.title,
                              value ?? '',
                              _editedProduct.price,
                              _editedProduct.imageUrl,
                              _editedProduct.isFavorite,
                            );
                          },
                        ),
                        ProductImage(
                          initialImageUrl: _editedProduct.imageUrl,
                          onImagePicked: (file) {
                            setState(() {
                              _pickedImage = file;
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: FloatingActionButton(
                            onPressed: _saveForm,
                            child: const Icon(Icons.save),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
