import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _pickedFile;
  bool _isLoading = false;
  int uploadLimit = 5;

  Future<void> _getImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        _pickedFile = image;
      });
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while picking the image: $e'),
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    try {
      if (_pickedFile != null) {
        final user = _auth.currentUser;
        final userId = user?.uid;

        // Check the number of uploaded images for the user
        final userRef = _storage.ref().child('users/$userId');
        final ListResult result = await userRef.list();
        final int currentImageCount = result.items.length;

        if (currentImageCount >= uploadLimit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload limit reached for this user.'),
            ),
          );
          return;
        }

        setState(() {
          _isLoading = true;
        });

        final fileName = 'user_$userId$currentImageCount.jpg';
        final reference = _storage.ref().child('images/$fileName');

        // Check image file extension and convert to JPEG if necessary
        File imageFile = File(_pickedFile!.path);
        final imageFormat = imageFile.path.split('.').last.toLowerCase();

        if (imageFormat != 'jpg' && imageFormat != 'jpeg') {
          final convertedImage = await imageFile.readAsBytes();
          final newFile = await File.fromUri(Uri.file(
            '${imageFile.path}.temp.jpg',
          ));
          await newFile.writeAsBytes(convertedImage);
          imageFile = newFile;
        }

        await reference.putFile(imageFile);

        // Update the user's image count after a successful upload
        await userRef.child(fileName).putFile(imageFile);

        print('Image uploaded successfully.');
        setState(() {
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select an image before uploading.'),
          ),
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while uploading the image: $e'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _pickedFile != null
                ? Expanded(child: Image.file(File(_pickedFile!.path)))
                : Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _getImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadImage,
              child: Text('Upload Image'),
            ),
            if (_isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}