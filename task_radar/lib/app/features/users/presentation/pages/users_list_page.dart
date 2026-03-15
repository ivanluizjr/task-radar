import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_radar/app/core/widgets/app_search_field.dart';
import 'package:task_radar/app/core/widgets/app_state_widgets.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';
import 'package:task_radar/app/features/users/presentation/bloc/users_bloc.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<UsersBloc>().add(const LoadUsers());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<UsersBloc>().state;
    if (state.searchQuery.isNotEmpty || state.filter != UserFilter.all) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<UsersBloc>().add(const LoadMoreUsers());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários')),
      body: Column(
        children: [
          BlocBuilder<UsersBloc, UsersState>(
            buildWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
            builder: (context, state) {
              return AppSearchField(
                controller: _searchController,
                hintText: 'Pesquisar usuários',
                hasText: state.searchQuery.isNotEmpty,
                onChanged: (value) =>
                    context.read<UsersBloc>().add(SearchUsers(value)),
                onClear: () {
                  _searchController.clear();
                  context.read<UsersBloc>().add(const SearchUsers(''));
                },
              );
            },
          ),
          const SizedBox(height: 8),
          BlocBuilder<UsersBloc, UsersState>(
            buildWhen: (prev, curr) => prev.filter != curr.filter,
            builder: (context, state) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    _UserFilterChip(
                      label: 'Todos',
                      selected: state.filter == UserFilter.all,
                      onSelected: () => context.read<UsersBloc>().add(
                        const FilterUsers(UserFilter.all),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _UserFilterChip(
                      label: 'Administradores',
                      selected: state.filter == UserFilter.admin,
                      onSelected: () => context.read<UsersBloc>().add(
                        const FilterUsers(UserFilter.admin),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _UserFilterChip(
                      label: 'Moderadores',
                      selected: state.filter == UserFilter.moderator,
                      onSelected: () => context.read<UsersBloc>().add(
                        const FilterUsers(UserFilter.moderator),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<UsersBloc, UsersState>(
              builder: (context, state) {
                if (state.status == UsersStatus.loading &&
                    state.users.isEmpty) {
                  return const AppCenteredLoading();
                }

                if (state.status == UsersStatus.error && state.users.isEmpty) {
                  return AppErrorRetry(
                    message: state.errorMessage ?? 'Erro ao carregar usuários',
                    onRetry: () =>
                        context.read<UsersBloc>().add(const LoadUsers()),
                  );
                }

                final filtered = state.filteredUsers;

                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    message: 'Nenhum usuário encontrado',
                  );
                }

                final admins = filtered.where((u) => u.isAdmin).toList();
                final moderators = filtered.where((u) => !u.isAdmin).toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<UsersBloc>().add(const LoadUsers());
                  },
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 8,
                    ),
                    children: [
                      if (admins.isNotEmpty) ...[
                        _SectionHeader(title: 'Administradores'),
                        ...admins.map((u) => _UserCard(user: u)),
                      ],
                      if (moderators.isNotEmpty) ...[
                        _SectionHeader(title: 'Moderadores'),
                        ...moderators.map((u) => _UserCard(user: u)),
                      ],
                      if (!state.hasReachedMax &&
                          state.searchQuery.isEmpty &&
                          state.filter == UserFilter.all)
                        const AppListFooterLoader(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _UserFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedBackground = theme.colorScheme.primary;
    final chipBackground = selected ? selectedBackground : Colors.transparent;
    final chipTextColor = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final chipBorderColor = selected
        ? selectedBackground
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: chipBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 1, color: chipBorderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check, size: 16, color: chipTextColor),
                const SizedBox(width: 6),
              ],
              Text(label, style: TextStyle(color: chipTextColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.image != null && user.image!.isNotEmpty
              ? NetworkImage(user.image!)
              : null,
          child: user.image == null || user.image!.isEmpty
              ? Text(user.firstName[0].toUpperCase())
              : null,
        ),
        title: Text(user.fullName),
        onTap: () {
          final uri = Uri(
            path: '/users/${user.id}/todos',
            queryParameters: {
              'name': user.fullName,
              if (user.image != null && user.image!.isNotEmpty)
                'image': user.image!,
            },
          );
          context.push(uri.toString());
        },
      ),
    );
  }
}
