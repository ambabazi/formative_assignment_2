import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum OpportunityStatus { open, closed }

class OpportunityModel {
  final String id;
  final String startupId;
  final String title;
  final String description;
  final String location;
  final List<String> skillsRequired;
  final OpportunityStatus status;

  const OpportunityModel({
    required this.id,
    required this.startupId,
    required this.title,
    required this.description,
    this.location = "",
    this.skillsRequired = const [],
    this.status = OpportunityStatus.open,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'startupId': startupId,
      'title': title,
      'description': description,
      'location': location,
      'skillsRequired': skillsRequired,
      'status': status.name,
    };
  }

  factory OpportunityModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OpportunityModel(
      id: id,
      startupId: data['startupId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      skillsRequired: List<String>.from(data['skillsRequired'] ?? []),
      status: OpportunityStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => OpportunityStatus.open,
      ),
    );
  }
}
