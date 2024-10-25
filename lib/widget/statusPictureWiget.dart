import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StatusPictureWidget extends StatefulWidget {
  final String imageUrl;
  final Function(File) onImageChanged;

  const StatusPictureWidget({
    Key? key,
    required this.imageUrl,
    required this.onImageChanged,
  }) : super(key: key);

  @override
  _StatusPictureWidgetState createState() => _StatusPictureWidgetState();
}

class _StatusPictureWidgetState extends State<StatusPictureWidget> {
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
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('ถ่ายภาพจากล้อง'),
                      onTap: () {
                        Navigator.pop(context);
                        _updateProfilePicture(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('เลือกภาพจากคลังภาพ'),
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
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF43474E),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _image != null
                ? Image.file(
                    _image!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : widget.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.imageUrl,
                        width: 200,
                        height: 200,
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
                          return const Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Colors.grey,
                      ),
          ),
        ),
      ),
    );
  }
}
