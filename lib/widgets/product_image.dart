import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductImage extends StatefulWidget {
  final String? initialImageUrl;
  final ValueChanged<File> onImagePicked;

  const ProductImage({
    super.key,
    this.initialImageUrl,
    required this.onImagePicked,
  });

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  File? _pickedImage;

  void buildBottomSheet(BuildContext context) {
    showModalBottomSheet(
      elevation: 4,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Picture'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  navigator.pop();
                  if (image != null) {
                    final file = File(image.path);
                    setState(() {
                      _pickedImage = file;
                    });
                    widget.onImagePicked(file);
                  }
                },
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose From Gallery'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  navigator.pop();
                  if (image != null) {
                    final file = File(image.path);
                    setState(() {
                      _pickedImage = file;
                    });
                    widget.onImagePicked(file);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasExistingImage =
        widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.all(25),
      child: Center(
        child: GestureDetector(
          onTap: () => buildBottomSheet(context),
          child: Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: BoxBorder.all(
                color: Colors.grey,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child:
                  _pickedImage != null
                      ? _buildPreview(Image.file(_pickedImage!, fit: BoxFit.cover))
                      : hasExistingImage
                      ? _buildPreview(
                        Image.network(
                          widget.initialImageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                      : IconButton(
                        icon: Icon(Icons.camera_alt_outlined),
                        iconSize: 30,
                        onPressed: () => buildBottomSheet(context),
                      ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(Widget image) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(width: double.infinity, height: double.infinity, child: image),
      ),
    );
  }
}
