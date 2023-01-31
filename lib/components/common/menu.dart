import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final List<Widget> items;

  const Menu({required this.items, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, container) {
      return Wrap(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  bottom: 12,
                  left: 12,
                  right: 12,
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.share,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.settings,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Wrap(
            children: items
                .map((item) => SizedBox(
                      width: container.maxWidth / 4,
                      child: item,
                    ))
                .toList(),
          )
        ],
      );
    });
  }
}
