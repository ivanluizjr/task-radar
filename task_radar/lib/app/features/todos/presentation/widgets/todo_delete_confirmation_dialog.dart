import 'package:flutter/material.dart';

Future<void> showTodoDeleteConfirmationDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
}) {
  final theme = Theme.of(context);

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Excluir tarefa?'),
      content: const Text('A tarefa desaparecerá e não poderá ser recuperada.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onConfirm();
          },
          child: Text(
            'Excluir',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ],
    ),
  );
}
