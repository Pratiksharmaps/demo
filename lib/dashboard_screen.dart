import 'package:demo/camera_screen.dart';
import 'package:demo/models/role.dart';
import 'package:demo/models/user_model.dart';
import 'package:demo/phone_login.dart';
import 'package:demo/utils/snackbars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../models/garbage_model.dart';
import '../services/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseService = DatabaseService();
  late Future<UserModel> _userDetailsFuture;
  late Future<List<GarbageModel>> _garbagePicsFuture;

  late Color colorInversePrimary;
  final cardBorderRadius = BorderRadius.circular(8);

  @override
  void initState() {
    _userDetailsFuture = databaseService.getUserProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    colorInversePrimary = Theme.of(context).colorScheme.inversePrimary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () async {
                await _auth.signOut();
                if (!mounted) return;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PhoneAuth()));
              },
              icon: const Icon(
                Icons.power_settings_new_outlined,
                size: 28,
              ))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {
              _userDetailsFuture = databaseService.getUserProfile();
            });
          });
        },
        child: FutureBuilder(
            future: _userDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return snapshot.data!.role == Role.ADMIN
                    ? adminDashboard()
                    : userDashboard(snapshot.data!.uid!);
              }
            }),
      ),
    );
  }

  Widget userDashboard(String uid) {
    _garbagePicsFuture = databaseService.getUserGarbagePics(uid);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: 120,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: cardBorderRadius,
                  side: const BorderSide(
                    color: Colors.blueAccent,
                    width: 1.5,
                  )),
              child: InkWell(
                borderRadius: cardBorderRadius,
                splashColor: colorInversePrimary,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CameraScreen()));
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 54),
                    Text(
                      'Take Picture',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: const Text(
            style: TextStyle(fontWeight: FontWeight.bold),
            'My Uploaded Pictures',
            textAlign: TextAlign.start,
          ),
        ),
        FutureBuilder(
          future: _garbagePicsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No pictures found'),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final currentItem = snapshot.data![index];
                    return garbageDetailsCard(currentItem);
                  },
                ),
              );
            }
          },
        )
      ],
    );
  }

  Widget adminDashboard() {
    _garbagePicsFuture = databaseService.getAllGarbagePics();
    return FutureBuilder(
        future: _garbagePicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No pictures found'),
            );
          } else {
            return Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final currentItem = snapshot.data![index];
                  return garbageDetailsCard(currentItem);
                },
              ),
            );
          }
        });
  }

  Widget garbageDetailsCard(GarbageModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.network(
                item.imgUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        '${item.address} \nUploaded By : ${item.uploadedByName} \nUploaded: ${item.uploadedDateTime}'),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                        shape: BoxShape.circle),
                    child: IconButton(
                        onPressed: () => {
                              openGoogleMapLocation(
                                  item.latitude, item.longitude)
                            },
                        icon: const Icon(Icons.location_on_rounded,
                            color: Colors.blueAccent)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> openGoogleMapLocation(double lat, double long) async {
    Uri mapUri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$long');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    } else {
      if (!mounted) return;
      Snackbars.error(context, 'Could not open the map.');
    }
  }
}
