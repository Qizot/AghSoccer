class Match {
  String sId;
  String name;
  String description;
  bool confirmed;
  String ownerId;
  List<String> players;
  DateTime startTime;
  DateTime endTime;
  bool isPrivate;

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

  Match.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    confirmed = json['confirmed'];
    ownerId = json['ownerId'];
    players = json['players'].cast<String>();
    startTime = DateTime.parse(json['startTime']);
    endTime = DateTime.parse(json['endTime']);
    isPrivate = json['isPrivate'];
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
}