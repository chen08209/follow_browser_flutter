import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class SearchBar extends StatelessWidget {
  final Widget? prefix;
  final Widget? suffix;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Function? submit;

  const SearchBar({
    this.focusNode,
    this.controller,
    this.prefix,
    this.suffix,
    this.submit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Container(
          height: CommonUtil.searchBarHeight,
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                child: prefix,
              ),
              Expanded(
                child: TextField(
                  focusNode: focusNode,
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    contentPadding: EdgeInsets.all(0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  onSubmitted: (value) {
                    if(submit != null){
                      submit!();
                    }
                  },
                ),
              ),
              SizedBox(
                child: suffix,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


