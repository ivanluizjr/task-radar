import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TodoDeleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TodoDeleteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton.icon(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        'assets/images/icon_delete.svg',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(theme.colorScheme.error, BlendMode.srcIn),
      ),
      label: Text('Excluir', style: TextStyle(color: theme.colorScheme.error)),
    );
  }
}
