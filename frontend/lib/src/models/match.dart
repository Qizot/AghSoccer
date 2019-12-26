import 'package:equatable/equatable.dart';

class Match extends Equatable {
  final String sId;
  final String name;
  final String description;
  final bool confirmed;
  final String ownerId;
  final List<String> players;
  final DateTime startTime;
  final DateTime endTime;
  final bool isPrivate;

  Match(
      {this.sId,
        this.name,
        this.description,
        this.confirmed,
        this.ownerId,
        this.players,
        this.startTime,
        this.endTime,
        this.isPrivate});

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      sId: json['_id'],
      name: json['name'],
      description: json['description'],
      confirmed: json['confirmed'],
      ownerId: json['ownerId'],
      players: json['players'].cast<String>(),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isPrivate: json['isPrivate']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['confirmed'] = this.confirmed;
    data['ownerId'] = this.ownerId;
    data['players'] = this.players;
    data['startTime'] = this.startTime.toIso8601String();
    data['endTime'] = this.endTime.toIso8601String();
    data['isPrivate'] = this.isPrivate;
    return data;
  }

  @override
  List<Object> get props => [sId, name, description, confirmed, ownerId, players, startTime, endTime, isPrivate];
}