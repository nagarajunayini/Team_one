import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final String credits;
  final num referralPoints;
  List<dynamic> extraInfo = [];
  List<dynamic> interests =[];

  User(
      {this.id,
      this.username,
      this.email,
      this.photoUrl,
      this.displayName,
      this.bio,
      this.credits,
      this.referralPoints,
      this.extraInfo,
      this.interests
      });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        email: doc['email'],
        username: doc['username'],
        photoUrl: doc['photoUrl'],
        displayName: doc['displayName'],
        bio: doc['bio'],
        credits: doc['credits'],
        referralPoints: doc['referralPoints'],
        extraInfo: doc['extraInfo'],
        interests: doc['interests']
        );
  }
}
