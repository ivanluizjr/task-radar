// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodoModel _$TodoModelFromJson(Map<String, dynamic> json) => _TodoModel(
  id: (json['id'] as num).toInt(),
  todo: json['todo'] as String,
  completed: json['completed'] as bool,
  userId: (json['userId'] as num).toInt(),
);

Map<String, dynamic> _$TodoModelToJson(_TodoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'todo': instance.todo,
      'completed': instance.completed,
      'userId': instance.userId,
    };

_TodoListResponseModel _$TodoListResponseModelFromJson(
  Map<String, dynamic> json,
) => _TodoListResponseModel(
  todos: (json['todos'] as List<dynamic>)
      .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$TodoListResponseModelToJson(
  _TodoListResponseModel instance,
) => <String, dynamic>{
  'todos': instance.todos,
  'total': instance.total,
  'skip': instance.skip,
  'limit': instance.limit,
};
