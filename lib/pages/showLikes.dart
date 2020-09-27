import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Likes extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Likes({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaUrl: this.postMediaUrl,
      );
}

class CommentsState extends State<Likes> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  buildLikes() {
    return StreamBuilder(
        stream: likesRef
            .document(postId)
            .collection('Likes')
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Like> likes = [];
          snapshot.data.documents.forEach((doc) {
            likes.add(Like.fromDocument(doc));
          });
          return ListView(
            children: likes,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Likes"),
      body: Column(
        children: <Widget>[
          Expanded(child: buildLikes()),
          Divider(),
        ],
      ),
    );
  }
}

class Like extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final bool liked;
  final Timestamp timestamp;

  Like({
    this.username,
    this.userId,
    this.avatarUrl,
    this.liked,
    this.timestamp,
  });

  factory Like.fromDocument(DocumentSnapshot doc) {
    return Like(
      username: doc['username'],
      userId: doc['userId'],
      liked: doc['liked'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(username),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
