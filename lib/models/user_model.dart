import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum UserRole { student, startupAdmin }

class UserModel {
  final String uuid;
  final String email;
  final String names;
  final UserRole role;
  final String location;
  final List<String> skills;

  const UserModel({
    required this.uuid,
    required this.email,
    required this.names,
    required this.role,
    this.location = "",
    this.skills = const [],
  });

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'names': names,
      'role': role,
      'location': location,
      'skills': skills,
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uuid) {
    return UserModel(
      uuid: uuid,
      email: data['email'] ?? '',
      names: data['names'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => UserRole.student,
      ),
      location: data['location'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
    );
  }
}
