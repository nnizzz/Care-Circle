import 'package:hive/hive.dart';

part 'hivemodels.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String password;

  @HiveField(4)
  String phone;

  @HiveField(5)
  String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });
}

@HiveType(typeId: 1)
class Orphanage extends HiveObject {
  @HiveField(0)
  String id;

  // Connects the orphanage profile to the User account
  @HiveField(1)
  String userId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String address;

  @HiveField(4)
  String description;

  @HiveField(5)
  String image;

  @HiveField(6)
  bool verified;

  @HiveField(7)
  String district;

  @HiveField(8)
String category;

  Orphanage({
    required this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.description,
    required this.image,
    required this.verified,
    required this.district,
    required this.category,
  });
}

@HiveType(typeId: 2)
class Requirement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String orphanageId;

  @HiveField(2)
  String item;

  @HiveField(3)
  String category;

  @HiveField(4)
  int quantity;

  @HiveField(5)
  String priority;

  @HiveField(6)
  String status;

  Requirement({
    required this.id,
    required this.orphanageId,
    required this.item,
    required this.category,
    required this.quantity,
    required this.priority,
    required this.status,
  });
}

@HiveType(typeId: 3)
class Donation extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String donorId;

  @HiveField(2)
  String orphanageId;

  @HiveField(3)
  String requirementId;

  @HiveField(4)
  String item;

  @HiveField(5)
  int quantity;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  String status;

  Donation({
    required this.id,
    required this.donorId,
    required this.orphanageId,
    required this.requirementId,
    required this.item,
    required this.quantity,
    required this.date,
    required this.status,
  });
}

@HiveType(typeId: 4)
class Notification extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String message;

  @HiveField(4)
  bool isRead;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
  });
}