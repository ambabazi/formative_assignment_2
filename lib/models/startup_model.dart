class StartupModel {
  final String id;
  final String companyName;
  final String description;
  final String industry;
  final String location;
  final String website;
  final String adminId;
  final bool verified;

  const StartupModel({
    required this.id,
    required this.companyName,
    required this.description,
    this.industry = '',
    this.location = '',
    this.website = '',
    required this.adminId,
    this.verified = false,
  });

  StartupModel copyWith({bool? verified}) {
    return StartupModel(
      id: id,
      companyName: companyName,
      description: description,
      industry: industry,
      location: location,
      website: website,
      adminId: adminId,
      verified: verified ?? this.verified,
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
    );
  }
}
