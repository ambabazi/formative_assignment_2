class StartupModel {
  final String id;
  final String companyName;
  final String description;
  final String industry;
  final String location;
  final String website;
  final String adminId;
  final bool verified;
  final bool rejected;

  const StartupModel({
    required this.id,
    required this.companyName,
    required this.description,
    this.industry = '',
    this.location = '',
    this.website = '',
    required this.adminId,
    this.verified = false,
    this.rejected = false,
  });

  StartupModel copyWith({bool? verified, bool? rejected}) {
    return StartupModel(
      id: id,
      companyName: companyName,
      description: description,
      industry: industry,
      location: location,
      website: website,
      adminId: adminId,
      verified: verified ?? this.verified,
      rejected: rejected ?? this.rejected,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'companyName': companyName,
      'description': description,
      'industry': industry,
      'location': location,
      'website': website,
      'adminId': adminId,
      'verified': verified,
      'rejected': rejected,
    };
  }

  factory StartupModel.fromFirestore(Map<String, dynamic> data, String id) {
    return StartupModel(
      id: id,
      companyName: data['companyName'] ?? '',
      description: data['description'] ?? '',
      industry: data['industry'] ?? '',
      location: data['location'] ?? '',
      website: data['website'] ?? '',
      adminId: data['adminId'] ?? '',
      verified: data['verified'] ?? false,
      rejected: data['rejected'] ?? false,
    );
  }
}
