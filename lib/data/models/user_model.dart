import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    @JsonKey(name: 'full_name') required String fullName,
    required String role,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// User roles enum
enum UserRole {
  @JsonValue('ADMIN')
  admin,
  @JsonValue('KASIR')
  kasir,
}

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.kasir:
        return 'KASIR';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'KASIR':
        return UserRole.kasir;
      default:
        return UserRole.kasir;
    }
  }
}
