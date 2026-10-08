class Orphanages {
  final String id;
  final String name;
  final String image;
  final String location;
  final String area;
  final double distance;
  final String description;
  final int childrenCount;
  final String phone;
  final int establishedYear;
  final bool verified;
  final double latitude;
  final double longitude;
  final List<String> photos;
  final List<OrphanageNeed> needs;
  final List<OrphanageNeed> urgentNeeds;

  Orphanages({
    required this.id,
    required this.name,
    required this.image,
    required this.location,
    required this.area,
    required this.distance,
    required this.description,
    required this.childrenCount,
    required this.phone,
    required this.establishedYear,
    required this.verified,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.needs,
    required this.urgentNeeds,
  });
}

class OrphanageNeed {
  final String id;
  final String itemName;
  final String icon;
  final int requiredQuantity;
  final int receivedQuantity;
  final String unit;
  final bool urgent;
  final String description;

  OrphanageNeed({
    required this.id,
    required this.itemName,
    required this.icon,
    required this.requiredQuantity,
    required this.receivedQuantity,
    required this.unit,
    required this.urgent,
    required this.description,
  });

  int get remainingQuantity {
    return requiredQuantity - receivedQuantity;
  }

  double get progress {
    if (requiredQuantity == 0) {
      return 0;
    }

    return receivedQuantity / requiredQuantity;
  }
}