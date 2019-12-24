class CreateMatch {
  String name;
  String description;
  String password;
  DateTime startTime;
  DateTime endTime;

  CreateMatch(
      {this.name,
        this.description,
        this.password,
        this.startTime,
        this.endTime});

  CreateMatch.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    password = json['password'];
    startTime = DateTime.parse(json['startTime']);
    endTime = DateTime.parse(json['endTime']);
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
}

