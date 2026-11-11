import 'package:flutter/material.dart';
import 'package:test_point/core/error/failure.dart';

/// Shows [failure]'s message in a snack bar.
void showFailureSnackBar(BuildContext context, Failure failure) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(failure.message, maxLines: 2)));
}
