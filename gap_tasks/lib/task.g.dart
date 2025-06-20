// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      title: fields[0] as String,
      desc: fields[1] as String,
      priority: fields[2] as String,
      tag: fields[3] as String,
      estimatedMinutes: fields[4] as int,
      deadline: fields[5] as DateTime?,
      scheduled: fields[6] as DateTime?,
      completed: fields[7] as bool,
      dependencies: (fields[8] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
      attachments: (fields[9] as List?)?.cast<String>(),
      feedback: fields[10] as String?,
      recurring: fields[14] as String?,
      recurringDays: (fields[15] as List?)?.cast<int>(),
    )
      ..startTime = fields[11] as DateTime?
      ..completedTime = fields[12] as DateTime?
      ..logs = (fields[13] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.desc)
      ..writeByte(2)
      ..write(obj.priority)
      ..writeByte(3)
      ..write(obj.tag)
      ..writeByte(4)
      ..write(obj.estimatedMinutes)
      ..writeByte(5)
      ..write(obj.deadline)
      ..writeByte(6)
      ..write(obj.scheduled)
      ..writeByte(7)
      ..write(obj.completed)
      ..writeByte(8)
      ..write(obj.dependencies)
      ..writeByte(9)
      ..write(obj.attachments)
      ..writeByte(10)
      ..write(obj.feedback)
      ..writeByte(11)
      ..write(obj.startTime)
      ..writeByte(12)
      ..write(obj.completedTime)
      ..writeByte(13)
      ..write(obj.logs)
      ..writeByte(14)
      ..write(obj.recurring)
      ..writeByte(15)
      ..write(obj.recurringDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
