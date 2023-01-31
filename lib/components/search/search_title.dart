import 'package:flutter/material.dart';

class SearchTitle extends StatelessWidget {
  const SearchTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24,horizontal: 0),
      child: Text(
        'Explore',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
