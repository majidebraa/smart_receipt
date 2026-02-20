import 'dart:convert';
import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageBase64;

  const FullScreenImagePage({super.key, required this.imageBase64});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // close on tap
        child: Center(
          child: InteractiveViewer(
            maxScale: 5,
            minScale: 0.5,
            child: Hero(
              tag: imageBase64, // hero tag must match
              child: Image.memory(
                base64Decode(imageBase64),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}