

class ApiConfig {
  String apiUri;

  factory ApiConfig({String apiUri}){
    if (ApiConfig._instance == null) {
      ApiConfig._instance = ApiConfig._privateConstructor(apiUri: apiUri);
    }
    return _instance;
  }

  ApiConfig._privateConstructor({this.apiUri});

  static ApiConfig _instance;

  static ApiConfig get instance { return _instance;}

}