import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final Widget child;
  final String describe;
  final Function? onTap;

  const Button({
    required this.child,
    required this.describe,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: child,
            ),
            Text(
              describe,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class Button2 extends StatelessWidget {
  final Widget child;
  final String describe;
  final Function? onTap;
  final Color? color;

  const Button2({
    required this.child,
    required this.describe,
    this.color,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: child,
            ),
          ),
          Text(
            describe,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
