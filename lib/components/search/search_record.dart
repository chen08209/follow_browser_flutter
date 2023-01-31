import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/model.dart';

class SearchRecord extends StatefulWidget {
  final Function(String value)? onTab;

  const SearchRecord({this.onTab, Key? key}) : super(key: key);

  @override
  State<SearchRecord> createState() => _SearchRecordState();
}

class _SearchRecordState extends State<SearchRecord> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> searchRecord = context.watch<Cache>().searchRecords;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: LayoutBuilder(
        builder: (context, container) {
          return Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            alignment: WrapAlignment.start,
            verticalDirection: VerticalDirection.up,
            children: searchRecord
                .map(
                  (e) => GestureDetector(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: container.maxWidth * 2 / 3,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        e,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onTap: () {
                      if(widget.onTab != null){
                        widget.onTab!(e);
                      }
                    },
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
