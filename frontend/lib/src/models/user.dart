class User {
  String sId;
  String email;
  String nickname;
  List<String> matchesPlayed;
  List<String> roles;

  User({this.sId, this.email, this.nickname, this.matchesPlayed, this.roles});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    nickname = json['nickname'];
    matchesPlayed = json['matchesPlayed'].cast<String>();
    roles = json['roles'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['email'] = this.email;
    data['nickname'] = this.nickname;
    data['matchesPlayed'] = this.matchesPlayed;
    data['roles'] = this.roles;
    return data;
  }
}