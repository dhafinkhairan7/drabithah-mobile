class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String role;
  final String status;
  final String? avatar;
  final String? resetToken;
  final DateTime? resetTokenEx;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.role = 'user',
    this.status = 'Belum Verifikasi',
    this.avatar,
    this.resetToken,
    this.resetTokenEx,
    this.createdAt,
    this.updatedAt,
  });

  // Constructor untuk login (tanpa password)
  User.login({
    required this.id,
    required this.username,
    required this.email,
    this.role = 'user',
    this.status = 'Belum Verifikasi',
    this.avatar,
    this.createdAt,
    this.updatedAt,
  }) : password = '',
     resetToken = null,
     resetTokenEx = null;

  factory User.fromJson(Map<String, dynamic> json) {
    return User.login(
      id: json['id'] as int?,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      status: json['status'] as String? ?? 'Belum Verifikasi',
      avatar: json['avatar'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'status': status,
      'avatar': avatar,
      'reset_token': resetToken,
      'reset_token_ex': resetTokenEx?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toRegistrationJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'status': status,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? role,
    String? status,
    String? avatar,
    String? resetToken,
    DateTime? resetTokenEx,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      status: status ?? this.status,
      avatar: avatar ?? this.avatar,
      resetToken: resetToken ?? this.resetToken,
      resetTokenEx: resetTokenEx ?? this.resetTokenEx,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, role: $role, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode ^ email.hashCode;
  }
}
