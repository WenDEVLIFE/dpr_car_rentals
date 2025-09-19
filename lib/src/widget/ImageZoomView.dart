import 'dart:io';
import 'package:flutter/material.dart';

class ImageZoomView extends StatefulWidget {
  final String? imageUrl;
  final File? imageFile;
  final String heroTag;

  const ImageZoomView({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.heroTag,
  }) : assert(imageUrl != null || imageFile != null,
            'Either imageUrl or imageFile must be provided');

  @override
  State<ImageZoomView> createState() => _ImageZoomViewState();
}

class _ImageZoomViewState extends State<ImageZoomView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Image'),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: widget.heroTag,
            child: widget.imageFile != null
                ? Image.file(
                    widget.imageFile!,
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    widget.imageUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
