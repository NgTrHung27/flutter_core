class ApiUrl {
  const ApiUrl._();

  //Test IP:
  // ifconfig | grep "inet " | grep -v 127.0.0.1
  static const anotherIP = '172.16.1.205';
  static const baseUrl = "http://$anotherIP:3000/api";

  static const baseIP = "2";
  //  static const baseUrl = "http://192.168.1.$baseIP:3000/api";

  // Auth
  static const login = "/auth/login";

  // Isolate Demo
  static const isolateHeavyPayload = "/isolate-test/heavy-payload";
}
