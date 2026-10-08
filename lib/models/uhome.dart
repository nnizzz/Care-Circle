class UrgentRequirement {
  final String item;
  final String needed;
  final String icon;

  UrgentRequirement({
    required this.item,
    required this.needed,
    required this.icon,
  });
}


class Orphanage {
  final String name;
  final String location;
  final String distance;
  final String image;

  Orphanage({
    required this.name,
    required this.location,
    required this.distance,
    required this.image,
  });
}


class RecentDonation {
  final String item;
  final int quantity;
  final String status;

  RecentDonation({
    required this.item,
    required this.quantity,
    required this.status,
  });
}