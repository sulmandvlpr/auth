//this widget class select image from camera and used inside AuthScreen
//to upload user image for authentication on firebase

//statful caus i need to pick image and display image

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedImage});

  //we need this picked image from file system to use inside Auth Screen tp hold the image and upload to firebase storage
  //pickedImage in paramets  is that we take from gallery
  final void Function(File pickedImage) onPickedImage;

  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

//methdo to pick image from camera
//takes times to pick image so we use async
  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
        source:
            //we use imageQuialt and size cause 1 take less time to load 2 we want to preview small
            ImageSource.camera,
        imageQuality: 50,
        maxWidth: 150);
//pickedImage is used as preview image down below

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickedImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return
        //colmn for image and button to uplaod
        Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          //show preview of pickedimage
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),
        TextButton.icon(
          icon: const Icon(Icons.image),
          //open camera wiht help of image picker
          onPressed: _pickImage,
          label: Text(
            'Add Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
