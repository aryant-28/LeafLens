import 'package:flutter/material.dart';
import 'dart:convert';

class PlantReminder {
  final String id;
  final String plantName;
  final String notes;
  final TimeOfDay time;
  final bool isEnabled;

  PlantReminder({
    required this.id,
    required this.plantName,
    required this.notes,
    required this.time,
    this.isEnabled = true,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantName': plantName,
      'notes': notes,
      'time': '${time.hour}:${time.minute}',
      'isEnabled': isEnabled,
    };
  }

  // Create from JSON
  factory PlantReminder.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return PlantReminder(
      id: json['id'],
      plantName: json['plantName'],
      notes: json['notes'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  // Create a copy with updated values
  PlantReminder copyWith({
    String? plantName,
    String? notes,
    TimeOfDay? time,
    bool? isEnabled,
  }) {
    return PlantReminder(
      id: this.id,
      plantName: plantName ?? this.plantName,
      notes: notes ?? this.notes,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  // For list operations
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantReminder &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
