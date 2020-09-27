import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class TimerApp extends StatefulWidget {
  final Timestamp timestamp;
  final int expiresIn;
  TimerApp({this.timestamp, this.expiresIn});
  @override
  _TimerAppState createState() =>
      _TimerAppState(timestamp: this.timestamp, expiresIn: this.expiresIn);
}

class _TimerAppState extends State<TimerApp> {
  final Timestamp timestamp;
  final int expiresIn;
  _TimerAppState({this.timestamp, this.expiresIn});

  static const duration = const Duration(seconds: 1);
  int secondsPassed = 36000;
  bool isActive = true;
  Timer timer;
  void handleTick() {
    if (isActive) {
      setState(() {
        secondsPassed = secondsPassed - 1;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    int seconds = this
        .timestamp
        .toDate()
        .add(Duration(hours: expiresIn))
        .difference(new DateTime.now())
        .inSeconds;
    secondsPassed = seconds;
    handleTick();
  }

  @override
  Widget build(BuildContext context) {
    if (timer == null) {
      timer = Timer.periodic(duration, (Timer t) {
        handleTick();
      });
    }
    String _printDuration() {
      Duration duration = new Duration(seconds: secondsPassed);
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return int.parse(twoDigits(duration.inHours)) < 0 &&
              int.parse(twoDigitMinutes) < 0 &&
              int.parse(twoDigitSeconds) < 0
          ? ""
          : "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _printDuration() == "" ? Text("") : Icon(Icons.timer),
        SizedBox(
          width: 5,
        ),
        Text(_printDuration())
      ],
    );
  }
}
