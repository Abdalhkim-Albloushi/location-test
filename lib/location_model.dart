import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

LoctionModel loctionModelFromJson(String str) =>
    LoctionModel.fromJson(json.decode(str));

String loctionModelToJson(LoctionModel data) => json.encode(data.toJson());

class LoctionModel {
  List<RouteModel>? routes;

  LoctionModel({
    this.routes,
  });

  factory LoctionModel.fromJson(Map<String, dynamic> json) => LoctionModel(
        routes: List<RouteModel>.from(
            json["routes"].map((x) => RouteModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "routes": List<dynamic>.from(routes!.map((x) => x.toJson())),
      };
}

class RouteModel {
  LatLngBounds bounds;
  String copyrights;
  String distance;
  String time;
  List<PointLatLng> overviewPolyline;

  RouteModel({
    required this.bounds,
    required this.copyrights,
    required this.distance,
    required this.time,
    required this.overviewPolyline,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        bounds: LatLngBounds(
          southwest: LatLng(json['bounds']['southwest']['lat'],
              json['bounds']['southwest']['lng']),
          northeast: LatLng(json['bounds']['northeast']['lat'],
              json['bounds']['northeast']['lng']),
        ),
        copyrights: json["copyrights"],
        distance: json["legs"][0]["distance"]["text"],
        time: json["legs"][0]["duration"]["text"],
        overviewPolyline: PolylinePoints()
            .decodePolyline(json["overview_polyline"]['points']),
      );

  Map<String, dynamic> toJson() => {
        "bounds": bounds,
        "copyrights": copyrights,
        "distance": distance,
        "duration": time,
        "overview_polyline": overviewPolyline,
      };
}
