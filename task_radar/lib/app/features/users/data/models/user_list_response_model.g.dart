// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserListResponseModel _$UserListResponseModelFromJson(
  Map<String, dynamic> json,
) => _UserListResponseModel(
  users: (json['users'] as List<dynamic>)
      .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$UserListResponseModelToJson(
  _UserListResponseModel instance,
) => <String, dynamic>{
  'users': instance.users,
  'total': instance.total,
  'skip': instance.skip,
  'limit': instance.limit,
};
