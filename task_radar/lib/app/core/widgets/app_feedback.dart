import 'package:flutter/material.dart';

void showAppErrorSnackBar(BuildContext context, String message) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: theme.colorScheme.error),
  );
}
