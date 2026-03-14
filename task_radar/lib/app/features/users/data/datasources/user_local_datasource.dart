import 'package:sqflite/sqflite.dart';
import 'package:task_radar/app/core/errors/exceptions.dart';
import 'package:task_radar/app/features/auth/data/models/user_model.dart';

abstract class UserLocalDataSource {
  Future<void> cacheUsers(List<UserModel> users);
  Future<List<UserModel>> getCachedUsers({
    required int limit,
    required int skip,
  });
  Future<int> getTotalCount();
  Future<UserModel?> getUserById(int id);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final Database _db;

  UserLocalDataSourceImpl(this._db);

  @override
  Future<void> cacheUsers(List<UserModel> users) async {
    try {
      final batch = _db.batch();
      for (final user in users) {
        batch.insert('users', {
          'id': user.id,
          'username': user.username,
          'email': user.email,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'image': user.image,
          'role': user.role,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    } catch (e) {
      throw const CacheException('Erro ao salvar usuários em cache');
    }
  }

  @override
  Future<List<UserModel>> getCachedUsers({
    required int limit,
    required int skip,
  }) async {
    try {
      final result = await _db.query(
        'users',
        limit: limit,
        offset: skip,
        orderBy: 'id ASC',
      );
      return result.map(_mapToUserModel).toList();
    } catch (e) {
      throw const CacheException('Erro ao buscar usuários do cache');
    }
  }

  @override
  Future<int> getTotalCount() async {
    final result = await _db.query('users', columns: ['COUNT(*) as count']);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<UserModel?> getUserById(int id) async {
    final result = await _db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return _mapToUserModel(result.first);
  }

  UserModel _mapToUserModel(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      username: map['username'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      image: map['image'] as String?,
      role: map['role'] as String,
    );
  }
}
