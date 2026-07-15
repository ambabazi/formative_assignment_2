enum UserRole { student, startupAdmin, admin }

class UserModel {
  final String uuid;
  final String email;
  final String names;
  final UserRole role;
  final String location;
  final List<String> skills;
  final bool onboardingComplete;
  final String startupId;

  const UserModel({
    required this.uuid,
    required this.email,
    required this.names,
    required this.role,
    this.location = "",
    this.skills = const [],
    this.onboardingComplete = false,
    this.startupId = "",
  });

  UserModel copyWith({
    String? names,
    String? location,
    List<String>? skills,
    bool? onboardingComplete,
    String? startupId,
  }) {
    return UserModel(
      uuid: uuid,
      email: email,
      names: names ?? this.names,
      role: role,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      startupId: startupId ?? this.startupId,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'names': names,
      'role': role.name,
      'location': location,
      'skills': skills,
      'onboardingComplete': onboardingComplete,
      'startupId': startupId,
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
      onboardingComplete: data['onboardingComplete'] ?? false,
      startupId: data['startupId'] ?? '',
    );
  }
}
