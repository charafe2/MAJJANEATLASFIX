class UserModel {
  final int    id;
  final String fullName;
  final String email;
  final String phone;
  final String accountType;
  final bool   isActive;

  const UserModel({
    required this.id,         required this.fullName,
    required this.email,      required this.phone,
    required this.accountType, required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id:          j['id'] as int,
    fullName:    j['full_name'] as String,
    email:       j['email'] as String,
    phone:       j['phone'] as String,
    accountType: j['account_type'] as String,
    isActive:    (j['is_active'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'full_name': fullName, 'email': email,
    'phone': phone, 'account_type': accountType, 'is_active': isActive,
  };
}