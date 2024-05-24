class GarbageModel {
  late String imgUrl;
  late double latitude;
  late double longitude;
  late String address;
  late String uploadedByEmail;
  late String uploadedById;
  late String uploadedByName;
  late String uploadedDateTime;

  GarbageModel(
      {required this.imgUrl,
      required this.latitude,
      required this.longitude,
      required this.address,
      required this.uploadedByEmail,
      required this.uploadedById,
      required this.uploadedByName,
      required this.uploadedDateTime});

  factory GarbageModel.fromJson(dynamic json) {
    return GarbageModel(
        imgUrl: json['imgUrl'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        address: json['address'],
        uploadedByEmail: json['uploadedByEmail'],
        uploadedById: json['uploadedById'],
        uploadedByName: json['uploadedByName'],
        uploadedDateTime: json['uploadedDateTime']);
  }
}
