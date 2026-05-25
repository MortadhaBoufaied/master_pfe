import 'package:flutter/material.dart';

class ImageStep extends StatelessWidget {
  final List<String> images;
  final Function(List<String>) onImagesChanged;

  const ImageStep({
    Key? key,
    required this.images,
    required this.onImagesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 10,
          children: images
              .map((img) => Stack(
            children: [
              Image.network(img, width: 100, height: 100, fit: BoxFit.cover),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    List<String> newImages = List.from(images)..remove(img);
                    onImagesChanged(newImages);
                  },
                  child: const Icon(Icons.close, color: Colors.red),
                ),
              ),
            ],
          ))
              .toList(),
        ),
        ElevatedButton(
          onPressed: () {
            // Implement image picking here
          },
          child: const Text(' '),
        ),
      ],
    );
  }
}


