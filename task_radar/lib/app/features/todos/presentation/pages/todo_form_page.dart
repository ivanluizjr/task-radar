import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';

class TodoFormPage extends StatefulWidget {
  final int? todoId;

  const TodoFormPage({super.key, this.todoId});

  @override
  State<TodoFormPage> createState() => _TodoFormPageState();
}

class _TodoFormPageState extends State<TodoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _todoController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.todoId != null) {
      _isEditing = true;
      final state = context.read<TodosBloc>().state;
      final todo = state.allTodos.where((t) => t.id == widget.todoId).firstOrNull;
      if (todo != null) {
        _todoController.text = todo.todo;
      }
    }
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
      ),
      body: BlocListener<TodosBloc, TodosState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _todoController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descrição da tarefa',
                    hintText: 'Digite a descrição da tarefa...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Insira a descrição da tarefa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isEditing ? 'Salvar' : 'Criar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final description = _todoController.text.trim();

    if (_isEditing) {
      context.read<TodosBloc>().add(
            UpdateTodoRequested(
              id: widget.todoId!,
              todo: description,
            ),
          );
    } else {
      final authState = context.read<AuthBloc>().state;
      final userId = authState is AuthAuthenticated ? authState.user.id : 1;

      context.read<TodosBloc>().add(
            CreateTodoRequested(
              todo: description,
              userId: userId,
            ),
          );
    }

    context.pop();
  }
}
