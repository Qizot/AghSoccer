import 'package:equatable/equatable.dart';

class CreateEditMatch extends Equatable {
  final String name;
  final String description;
  final String password;
  final DateTime startTime;
  final DateTime endTime;

  CreateEditMatch({
    this.name,
    this.description,
    this.password,
    this.startTime,
    this.endTime
  });

  factory CreateEditMatch.fromJson(Map<String, dynamic> json) {
    return CreateEditMatch(
      name: json['name'],
      description: json['description'],
      password: json['password'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime'])
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    data['password'] = this.password;
    data['startTime'] = this.startTime.toIso8601String();
    data['endTime'] = this.endTime.toIso8601String();
    return data;
  }

  @override
  List<Object> get props => [name, description, password, startTime, endTime];
}

