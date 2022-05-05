import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String dataOfBirth;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final String credits;
  final String pinCode;
  final num referralPoints;
  List<dynamic> extraInfo = [];
  List<dynamic> interests =[];

  User(
      {this.id,
      this.phoneNumber,
      this.firstName,
      this.lastName,
      this.dataOfBirth,
      this.username,
      this.email,
      this.photoUrl,
      this.displayName,
      this.bio,
      this.credits,
      this.pinCode,
      this.referralPoints,
      this.extraInfo,
      this.interests
      });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        phoneNumber: doc['phoneNumber'],
        firstName: doc['firstName'],
        lastName: doc['lastName'],
        dataOfBirth: doc['dataOfBirth'],
        email: doc['email'],
        username: doc['username'],
        photoUrl: doc['photoUrl'],
        displayName: doc['displayName'],
        bio: doc['bio'],
        credits: doc['credits'],
        pinCode: doc['pinCode'],
        referralPoints: doc['referralPoints'],
        extraInfo: doc['extraInfo'],
        interests: doc['interests']
        );
  }
}
