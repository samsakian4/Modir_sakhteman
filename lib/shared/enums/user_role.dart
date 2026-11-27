enum UserRole {
  admin('admin', 'مدیر ساختمان'),
  resident('resident', 'ساکن');

  const UserRole(this.dbValue, this.label);
  final String dbValue;
  final String label;

  static UserRole fromDbValue(String value) => UserRole.values.firstWhere((r) => r.dbValue == value, orElse: () => UserRole.resident);
  bool get isAdmin => this == UserRole.admin;
  bool get isResident => this == UserRole.resident;
}
