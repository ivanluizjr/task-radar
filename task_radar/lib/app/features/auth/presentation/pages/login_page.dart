import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:task_radar/app/core/widgets/app_feedback.dart';
import 'package:task_radar/app/core/widgets/spinner_animation.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_event.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showAppErrorSnackBar(context, state.message);
          }
        },
        child: SafeArea(
          child: Center(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                if (isLoading) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/title_task_radar.svg',
                        width: 215,
                        height: 40,
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SpinnerAnimation(
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SvgPicture.asset(
                          'assets/images/title_task_radar.svg',
                          width: 215,
                          height: 40,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Usuário',
                            hintText: 'Digite o usuário',
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Insira seu nome de usuário';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: 'Digite sua senha',
                            suffixIcon: IconButton(
                              icon: SvgPicture.asset(
                                _obscurePassword
                                    ? 'assets/images/icon_visibility.svg'
                                    : 'assets/images/icon_visibility_off.svg',
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  theme.iconTheme.color ?? Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _onLogin(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Insira sua senha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _onLogin,
                          child: Text(
                            'Entrar',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequested(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }
}
