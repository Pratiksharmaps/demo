

import 'package:demo/models/role.dart';

class UserModel {
  late String? name;
  late String? email;
  late String? uid;
  late Role? role;

  UserModel({required this.name, this.email, this.uid, this.role});

  factory UserModel.fromJson(dynamic json) {
    return UserModel(
        name: json['name'],
        email: json['email'],
        uid: json['uid'],
        role: Role.values
            .firstWhere((role) => role.toString() == 'Role.${json['role']}'));
  }
}
