import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'AnimatedDots.dart';

class LeaderImageWidget extends StatelessWidget {
  final Future<Uint8List?> leaderImageFuture;
  final double circleSize; // Diameter of the outer circle
  final double dotSize;    // Size of the animated dots

  const LeaderImageWidget({
    Key? key,
    required this.leaderImageFuture,
    required this.circleSize, // Entry for circle size
    required this.dotSize,    // Entry for dot size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: leaderImageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // AnimatedDots loading animation
          return Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Colors.teal, width: 2),
            ),
            child: Center(
              child: AnimatedDots(size: dotSize), // Use dotSize as entry
            ),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          // Default avatar for error or no data
          return Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Colors.teal, width: 2),
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
          );
        } else {
          // Display the loaded image
          return CircleAvatar(
            radius: circleSize / 2, // Calculate radius from circleSize
            backgroundImage: MemoryImage(snapshot.data!),
          );
        }
      },
    );
  }
}


