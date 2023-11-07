import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key, required this.image, required this.tag});
  final Image image;
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
            child: image,
          ),
        ));
  }
}
