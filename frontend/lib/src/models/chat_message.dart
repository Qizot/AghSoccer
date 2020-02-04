class ChatMessage {
  String nickname;
  DateTime timestamp;
  String message;

  ChatMessage({this.nickname, this.timestamp, this.message});

  ChatMessage.fromJson(Map<String, dynamic> json) {
    nickname = json['nickname'];
    timestamp = DateTime.parse(json['timestamp']);
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nickname'] = this.nickname;
    data['timestamp'] = this.timestamp.toIso8601String();
    data['message'] = this.message;
    return data;
  }
}