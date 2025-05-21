import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final Function(XFile? imageFile) onChanged;
  final XFile? initialImage;
  final String? labelText;

  const ImageInput({
    Key? key,
    required this.onChanged,
    this.initialImage,
    this.labelText = 'Tap to select image',
  }) : super(key: key);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pickedImage = widget.initialImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Adjust quality as needed
        maxWidth: 800,    // Adjust max width as needed
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
        });
        widget.onChanged(_pickedImage);
      } else {
        // User cancelled the picker
        widget.onChanged(null); // Notify that no image is selected
      }
    } catch (e) {
      // Handle errors, e.g., permissions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      widget.onChanged(null);
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null && widget.labelText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.labelText!,
              style: Theme.of(context).textTheme.bodyMedium, // Or another appropriate style
            ),
          ),
        GestureDetector(
          onTap: () => _showImageSourceActionSheet(context),
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey[400]!),
            ),
            alignment: Alignment.center,
            child: _pickedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(7.0), // slightly less than container to show border
                    child: Image.file(
                      File(_pickedImage!.path),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.add_a_photo,
                    color: Colors.grey[800],
                    size: 50,
                  ),
          ),
        ),
      ],
    );
  }
}
