import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';



class LocationPermission extends StatefulWidget {
  @override
  _LocationPermissionExampleState createState() =>
      _LocationPermissionExampleState();
}

class _LocationPermissionExampleState extends State<LocationPermission> {
  PermissionStatus _locationPermissionStatus = PermissionStatus.granted;

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
  }

  // Check if location permission is already granted
  Future<void> checkLocationPermission() async {
    final status = await Permission.location.status;
    setState(() {
      _locationPermissionStatus = status;
    });
  }

  // Request location permission
  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    setState(() {
      _locationPermissionStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Permission Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Location Permission Status: $_locationPermissionStatus',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                if (_locationPermissionStatus.isGranted) {
                  // Location permission is already granted, you can take a picture here.
                  // Replace this with your picture-taking logic.
                  // For example, you can use the camera package to take pictures.
                } else {
                  // Request location permission
                  requestLocationPermission();
                }
              },
              child: Text('Take Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
