import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_radar/app/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_bloc.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_event.dart';
import 'package:task_radar/app/features/todos/presentation/bloc/todos_state.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/todo_delete_button.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/todo_delete_confirmation_dialog.dart';
import 'package:task_radar/app/features/todos/presentation/widgets/todo_error_snackbar.dart';

void showCreateTodoBottomSheet(BuildContext context) {
  _showTodoBottomSheet(context);
}

void showTodoDetailBottomSheet(BuildContext context, Todo todo) {
  _showTodoBottomSheet(context, todo: todo);
}

void _showTodoBottomSheet(BuildContext context, {Todo? todo}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<TodosBloc>()),
        BlocProvider.value(value: context.read<AuthBloc>()),
      ],
      child: CreateTodoSheet(todo: todo),
    ),
  );
}

class CreateTodoSheet extends StatefulWidget {
  final Todo? todo;

  const CreateTodoSheet({super.key, this.todo});

  @override
  State<CreateTodoSheet> createState() => _CreateTodoSheetState();
}

class _CreateTodoSheetState extends State<CreateTodoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isNameFilled = false;
  bool _isEditing = false;

  bool get _isViewMode => widget.todo != null && !_isEditing;
  bool get _isEditMode => widget.todo != null && _isEditing;
  bool get _isCreateMode => widget.todo == null;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);

    if (widget.todo != null) {
      final parts = widget.todo!.todo.split('\n');
      _nameController.text = parts.first;
      if (parts.length > 1) {
        _descriptionController.text = parts.sublist(1).join('\n');
      }
      _isNameFilled = true;
    }
  }

  void _onNameChanged() {
    final filled = _nameController.text.trim().isNotEmpty;
    if (filled != _isNameFilled) {
      setState(() => _isNameFilled = filled);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return BlocListener<TodosBloc, TodosState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          showTodoErrorSnackBar(context, state.errorMessage!);
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!_isCreateMode && !_isEditMode) ...[
                // View mode title
              ] else if (_isCreateMode) ...[
                Text(
                  'Nova tarefa',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                Text(
                  'Editar tarefa',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              TextFormField(
                controller: _nameController,
                readOnly: _isViewMode,
                decoration: InputDecoration(
                  labelText: _isViewMode ? null : 'Nome da tarefa',
                  hintText: _isViewMode ? null : 'Digite o nome da tarefa',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Insira o nome da tarefa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                readOnly: _isViewMode,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: _isViewMode ? null : 'Descrição',
                  hintText: _isViewMode ? null : 'Digite a descrição da tarefa',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              if (_isViewMode) ...[
                ElevatedButton(
                  onPressed: () => setState(() => _isEditing = true),
                  child: Text(
                    'Editar tarefa',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isLight ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TodoDeleteButton(
                  onPressed: () => showTodoDeleteConfirmationDialog(
                    context: context,
                    onConfirm: () {
                      context.read<TodosBloc>().add(
                        DeleteTodoRequested(widget.todo!.id),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ] else if (_isEditMode)
                ElevatedButton(
                  onPressed: _isNameFilled ? _submitEdit : null,
                  child: const Text(
                    'Salvar',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _isNameFilled ? _submit : null,
                  child: Text(
                    'Criar tarefa',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isLight ? Colors.white : Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final todoText = description.isNotEmpty ? '$name\n$description' : name;

    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : 1;

    context.read<TodosBloc>().add(
      CreateTodoRequested(todo: todoText, userId: userId),
    );

    Navigator.of(context).pop();
  }

  void _submitEdit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final todoText = description.isNotEmpty ? '$name\n$description' : name;

    context.read<TodosBloc>().add(
      UpdateTodoRequested(id: widget.todo!.id, todo: todoText),
    );

    Navigator.of(context).pop();
  }
}
