import 'package:flutter/material.dart';
import 'pad.dart';
import 'package:roslibdart/roslibdart.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = 'ROS-Remote-Pad';
    return MaterialApp(
      title: title,
      home: RoslibPSPad(title: title),
    );
  }
}

class RoslibPSPad extends StatefulWidget {
  const RoslibPSPad({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<RoslibPSPad> createState() => _RoslibPSPadState();
}

class _RoslibPSPadState extends State<RoslibPSPad> {
  String host = 'ws://192.168.2.6:9090';
  late Ros ros;
  late Topic cmdVelTopic;
  double turnAngularVelocity = 1.5;
  double forwardVelocity = 0.2;

  bool isConnected = false;

  @override
  void initState() {
    ros = Ros(url: host);
    cmdVelTopic = Topic(
        ros: ros,
        name: '/cmd_vel',
        type: "geometry_msgs/msg/Twist",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);

    ros.connect();
    super.initState();
    Timer.periodic(const Duration(milliseconds: 200), directionFired);
  }



  int leftButtonState = 1;
  int rightButtonState = 1;
  int forwardButtonState = 1;
  int backwardButtonState = 1;

  var lastDirectionTwist = {};

  void directionFired(Timer timer) {
    var linear = {'x': 0.0, 'y': 0.0, 'z': 0.0};
    var angular = {'x': 0.0, 'y': 0.0, 'z': 0.0};
    if (leftButtonState == -1) {
      linear = {'x': 0.0, 'y': 0.0, 'z': 0.0};
      angular = {'x': 0.0, 'y': 0.0, 'z': turnAngularVelocity};
    } else if (rightButtonState == -1) {
      linear = {'x': 0.0, 'y': 0.0, 'z': 0.0};
      angular = {'x': 0.0, 'y': 0.0, 'z': -turnAngularVelocity};
    } else if (forwardButtonState == -1) {
      linear = {'x': forwardVelocity, 'y': 0.0, 'z': 0.0};
      angular = {'x': 0.0, 'y': 0.0, 'z': 0};
    } else if (backwardButtonState == -1) {
      linear = {'x': -forwardVelocity, 'y': 0.0, 'z': 0.0};
      angular = {'x': 0.0, 'y': 0.0, 'z': 0};
    }
    var twist = {'linear': linear, 'angular': angular};
    if (lastDirectionTwist == twist &&
        twist['linear'] == {'x': 0.0, 'y': 0.0, 'z': 0.0} &&
        twist['angular'] == {'x': 0.0, 'y': 0.0, 'z': 0.0}) {
      return;
    }
    cmdVelTopic.publish(twist);
    lastDirectionTwist = twist;
    print(ros.status.toString());
  }


  void leftCallback(int event) {
    leftButtonState = event;
  }

  void rightCallback(int event) {
    rightButtonState = event;
  }

  void forwardCallback(int event) {
    forwardButtonState = event;
  }

  void backwardCallback(int event) {
    backwardButtonState = event;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center( // This centers its child vertically and horizontally within the Scaffold's available space.
        child: DirectionPad(
          diameter: 200, // This is your specified size for the DirectionPad.
          leftCallback: leftCallback,
          rightCallback: rightCallback,
          forwardCallback: forwardCallback,
          backwardCallback: backwardCallback,
        ),
      ),
    );
  }
}
