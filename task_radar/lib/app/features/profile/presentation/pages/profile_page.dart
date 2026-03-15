import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_radar/app/core/theme/app_theme.dart';
import 'package:task_radar/app/core/theme/theme_cubit.dart';
import 'package:task_radar/app/core/widgets/app_state_widgets.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_event.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_radar/app/features/profile/presentation/widgets/profile_shimmer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const GetCurrentUserRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthRefreshing) {
              return const ProfileShimmer();
            }

            if (state is AuthError) {
              return AppErrorRetry(
                message: state.message,
                onRetry: () => context.read<AuthBloc>().add(
                  const GetCurrentUserRequested(),
                ),
              );
            }

            if (state is! AuthAuthenticated) {
              return const AppCenteredLoading();
            }

            final user = state.user;

            return BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDark = themeMode == ThemeMode.dark;
                final pillBg = isDark
                    ? const Color(0xFF381E72)
                    : theme.appColors.purple.withValues(alpha: 0.18);
                final activeBg = theme.colorScheme.primary;
                final logoutColor = isDark
                    ? Colors.white
                    : theme.colorScheme.onSurface;

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.read<ThemeCubit>().toggleTheme(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: pillBg,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.transparent
                                        : activeBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      isDark
                                          ? 'assets/images/icon_unselecte_light.svg'
                                          : 'assets/images/icon_selected_light.svg',
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? activeBg
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      isDark
                                          ? 'assets/images/icon_selected_moon.svg'
                                          : 'assets/images/icon_unselected_moon.svg',
                                      width: 17,
                                      height: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _confirmLogout(context),
                          style: TextButton.styleFrom(
                            foregroundColor: logoutColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          ),
                          icon: SvgPicture.asset(
                            'assets/images/icon_logout.svg',
                            width: 18,
                            height: 18,
                            colorFilter: ColorFilter.mode(
                              logoutColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: Text(
                            'Sair',
                            style: TextStyle(fontSize: 14, color: logoutColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            user.image != null && user.image!.isNotEmpty
                            ? NetworkImage(user.image!)
                            : null,
                        child: user.image == null || user.image!.isEmpty
                            ? Text(
                                user.firstName[0].toUpperCase(),
                                style: const TextStyle(fontSize: 36),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        user.firstName,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.appColors.grayLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user_outlined, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              user.isAdmin ? 'Administrador' : 'Moderador',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Divider(color: Colors.grey.shade700, thickness: 0.5),
                    const SizedBox(height: 18),
                    _ProfileField(label: 'Nome completo', value: user.fullName),
                    const SizedBox(height: 18),
                    _ProfileField(label: 'E-mail', value: user.email),
                    const SizedBox(height: 18),
                    _ProfileField(
                      label: 'Empresa',
                      value: _displayValue(user.companyName),
                    ),
                    const SizedBox(height: 18),
                    _ProfileField(
                      label: 'Departamento',
                      value: _displayValue(user.department),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Não informado';
    }
    return value;
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: Text(
              'Sair',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 32 / 2, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
