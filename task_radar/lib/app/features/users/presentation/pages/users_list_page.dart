import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_radar/app/features/users/presentation/bloc/users_bloc.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<UsersBloc>().add(const LoadUsers());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<UsersBloc>().add(const LoadMoreUsers());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
      ),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          if (state.status == UsersStatus.loading && state.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == UsersStatus.error && state.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage ?? 'Erro ao carregar usuários',
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<UsersBloc>().add(const LoadUsers()),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (state.users.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<UsersBloc>().add(const LoadUsers());
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: state.users.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.users.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final user = state.users[index];
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
                    subtitle: Text(user.email),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push(
                        '/users/${user.id}/todos?name=${Uri.encodeComponent(user.fullName)}',
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
