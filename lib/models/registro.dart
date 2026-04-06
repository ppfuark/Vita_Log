import 'package:equatable/equatable.dart';

class Registro extends Equatable {
  final String id;
  final String type;
  final String? imagePath;
  final double humorLevel;
  final String? note;
  final DateTime timestamp;
  final int steps;

  Registro({
    String? id,
    required this.type,
    this.imagePath,
    required this.humorLevel,
    this.note,
    DateTime? timestamp,
    required this.steps,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [
    id,
    type,
    imagePath,
    humorLevel,
    note,
    timestamp,
    steps,
  ];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type,
      "imagePath": imagePath,
      "humorLevel": humorLevel,
      "note": note,
      "timestamp": timestamp.millisecondsSinceEpoch,
      "steps": steps,
    };
  }

  factory Registro.fromMap(Map map) {
    return Registro(
      id: map['id'],
      type: map['type'],
      imagePath: map['imagePath'],
      humorLevel: map['humorLevel'],
      note: map['note'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      steps: map['steps'],
    );
  }
}
