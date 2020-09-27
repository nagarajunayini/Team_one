import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Stats extends StatefulWidget {
  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  buildComments() {
    return StreamBuilder(
        stream: currentWeekInfluencersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Stat> influencersList = [];
          snapshot.data.documents.forEach((doc) {
            influencersList.add(Stat.fromDocument(doc));
          });
          return ListView(
            children: influencersList,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "This week Influencer's"),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          Divider(),
        ],
      ),
    );
  }
}

class Stat extends StatelessWidget {
  final String username;
  final String id;
  final String photoUrl;
  final String reason;
  final Timestamp timestamp;

  Stat({
    this.username,
    this.id,
    this.photoUrl,
    this.reason,
    this.timestamp,
  });

  factory Stat.fromDocument(DocumentSnapshot doc) {
    return Stat(
      username: doc['username'],
      id: doc['id'],
      reason: doc['reason'],
      timestamp: doc['timestamp'],
      photoUrl: doc['photoUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(username),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(photoUrl),
          ),
          subtitle: Text(reason),
        ),
        Divider(),
      ],
    );
  }
}
