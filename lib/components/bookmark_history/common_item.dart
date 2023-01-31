import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class CommonItem extends StatelessWidget {
  static double height = 64;
  final dynamic item;

  const CommonItem(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeUtil themeUtil = ThemeUtil(context);

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        vertical: CommonUtil.defaultPadding,
        horizontal: CommonUtil.defaultPadding * 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(right: CommonUtil.defaultPadding),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40 / 3),
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
              child: item?.favicon != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  item?.favicon!,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      FontIcons.earth,
                      size: 24,
                    );
                  },
                  width: 24,
                  height: 24,
                  fit: BoxFit.fill,
                ),
              )
                  : const Icon(
                FontIcons.earth,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              alignment: Alignment.center,
              padding: EdgeInsets.only(right: CommonUtil.defaultPadding),
              child: Padding(
                padding: EdgeInsets.zero,
                child: LayoutBuilder(
                  builder: (_, container) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.fitHeight,
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            height: 22,
                            width: container.maxWidth,
                            child: Text(
                              modString(item?.title ?? '未知'),
                              style: TextStyle(
                                fontSize: 16,
                                color: themeUtil.textPrimaryColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.fitHeight,
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            height: 18,
                            width: container.maxWidth,
                            child: Text(
                              modString(item?.url ?? '未知'),
                              style: TextStyle(
                                fontSize: 12,
                                color: themeUtil.textSecondaryColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
