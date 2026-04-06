import 'package:flutter/material.dart';

Future<void> popAfterConfirmation(
  BuildContext context, {
  required Future<bool> Function() confirmExit,
  Object? result,
}) async {
  final shouldPop = await confirmExit();
  if (!context.mounted || !shouldPop) return;
  Navigator.of(context).pop(result);
}
