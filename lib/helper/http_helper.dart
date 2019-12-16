import 'dart:io';

import 'package:http/io_client.dart';

class HttpHelper {

  static IOClient myHttpClient;

  static void initClient() {
    // Make sure to replace <YOUR_LOCAL_IP> with
// the external IP of your computer if you're using Android.
// Note that we're using port 8888 which is Charles' default.
    String proxy = Platform.isAndroid ? '10.0.2.2:9080' : 'localhost:9080';

// Create a new HttpClient instance.
    HttpClient httpClient = new HttpClient();

// Hook into the findProxy callback to set
// the client's proxy.
    httpClient.findProxy = (uri) {
      return "PROXY $proxy;";
    };

// This is a workaround to allow Charles to receive
// SSL payloads when your app is running on Android.
    httpClient.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => Platform.isAndroid);

    myHttpClient = IOClient(httpClient);
  }
}
