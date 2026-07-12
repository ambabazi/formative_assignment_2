class StartupModel {
  final String id;
  final String companyName;
  final String description;
  final String industry;
  final String location;
  final String website;

  const StartupModel({
    required this.id,
    required this.companyName,
    required this.description,
    this.industry = '',
    this.location = '',
    this.website = '',
  });

  // Convert Flutter object → Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'companyName': companyName,
      'description': description,
      'industry': industry,
      'location': location,
      'website': website,
    };
  }

  // Convert Firebase → Flutter object
  factory StartupModel.fromFirestore(Map<String, dynamic> data, String id) {
    return StartupModel(
      id: id,
      companyName: data['companyName'] ?? '',
      description: data['description'] ?? '',
      industry: data['industry'] ?? '',
      location: data['location'] ?? '',
      website: data['website'] ?? '',
    );
  }
}
