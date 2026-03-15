import 'package:flutter/material.dart';
import 'package:task_radar/app/core/widgets/spinner_animation.dart';

class AppCenteredLoading extends StatelessWidget {
  const AppCenteredLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: SpinnerAnimation());
  }
}

class AppEmptyState extends StatelessWidget {
  final String message;

  const AppEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class AppErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool centered;

  const AppErrorRetry({
    super.key,
    required this.message,
    required this.onRetry,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Column(
      mainAxisSize: centered ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: TextStyle(color: theme.colorScheme.error),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('Tentar novamente'),
        ),
      ],
    );

    return centered ? Center(child: content) : content;
  }
}

class AppListFooterLoader extends StatelessWidget {
  const AppListFooterLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: SpinnerAnimation(size: 28)),
    );
  }
}
