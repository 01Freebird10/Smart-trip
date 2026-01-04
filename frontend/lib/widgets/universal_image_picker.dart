import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UniversalImagePicker extends StatefulWidget {
  final String? initialImage;
  final Function(String) onImageSelected;
  final String label;

  final Widget? child;

  const UniversalImagePicker({
    super.key,
    this.initialImage,
    required this.onImageSelected,
    this.label = "Choose Image",
    this.child,
  });

  @override
  State<UniversalImagePicker> createState() => _UniversalImagePickerState();
}

class _UniversalImagePickerState extends State<UniversalImagePicker> {
  String? _base64Image;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null && widget.initialImage!.startsWith('data:image')) {
      _base64Image = widget.initialImage;
      final commaIndex = _base64Image!.indexOf(',');
      if (commaIndex != -1) {
        _imageBytes = base64Decode(_base64Image!.substring(commaIndex + 1));
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      final bytes = result.files.first.bytes!;
      final extension = result.files.first.extension ?? 'jpg';
      final base64String = 'data:image/$extension;base64,${base64Encode(bytes)}';
      
      setState(() {
        _imageBytes = bytes;
        _base64Image = base64String;
      });
      
      widget.onImageSelected(base64String);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: widget.child ?? Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                image: _imageBytes != null 
                  ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                  : (widget.initialImage != null && !widget.initialImage!.startsWith('data:image')
                      ? DecorationImage(image: NetworkImage(widget.initialImage!), fit: BoxFit.cover)
                      : null),
              ),
              child: (_imageBytes == null && (widget.initialImage == null || widget.initialImage!.isEmpty))
                ? Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.primary, size: 24)
                : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    _base64Image != null ? "Image selected" : "No file chosen",
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.upload_file_rounded, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
