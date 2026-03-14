import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_event.dart';
import 'package:task_radar/app/features/splash/presentation/widgets/splash_shape_animation.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const _purple = Color(0xFFCBB6F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SplashShapeAnimation(
        color: _purple,
        onCompleted: () {
          context.read<AuthBloc>().add(const CheckAuthRequested());
        },
      ),
    );
  }
}
