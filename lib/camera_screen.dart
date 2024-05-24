import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../config/database_config.dart';
import '../services/database_service.dart';
import '../utils/progress_dialog.dart';
import '../utils/snackbars.dart';
import 'package:intl/intl.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> cameras;
  late Future<CameraController> cameraFuture;
  late XFile? picture;
  bool pictureTaken = false;

  String? _currentAddress;
  Position? _currentPosition;
  final databaseService = DatabaseService();
  Future<CameraController> initCamera() async {
    cameras = await availableCameras();
    final cameraController = CameraController(cameras[0], ResolutionPreset.max);
    await cameraController.initialize();
    return cameraController;
  }

  @override
  void initState() {
    cameraFuture = initCamera();
    _getCurrentPosition();
    super.initState();
  }

  Future<void> _getCurrentPosition() async {
    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      Snackbars.error(context, 'Location service is not enabled');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        Snackbars.error(context, 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      Snackbars.error(context,
          'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _currentPosition = position;
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: cameraFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.data!.value.isInitialized) {
              return Container();
            } else if (pictureTaken) {
              return getPicturePreview();
            } else {
              return getCameraPreview(snapshot);
            }
          }),
    );
  }

  Widget getCameraPreview(AsyncSnapshot<CameraController> snapshot) {
    final screenAspectRatio = MediaQuery.of(context).size.aspectRatio;
    return Stack(children: [
      SizedBox(
          height: MediaQuery.of(context).size.width / screenAspectRatio,
          child: CameraPreview(snapshot.data!)),
      Align(
        alignment: Alignment.bottomCenter,
        child: IconButton(
            onPressed: () async => {
                  picture = await snapshot.data!.takePicture(),
                  setState(() {
                    pictureTaken = true;
                  }),
                },
            icon: const Icon(
              Icons.camera,
              size: 60,
              color: Colors.blueAccent,
            )),
      )
    ]);
  }

  Widget getPicturePreview() {
    final screenAspectRatio = MediaQuery.of(context).size.aspectRatio;

    return Column(
      children: [
        Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.width / screenAspectRatio,
            child: Image.file(File(picture!.path), fit: BoxFit.cover),
          ),
        ),
        Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 12,
          child: Column(
            children: [
              _currentAddress == null
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  : Text(
                      'Address: $_currentAddress \nLatitude: ${_currentPosition?.latitude} \nLongitude: ${_currentPosition?.longitude}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () => {
                            setState(() {
                              pictureTaken = false;
                              picture = null;
                            }),
                          },
                      icon: const Icon(
                        Icons.cancel,
                        size: 48,
                        color: Colors.redAccent,
                      )),
                  IconButton(
                      onPressed: () => uploadPicture(),
                      icon: const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Colors.greenAccent,
                      )),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> uploadPicture() async {
    showProgressDialog(context, 'Uploading picture, please wait...');
    String? pictureUrl = await databaseService.uploadPicture(
        picture!.path, picture!.name, context);
    if (pictureUrl == null) {
      if (mounted) hideProgressDialog(context);
      return;
    }
    final user = await databaseService.getUserProfile();
    final map = {
      'resolved': false,
      'imgUrl': pictureUrl,
      'latitude': _currentPosition!.latitude,
      'longitude': _currentPosition!.longitude,
      'address': _currentAddress,
      'uploadedById': user.uid,
      'uploadedByName': user.name,
      'uploadedByEmail': user.email,
      'uploadedDateTime': getCurrentDateTime(),
      'createdOn': FieldValue.serverTimestamp()
    };

    String uuid = const Uuid().v4();
    bool success = await databaseService.insertData(
        map, DatabaseConfig.garbagePicturesDocument, uuid);

    if (!mounted) return;
    hideProgressDialog(context);
    if (success) {
      Snackbars.success(context, "Picture sent successfully");
      Navigator.pop(context);
    } else {
      Snackbars.error(context, "Failed to send picture");
    }
  }

  String getCurrentDateTime() {
    DateTime now = DateTime.now();

    // String formattedDate =
    //     "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}AM";
    String formattedDate = "${DateFormat('jms').format(now)}";
    return formattedDate;
  }
}
