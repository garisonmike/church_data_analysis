import 'package:equatable/equatable.dart';

/// Represents an admin user who can manage church data
class AdminUser extends Equatable {
  final int? id;
  final String username;
  final String fullName;
  final String? email;
  final int churchId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const AdminUser({
    this.id,
    required this.username,
    required this.fullName,
    this.email,
    required this.churchId,
    this.isActive = true,
    required this.createdAt,
    required this.lastLoginAt,
  });

  /// Creates a copy of this AdminUser with updated fields
  AdminUser copyWith({
    int? id,
    String? username,
    String? fullName,
    String? email,
    int? churchId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      churchId: churchId ?? this.churchId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Converts this AdminUser to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'churchId': churchId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  /// Creates an AdminUser from a JSON map
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int?,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      churchId: json['churchId'] as int,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
    );
  }

  /// Validates the admin user model
  String? validate() {
    if (username.trim().isEmpty) {
      return 'Username cannot be empty';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (username.length > 50) {
      return 'Username cannot exceed 50 characters';
    }
    if (fullName.trim().isEmpty) {
      return 'Full name cannot be empty';
    }
    if (fullName.length > 100) {
      return 'Full name cannot exceed 100 characters';
    }
    if (email != null && email!.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email!)) {
        return 'Invalid email format';
      }
    }
    if (churchId <= 0) {
      return 'Invalid church ID';
    }
    return null;
  }

  /// Checks if this admin user model is valid
  bool isValid() => validate() == null;

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    email,
    churchId,
    isActive,
    createdAt,
    lastLoginAt,
  ];
}
