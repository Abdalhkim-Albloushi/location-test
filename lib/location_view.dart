import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_app/location_model.dart';
import 'package:http/http.dart' as http;
import 'package:location_app/result_view.dart';

class LocationView extends StatefulWidget {
  const LocationView({super.key});

  @override
  State<LocationView> createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  Marker? _start, _end;
  bool isLoding = false;
  late GoogleMapController _mapController;
  RouteModel? routeModel;
  final CameraPosition _initPosition = const CameraPosition(
    target: LatLng(23.5880, 58.3829),
    zoom: 12.0,
  );

  Future _getApiData(LatLng from, LatLng to) async {
    setState(() {
      isLoding = true;
    });
    try {
      const url = 'https://maps.googleapis.com/maps/api/directions/json?';
      const googleKey = 'xxxxxxxxxxxx';
      final res = await http.get(
        Uri.parse(
            '${url}origin=${from.latitude},${from.longitude}&destination=${to.latitude},${to.longitude}&key=$googleKey'),
      );

      if (res.statusCode != 200) return null;

      final data = loctionModelFromJson(res.body);
      if (data.routes?.isNotEmpty ?? false) {
        routeModel = data.routes?.first;
      }
      return;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 1));

      return;
    } finally {
      // --> i need some time when it offline because of set state <--

      setState(() {
        isLoding = false;
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  onLongPress(LatLng latLng) async {
    if (isLoding) return;
    final bool isSecondSelect =
        _start == null || (_end != null && _start != null);
    if (isSecondSelect) {
      _start = Marker(
        markerId: const MarkerId('start'),
        infoWindow: const InfoWindow(title: 'start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        position: latLng,
      );

      routeModel = null;
      _end = null;
      setState(() {});
    } else {
      _end = Marker(
        markerId: const MarkerId('end'),
        infoWindow: const InfoWindow(title: 'end'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        position: latLng,
      );

      await _getApiData(_start!.position, _end!.position);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNotReady = _start == null || _end == null || routeModel == null;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            routeModel = null;

            _end = null;
            _start = null;
            isLoding = false;
          });
        },
        child: const Text('Reset'),
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _initPosition,
              onMapCreated: (controller) => _mapController = controller,
              polylines: {
                if (routeModel != null)
                  Polyline(
                    polylineId: const PolylineId('distance'),
                    color: Colors.blue,
                    width: 5,
                    points: [
                      for (final item in routeModel!.overviewPolyline)
                        LatLng(item.latitude, item.longitude)
                    ],
                  ),
              },
              markers: {
                if (_start != null) _start!,
                if (_end != null) _end!,
              },
              onLongPress: onLongPress,
            ),
            if (routeModel != null) _Result(routeModel: routeModel),
            Positioned(
                bottom: 10,
                child: isLoding
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                      )
                    : routeModel != null && !isLoding
                        ? _NextBTN(
                            isNotReady: isNotReady, routeModel: routeModel)
                        : const SizedBox())
          ],
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.routeModel,
  });

  final RouteModel? routeModel;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      child: Column(
        children: [
          Text(routeModel!.time),
          Text(routeModel!.distance),
        ],
      ),
    );
  }
}

class _NextBTN extends StatelessWidget {
  const _NextBTN({
    required this.isNotReady,
    required this.routeModel,
  });

  final bool isNotReady;
  final RouteModel? routeModel;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        minWidth: MediaQuery.of(context).size.width / 2,
        height: 45,
        color: isNotReady ? Colors.grey : Colors.blue,
        onPressed: () {
          if (isNotReady) return;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ResultView(
                    time: routeModel?.time ?? '',
                    distance: routeModel?.distance ?? '',
                    loction1:
                        '${routeModel?.bounds.northeast.latitude} - ${routeModel?.bounds.northeast.longitude}',
                    loction2:
                        '${routeModel?.bounds.southwest.latitude} - ${routeModel?.bounds.southwest.longitude}',
                  )));
        },
        child: Text(
          'NEXT',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.white),
        ));
  }
}
