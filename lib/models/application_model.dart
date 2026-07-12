import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { pending, shortlisted, accepted, rejected }

class ApplicationModel {
  final String id;
  final String studentId;
  final String opportunityId;
  final ApplicationStatus status;
  final DateTime appliedAt;

  const ApplicationModel({
    required this.id,
    required this.studentId,
    required this.opportunityId,
    this.status = ApplicationStatus.pending,
    required this.appliedAt,
  });

  // Convert Flutter object → Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'opportunityId': opportunityId,
      'status': status.name,
      'appliedAt': Timestamp.fromDate(appliedAt),
    };
  }

  // Convert Firebase → Flutter object
  factory ApplicationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ApplicationModel(
      id: id,
      studentId: data['studentId'] ?? '',
      opportunityId: data['opportunityId'] ?? '',
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
    );
  }
}
