class MatchFilter {
  DateTime timeFrom;
  DateTime timeTo;
  bool showPrivate;

  MatchFilter({this.timeFrom, this.timeTo, this.showPrivate});

  MatchFilter.fromJson(Map<String, dynamic> json) {
    timeFrom = DateTime.parse(json['timeFrom']);
    timeTo = DateTime.parse(json['timeTo']);
    showPrivate = json['showPrivate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timeFrom'] = this.timeFrom.toIso8601String();
    data['timeTo'] = this.timeTo.toIso8601String();
    data['showPrivate'] = this.showPrivate;
    return data;
  }
}