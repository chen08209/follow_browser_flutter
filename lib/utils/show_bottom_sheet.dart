import 'package:flutter/material.dart';
import 'screen_util.dart';

customShowBottomSheet({
  required BuildContext context,
  required Widget child,
  double horizontalPadding = 12,
}) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Material(
          color: Theme.of(context).colorScheme.background,
          shape: const RoundedRectangleBorder(
            side: BorderSide(style: BorderStyle.none),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            width: double.infinity,
            margin: EdgeInsets.only(
                bottom: 12 + ScreenUtil.getInstance().navigationBarHeight),
            child: child,
            // child: Wrap(
            //   direction: Axis.horizontal,
            //   alignment: WrapAlignment.center,
            //   children: [
            //     Container(
            //         width: 40,
            //         height: 5,
            //         margin: const EdgeInsets.only(bottom: 12),
            //         decoration: BoxDecoration(
            //           color: Theme.of(context).colorScheme.surfaceVariant,
            //           border: Border.all(style: BorderStyle.none),
            //           borderRadius: const BorderRadius.all(Radius.circular(2)),
            //         )),
            //     child,
            //   ],
            // ),
          ),
        );
      });
}
