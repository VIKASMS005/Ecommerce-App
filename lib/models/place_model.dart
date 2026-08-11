import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  final String id;
  final String fullName;
  final GeoPoint location;
  final String area;
  final String roomNo;
  final String city;
  final String state;
  final String pincode;
  final String addressType;
  final String phoneNumber;

  PlaceModel(
    this.id,
    this.fullName,
    this.area,
    this.roomNo,
    this.city,
    this.state,
    this.pincode,
    this.location,
    this.addressType,
    this.phoneNumber,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'area': area,
      'roomNo': roomNo,
      'city': city,
      'state': state,
      'pincode': pincode,
      'location': location,
      'addressType': addressType,
      'phoneNumber': phoneNumber,
    };
  }

  factory PlaceModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return PlaceModel(
      id ?? '',
      map['fullName'] ?? '',
      map['area'] ?? '',
      map['roomNo'] ?? '',
      map['city'] ?? '',
      map['state'] ?? '',
      map['pincode'] ?? '',
      _parseLocation(map['location']),
      map['addressType'] ?? '',
      map['phoneNumber'] ?? '',
    );
  }

  static GeoPoint _parseLocation(dynamic value) {
    if (value is GeoPoint) return value;
    if (value is Map) {
      final lat = (value['latitude'] as num?)?.toDouble() ?? 0.0;
      final lng = (value['longitude'] as num?)?.toDouble() ?? 0.0;
      return GeoPoint(lat, lng);
    }
    return const GeoPoint(0, 0);
  }
}
