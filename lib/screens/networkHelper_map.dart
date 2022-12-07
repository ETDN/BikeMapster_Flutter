import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:http_requests/http_requests.dart';

class NetworkHelper {
  NetworkHelper(
      {required this.startLng,
      required this.startLat,
      required this.endLng,
      required this.endLat});

  final String url = 'https://api.openrouteservice.org/v2/directions/';
  final String apiKey =
      '5b3ce3597851110001cf6248c376574b5ab44180aa6d43c730a6b40c';
  final String pathParam =
      'cycling-road'; // other possibilities : cycling-mountain, cycling-electric,...
  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;

  Future getData() async {
    http.Response response = await http.get(Uri.parse(
        '$url$pathParam?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat'));
    // Response response = await HttpRequests.get(
    //     '$url$pathParam?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat');
    // print("HI from networkHelper_map.dart");
    // print(response.body);
    if (response.statusCode == 200) {
      var data = response.body;
      return jsonDecode(data);
    } else {
      print("ERROR founded : ");
      print(response.statusCode);
    }
  }
}
