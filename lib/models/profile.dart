import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String gender;
  final String imageUrl;
  final String bio;

  Profile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    this.imageUrl = '',
    this.bio = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'imageUrl': imageUrl,
      'bio': bio,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      gender: map['gender'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      bio: map['bio'] ?? '',
    );
  }
}
