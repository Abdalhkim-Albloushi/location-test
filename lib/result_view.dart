
import 'package:flutter/material.dart';

class ResultView extends StatelessWidget {
  const ResultView(
      {super.key,
      required this.distance,
      required this.time,
      required this.loction1,
      required this.loction2});

  final String distance, time, loction1, loction2;

  @override
  Widget build(BuildContext context) {
    int timeWalking = 0;
    final pureKM = distance.onlyKM;
    timeWalking = (12 * double.parse(pureKM)).round();
    final hour = timeWalking.walkingTime;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CustomItem(
              iconData: Icons.map,
              title: 'Point1',
              text: loction1,
            ),
            _CustomItem(
              iconData: Icons.map,
              title: 'Point2',
              text: loction2,
            ),
            _CustomItem(
              iconData: Icons.lock_clock,
              title: 'Time',
              text: time,
            ),
            _CustomItem(
              iconData: Icons.car_repair,
              title: 'By Car',
              text: distance,
            ),
            _CustomItem(
              iconData: Icons.nordic_walking,
              title: 'By Walk',
              text: hour.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomItem extends StatelessWidget {
  const _CustomItem(
      {required this.iconData, required this.text, required this.title});
  final IconData iconData;
  final String text, title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(iconData),
              Text(title),
            ],
          ),
          Text(text),
        ],
      ),
    );
  }
}

extension GetWalk on int {
  String get walkingTime {
    final data = this;
    String t = '';
    final int hour = data ~/ 60;
    final int minutes = data % 60;
    final h = hour.toString();
    if (h != '0') {
      t += '$h hour';
    }

    return '$t $minutes mins';
  }
}

extension GetKM on String {
  String get onlyKM => split(' ').first.replaceAll(',', '');
}
