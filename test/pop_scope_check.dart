import 'package:flutter/material.dart';

Widget testPopScope() {
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (bool didPop, dynamic result) {},
    child: const SizedBox(),
  );
}

