import 'package:care_circle/models/hivemodels.dart';
import 'package:hive_flutter/hive_flutter.dart';


class HiveDB {
  static const String usersBox = 'usersBox';
  static const String orphanagesBox = 'orphanagesBox';
  static const String requirementsBox = 'requirementsBox';
  static const String donationsBox = 'donationsBox';
  static const String notificationsBox = 'notificationsBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(OrphanageAdapter());
    Hive.registerAdapter(RequirementAdapter());
    Hive.registerAdapter(DonationAdapter());
    Hive.registerAdapter(NotificationAdapter());

    await Hive.openBox<User>(usersBox);
    await Hive.openBox<Orphanage>(orphanagesBox);
    await Hive.openBox<Requirement>(requirementsBox);
    await Hive.openBox<Donation>(donationsBox);
    await Hive.openBox<Notification>(notificationsBox);
  }

  static Box<User> get users => Hive.box<User>(usersBox);

  static Box<Orphanage> get orphanages =>
      Hive.box<Orphanage>(orphanagesBox);

  static Box<Requirement> get requirements =>
      Hive.box<Requirement>(requirementsBox);

  static Box<Donation> get donations =>
      Hive.box<Donation>(donationsBox);

  static Box<Notification> get notifications =>
      Hive.box<Notification>(notificationsBox);
}