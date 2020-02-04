

class ApiConfig {
  String apiUri;
  String chatUri;

  factory ApiConfig({String apiUri, String chatUri}){
    if (ApiConfig._instance == null) {
      ApiConfig._instance = ApiConfig._privateConstructor(apiUri: apiUri, chatUri: chatUri);
    }
    return _instance;
  }

  ApiConfig._privateConstructor({this.apiUri, this.chatUri});

  static ApiConfig _instance;

  static ApiConfig get instance { return _instance;}

}