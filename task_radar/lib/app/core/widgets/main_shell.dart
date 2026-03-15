import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:task_radar/app/core/theme/app_theme.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_radar/app/features/dashboard/presentation/bloc/dashboard_cubit.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin =
        (authState is AuthAuthenticated && authState.user.isAdmin) ||
        (authState is AuthRefreshing && authState.user.isAdmin);
    final theme = Theme.of(context);
    final iconColor = theme.iconTheme.color ?? Colors.white;
    final selectedColor = Colors.white;

    Widget svgIcon(String asset, {bool selected = false}) {
      return SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          selected ? selectedColor : iconColor,
          BlendMode.srcIn,
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: NavigationBar(
            height: 84,
            backgroundColor: theme.colorScheme.surface,
            indicatorColor: theme.appColors.grayLight,
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) =>
                _onItemTapped(index, context, isAdmin),
            destinations: [
              NavigationDestination(
                icon: svgIcon('assets/images/icon_home.svg'),
                selectedIcon: svgIcon(
                  'assets/images/icon_home.svg',
                  selected: true,
                ),
                label: 'Início',
              ),
              NavigationDestination(
                icon: svgIcon('assets/images/icon_add_check.svg'),
                selectedIcon: svgIcon(
                  'assets/images/icon_add_check.svg',
                  selected: true,
                ),
                label: 'Tarefas',
              ),
              if (isAdmin)
                NavigationDestination(
                  icon: svgIcon('assets/images/icon_group.svg'),
                  selectedIcon: svgIcon(
                    'assets/images/icon_group.svg',
                    selected: true,
                  ),
                  label: 'Usuários',
                ),
              NavigationDestination(
                icon: svgIcon('assets/images/icon_account.svg'),
                selectedIcon: svgIcon(
                  'assets/images/icon_account.svg',
                  selected: true,
                ),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final authState = context.read<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;

    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/todos')) return 1;
    if (isAdmin && location.startsWith('/users')) return 2;
    if (location.startsWith('/profile')) return isAdmin ? 3 : 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, bool isAdmin) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        // Sempre relê o banco local para refletir toggles feitos em Tarefas
        context.read<DashboardCubit>().refreshSummary();
      case 1:
        context.go('/todos');
      case 2:
        if (isAdmin) {
          context.go('/users');
        } else {
          context.go('/profile');
        }
      case 3:
        context.go('/profile');
    }
  }
}
