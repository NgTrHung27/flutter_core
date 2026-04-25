class ApiUrl {
  const ApiUrl._();
  //Base Domain
  static const domain = "nest-js-flutter-practise.onrender.com";
  static const baseDomain = "https://$domain"; //Test IP:
  // ifconfig | grep "inet " | grep -v 127.0.0.1
  // static const anotherIP = '172.16.1.205';
  // static const baseUrl = "http://$anotherIP:3000/api";

  // Local API URL
  static const baseIP = "8";
  static const baseUrl = "http://192.168.1.$baseIP:3000/api";

  // Production API URL
  static const apiProduction =
      "https://nest-js-flutter-practise.onrender.com/api";
  // Auth
  static const login = "/auth/login";

  // Isolate Demo
  static const isolateHeavyPayload = "/isolate-test/heavy-payload";
}
