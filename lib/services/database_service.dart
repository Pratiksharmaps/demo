import 'dart:io';

import 'package:demo/config/database_config.dart';
import 'package:demo/utils/snackbars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import '../models/garbage_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  DatabaseService._privateConstructor();

  static final DatabaseService _instance =
      DatabaseService._privateConstructor();

  factory DatabaseService() {
    return _instance;
  }
  final _auth = FirebaseAuth.instance;
  final _storageRef = FirebaseStorage.instance.ref();
  final _firestore = FirebaseFirestore.instance;

  Future<bool> insertData(
      Map<String, dynamic> data, String document, String uuid) async {
    final documentPath = '$document/$uuid';
    try {
      final DocumentReference documentReference = _firestore.doc(documentPath);
      await documentReference.set(data);
      print('Data inserted successfully.');
      return true;
    } catch (e) {
      print('Error inserting data: $e');
      return false;
    }
  }

  Future<String?> uploadPicture(
      String imagePath, String fileName, BuildContext context) async {
    final imageRef = _storageRef.child(fileName);
    try {
      await imageRef.putFile(File(imagePath));
      return await imageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      print(e.stackTrace);
      Snackbars.error(context, "Failed to upload picutre");
      return null;
    }
  }

  Future<UserModel> getUserProfile() async {
    String? uid = _auth.currentUser?.uid;
    final snapshot =
        await _firestore.collection(DatabaseConfig.userDocument).doc(uid).get();
    return UserModel.fromJson(snapshot.data());
  }

  Future<List<GarbageModel>> getAllGarbagePics() async {
    final snapshot = await _firestore
        .collection(DatabaseConfig.garbagePicturesDocument)
        .orderBy('createdOn', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GarbageModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<GarbageModel>> getUserGarbagePics(String uid) async {
    final snapshot = await _firestore
        .collection(DatabaseConfig.garbagePicturesDocument)
        .where('uploadedById', isEqualTo: uid)
        .orderBy('createdOn', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GarbageModel.fromJson(doc.data()))
        .toList();
  }
}
