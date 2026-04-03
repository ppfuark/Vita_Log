import 'package:equatable/equatable.dart';

class Config extends Equatable {
  final int stepsGoal;
  final String userName;
  final bool notification;
  final bool darkTheme;

  const Config({
    int? stepsGoal,
    String? userName,
    bool? notification,
    bool? darkTheme,
  }) : stepsGoal = stepsGoal ?? 1000,
       userName = userName ?? "",
       notification = notification ?? false,
       darkTheme = darkTheme ?? true;

  @override
  List<Object?> get props => [stepsGoal, userName, notification, darkTheme];

  Map<String, dynamic> toMap() {
    return {
      "stepsGoal": stepsGoal,
      "userName": userName,
      "notification": notification,
      "darkTheme": darkTheme,
    };
  }

  factory Config.fromMap(Map<String, dynamic> map) {
    return Config(
      stepsGoal: map["stepsGoal"],
      userName: map["userName"],
      notification: map["notification"],
      darkTheme: map["darkTheme"],
    );
  }
}
