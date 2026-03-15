import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/todo_error_snackbar.dart';

class TodoFormPage extends StatefulWidget {
  final int? todoId;

  const TodoFormPage({super.key, this.todoId});

  @override
  State<TodoFormPage> createState() => _TodoFormPageState();
}

class _TodoFormPageState extends State<TodoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<TodosBloc>().state;
    final todo = state.allTodos.where((t) => t.id == widget.todoId).firstOrNull;
    if (todo != null) {
      _todoController.text = todo.todo;
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
      appBar: AppBar(title: const Text('Editar Tarefa')),
      body: BlocListener<TodosBloc, TodosState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            showTodoErrorSnackBar(context, state.errorMessage!);
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
                ElevatedButton(onPressed: _submit, child: const Text('Salvar')),
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

    context.read<TodosBloc>().add(
      UpdateTodoRequested(id: widget.todoId!, todo: description),
    );

    context.pop();
  }
}
