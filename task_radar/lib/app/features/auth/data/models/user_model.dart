import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

Object? _userModelReadCompanyName(Map json, String key) {
  final company = json['company'];
  if (company is Map<String, dynamic>) {
    return company['name'];
  }
  if (company is Map) {
    return company['name'];
  }
  return null;
}

Object? _userModelReadDepartment(Map json, String key) {
  final company = json['company'];
  if (company is Map<String, dynamic>) {
    return company['department'];
  }
  if (company is Map) {
    return company['department'];
  }
  return null;
}

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required int id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    String? image,
    @Default('moderator') String role,
    @JsonKey(readValue: _userModelReadCompanyName) String? companyName,
    @JsonKey(readValue: _userModelReadDepartment) String? department,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() => User(
    id: id,
    username: username,
    email: email,
    firstName: firstName,
    lastName: lastName,
    image: image,
    role: role,
    companyName: companyName,
    department: department,
  );

  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    username: user.username,
    email: user.email,
    firstName: user.firstName,
    lastName: user.lastName,
    image: user.image,
    role: user.role,
    companyName: user.companyName,
    department: user.department,
  );
}
