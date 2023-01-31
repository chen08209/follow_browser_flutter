import 'package:flutter/material.dart';
import '../../utils/font_icons.dart';

class SearchList extends StatelessWidget {
  final Function(String)? onItemTap;
  final List suggestions;

  const SearchList({this.onItemTap, required this.suggestions, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      children: buildList(suggestions: suggestions, onTap: onItemTap),
    );
  }
}

List<SuggestionsItem> buildList(
    {required List suggestions, Function(String)? onTap}) {
  return suggestions
      .map(
        (e) => SuggestionsItem(
          text: e,
          onTap: onTap,
        ),
      )
      .toList();
}

class SuggestionsItem extends StatelessWidget {
  final String text;
  final Function(String)? onTap;

  const SuggestionsItem({required this.text, this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        if (onTap != null) {onTap!(text)}
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              child: Icon(
                FontIcons.search,
                size: 24,
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              child: Icon(
                FontIcons.arrowUpLeft,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
