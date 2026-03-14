import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_radar/app/features/todos/domain/entities/todo.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

@freezed
abstract class TodoModel with _$TodoModel {
  const TodoModel._();

  const factory TodoModel({
    required int id,
    required String todo,
    required bool completed,
    required int userId,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  Todo toEntity() =>
      Todo(id: id, todo: todo, completed: completed, userId: userId);

  factory TodoModel.fromEntity(Todo entity) => TodoModel(
    id: entity.id,
    todo: entity.todo,
    completed: entity.completed,
    userId: entity.userId,
  );
}

@freezed
abstract class TodoListResponseModel with _$TodoListResponseModel {
  const factory TodoListResponseModel({
    required List<TodoModel> todos,
    required int total,
    required int skip,
    required int limit,
  }) = _TodoListResponseModel;

  factory TodoListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TodoListResponseModelFromJson(json);
}
