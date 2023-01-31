import 'dart:async';

import 'package:flutter/material.dart';

Function debounce(
  Function? func, [
  Duration delay = const Duration(milliseconds: 200),
]) {
  Timer? timer;
  target() {
    if (timer?.isActive ?? false) {
      timer?.cancel();
    }
    timer = Timer(delay, () {
      func?.call();
    });
  }

  return target;
}

void delayExec(Function func){
  Future.delayed(const Duration(milliseconds: 300),(){
    func();
  });
}