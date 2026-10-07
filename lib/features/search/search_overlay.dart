import 'package:flutter/material.dart';

class SearchOverlay extends StatelessWidget {
  const SearchOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
        hintText: 'Search destination...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
