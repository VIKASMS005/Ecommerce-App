import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as systempath;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfilePic extends StatefulWidget {
  final Function(File)? onSelectImage;
  final bool showCameraIcon;
  const ProfilePic({
    super.key,
    this.onSelectImage,
    this.showCameraIcon = false,
  });

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      elevation: 4,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsetsGeometry.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Picture'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final imageFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    maxWidth: 600,
                  );

                  if (!mounted) return;
                  navigator.pop();

                  if (imageFile == null) return;

                  final appDir =
                      await systempath.getApplicationDocumentsDirectory();
                  final imageName = path.basename(imageFile.path);
                  final savedImagePath = '${appDir.path}/$imageName';

                  await imageFile.saveTo(savedImagePath);
                  widget.onSelectImage?.call(File(savedImagePath));
                },
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose From Gallery'),
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final imageFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 600,
                  );

                  if (!mounted) return;
                  navigator.pop();

                  if (imageFile == null) return;

                  final appDir =
                      await systempath.getApplicationDocumentsDirectory();
                  final imageName = path.basename(imageFile.path);
                  final savedImagePath = '${appDir.path}/$imageName';

                  await imageFile.saveTo(savedImagePath);
                  widget.onSelectImage?.call(File(savedImagePath));
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
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    final profileProvider = Provider.of<ProfileProvider>(context);
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).primaryColor,
                backgroundImage:
                    profileProvider.profileImage != null
                        ? FileImage(profileProvider.profileImage!)
                        : null,
                child:
                    profileProvider.profileImage == null
                        ? Icon(Icons.person, size: 100)
                        : null,
              ),
              if (widget.showCameraIcon)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      _showBottomSheet(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      radius: 15,
                      child: Icon(Icons.camera_alt, size: 15),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Text('$userEmail'),
        ],
      ),
    );
  }
}
