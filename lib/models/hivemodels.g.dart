// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hivemodels.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      password: fields[3] as String,
      phone: fields[4] as String,
      role: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.role);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrphanageAdapter extends TypeAdapter<Orphanage> {
  @override
  final int typeId = 1;

  @override
  Orphanage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Orphanage(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      address: fields[3] as String,
      description: fields[4] as String,
      image: fields[5] as String,
      verified: fields[6] as bool,
      district: fields[7] as String,
      category: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Orphanage obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.image)
      ..writeByte(6)
      ..write(obj.verified)
      ..writeByte(7)
      ..write(obj.district)
      ..writeByte(8)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrphanageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RequirementAdapter extends TypeAdapter<Requirement> {
  @override
  final int typeId = 2;

  @override
  Requirement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Requirement(
      id: fields[0] as String,
      orphanageId: fields[1] as String,
      item: fields[2] as String,
      category: fields[3] as String,
      quantity: fields[4] as int,
      priority: fields[5] as String,
      status: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Requirement obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orphanageId)
      ..writeByte(2)
      ..write(obj.item)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequirementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DonationAdapter extends TypeAdapter<Donation> {
  @override
  final int typeId = 3;

  @override
  Donation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Donation(
      id: fields[0] as String,
      donorId: fields[1] as String,
      orphanageId: fields[2] as String,
      requirementId: fields[3] as String,
      item: fields[4] as String,
      quantity: fields[5] as int,
      date: fields[6] as DateTime,
      status: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Donation obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.donorId)
      ..writeByte(2)
      ..write(obj.orphanageId)
      ..writeByte(3)
      ..write(obj.requirementId)
      ..writeByte(4)
      ..write(obj.item)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationAdapter extends TypeAdapter<Notification> {
  @override
  final int typeId = 4;

  @override
  Notification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Notification(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      message: fields[3] as String,
      isRead: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Notification obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
