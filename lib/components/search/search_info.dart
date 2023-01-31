import 'package:flutter/material.dart';
import '../../model/model.dart';

import '../../utils/utils.dart';

class SearchInfo extends StatelessWidget {
  final BrowserTabModel? info;

  const SearchInfo({this.info, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modString(info?.title),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    modString(info?.url.toString()),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Wrap(
              spacing: 16,
              children: const [
                Icon(Icons.copy),
                Icon(Icons.edit),
                Icon(Icons.qr_code)
              ],
            ),
          ),
        ],
      ),
    );
    // Container(
    //   clipBehavior: Clip.hardEdge,
    //   margin: const EdgeInsets.symmetric(horizontal: 16),
    //   width: 32,
    //   height: 32,
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(16),
    //   ),
    //   child: () {
    //     if (info?.favicon?.url != null) {
    //       return Image.network(
    //         (info?.favicon?.url.toString())!,
    //         width: 24,
    //         height: 24,
    //         fit: BoxFit.contain,
    //         loadingBuilder: (context, child, loadingProgress) {
    //           if (loadingProgress == null) {
    //             return child;
    //           }
    //           return const Icon(Icons.explore);
    //         },
    //       );
    //     } else {
    //       return const Icon(Icons.explore);
    //     }
    //   }(),
    // );
  }

}
