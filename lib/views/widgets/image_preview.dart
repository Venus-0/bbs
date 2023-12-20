import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key, required this.image, required this.tag});
  final Uint8List image;
  final Object tag;
  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: tag,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.translucent,
          child: Container(
            color: Colors.black54.withAlpha(128),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Image.memory(image, fit: BoxFit.contain),
          ),
        ));
  }
}
