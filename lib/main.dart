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
  String host = 'ws://192.168.0.100:9090';
  late Ros ros;
  late Topic cmdVelTopic;
  late Topic autonomousTopic;
  late Topic batteryTopic;
  late Topic waypointTopic;

  double turnAngularVelocity = 1.5;
  double forwardVelocity = 0.2;
  double batteryPercentage = 0.0;

  bool isConnected = false;
  bool isAutonomousMode = false;

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

    autonomousTopic = Topic(
        ros: ros,
        name: '/autonomous',
        type: "std_msgs/msg/Bool",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);

    batteryTopic = Topic(
        ros: ros,
        name: '/battery_state',
        type: "sensor_msgs/BatteryState",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);


    waypointTopic = Topic(
        ros: ros,
        name: '/goal_pose',
        type: "geometry_msgs/msg/PoseStamped",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);

    batteryTopic.subscribe(batteryCallback);
    ros.connect();
  }

  Future<void> batteryCallback(Map<String, dynamic> message) async {
    setState(() {
      batteryPercentage = message['percentage'];
    });
  }


  Widget buildBatteryIndicator(double batteryPercentage) {
    Color batteryColor;
    if (batteryPercentage > 75) {
      batteryColor = Colors.green;
    } else if (batteryPercentage > 25) {
      batteryColor = Colors.yellow;
    } else {
      batteryColor = Colors.red;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.battery_charging_full, color: batteryColor, size: 24),
        SizedBox(width: 5),
        Text(
          '${batteryPercentage.toStringAsFixed(2)}%',
          style: TextStyle(fontSize: 18),
        )
      ],
    );
  }

  TextEditingController xController = TextEditingController();
  TextEditingController yController = TextEditingController();

  void sendWaypoint() {
    var waypoint = {
      'header': { 'frame_id': 'map' },
      'pose': {
        'position': {
          'x': double.parse(xController.text),
          'y': double.parse(yController.text),
          'z': 0.0
        },
        'orientation': {
          'x': 0.0,
          'y': 0.0,
          'z': 0.0,
          'w': 1.0
        }
      }
    };
    waypointTopic.publish(waypoint);
  }

  void toggleAutonomousMode() {
    setState(() {
      isAutonomousMode = !isAutonomousMode;
      var autonomyMessage = {"data": isAutonomousMode};
      autonomousTopic.publish(autonomyMessage);
    });
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
      angular = {'x': 0.0, 'y': 0.0, 'z': turnAngularVelocity};
    } else if (rightButtonState == -1) {
      angular = {'x': 0.0, 'y': 0.0, 'z': -turnAngularVelocity};
    } else if (forwardButtonState == -1) {
      linear = {'x': forwardVelocity, 'y': 0.0, 'z': 0.0};
    } else if (backwardButtonState == -1) {
      linear = {'x': -forwardVelocity, 'y': 0.0, 'z': 0.0};
    }
    var twist = {'linear': linear, 'angular': angular};
    if (lastDirectionTwist == twist &&
        twist['linear'] == {'x': 0.0, 'y': 0.0, 'z': 0.0} &&
        twist['angular'] == {'x': 0.0, 'y': 0.0, 'z': 0.0}) {
      return;
    }
    cmdVelTopic.publish(twist);
    lastDirectionTwist = twist;
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
        title: Text('${widget.title}'),
        actions: <Widget>[
          buildBatteryIndicator(batteryPercentage),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DirectionPad(
              diameter: 200,
              leftCallback: leftCallback,
              rightCallback: rightCallback,
              forwardCallback: forwardCallback,
              backwardCallback: backwardCallback,
            ),
            TextField(
              controller: xController,
              decoration: InputDecoration(labelText: 'X Coordinate'),
            ),
            TextField(
              controller: yController,
              decoration: InputDecoration(labelText: 'Y Coordinate'),
            ),
            ElevatedButton(
              onPressed: sendWaypoint,
              child: Text(
                'Send Waypoint',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleAutonomousMode,
        tooltip: isAutonomousMode ? 'Switch to Manual' : 'Switch to Autonomous',
        child: Icon(isAutonomousMode ? Icons.autorenew : Icons.directions_car),
      ),
    );
  }
}