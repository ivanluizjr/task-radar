import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_radar/app/features/auth/data/models/user_model.dart';

part 'user_list_response_model.freezed.dart';
part 'user_list_response_model.g.dart';

@freezed
abstract class UserListResponseModel with _$UserListResponseModel {
  const factory UserListResponseModel({
    required List<UserModel> users,
    required int total,
    required int skip,
    required int limit,
  }) = _UserListResponseModel;

  factory UserListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserListResponseModelFromJson(json);
}
