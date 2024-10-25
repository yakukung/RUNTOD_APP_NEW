import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureWidget extends StatefulWidget {
  final String imageUrl;
  final Function(File) onImageChanged;

  const ProfilePictureWidget({
    Key? key,
    required this.imageUrl,
    required this.onImageChanged,
  }) : super(key: key);

  @override
  _ProfilePictureWidgetState createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _updateProfilePicture(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        widget.onImageChanged(_image!);
      }
    } catch (e) {
      // Handle error
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: Text('ถ่ายภาพจากล้อง'),
                      onTap: () {
                        Navigator.pop(context);
                        _updateProfilePicture(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('เลือกภาพจากคลังภาพ'),
                      onTap: () {
                        Navigator.pop(context);
                        _updateProfilePicture(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: _image != null
                ? Image.file(
                    _image!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : widget.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.imageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          );
                        },
                      )
                    : Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
          ),
        ),
      ),
    );
  }
}
