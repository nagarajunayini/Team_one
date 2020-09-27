import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/widgets/contests.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:uuid/uuid.dart';

final usersRef = Firestore.instance.collection('users');

class ContestTimeline extends StatefulWidget {
  final User currentUser;

  ContestTimeline({this.currentUser});

  @override
  _ContestTimelineState createState() => _ContestTimelineState();
}

class _ContestTimelineState extends State<ContestTimeline> {
  TextEditingController postController = TextEditingController();

  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  List<Contests> contests = [];
  List<User> userData = [];

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getProfilePosts();
  }

  getCurrentUser() {
    usersRef
        .where("id", isEqualTo: currentUserId)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        userData.add(User.fromDocument(doc));
        print(userData);
      });
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    getDocumentDetails();
  }

  getuserProfile() {
    return FutureBuilder(
        future: usersRef.document(currentUserId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircleAvatar();
          }
          User user = User.fromDocument(snapshot.data);
          return CircleAvatar(
            radius: 50.0,
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          );
        });
  }

  getDocumentDetails() async {
    QuerySnapshot snapshot = await userContestRef
        .orderBy('timestamp', descending: true)
        .where("contestStatus", isEqualTo: "verified")
        .where("contestExpired", isEqualTo: false)
        .getDocuments();
    setState(() {
      isLoading = false;
      contests.addAll(
          snapshot.documents.map((doc) => Contests.fromDocument(doc)).toList());
      print(contests);
      // posts.sort((a,b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  createPostInFirestore() {
    String contestId = Uuid().v4();
    if (postController.text != "" && postController.text != null) {
      userContestRef.document(contestId).setData({
        "contestId": contestId,
        "ownerId": widget.currentUser.id,
        "username": widget.currentUser.username,
        "mediaUrl": "",
        "description": postController.text,
        "location": "",
        "timestamp": timestamp,
        "contestStatus": "pending",
        "likes": {},
        "disLikes": {},
        "comments": {},
        "contestType": "",
        "contestExpired": false,
        "contestExpiredIn": 7
      });
      postController.clear();
      _showMyDialog();
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Contest uploaded successfully"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your Contest is yet to verify.'),
                Text('Once verified, it is visible to all'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    }
    return Column(
      children: contests,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('CONTESTS'),
        actions: [
          // action button
          IconButton(
            icon: Icon(Icons.notifications_active),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActivityFeed()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Search()),
              );
            },
          ),
        ],
        leading: getuserProfile(),
      ),
      body: Column(
        children: <Widget>[
          widget.currentUser.credits == '1'
              ? ListTile(
                  title: TextFormField(
                    controller: postController,
                    decoration:
                        InputDecoration(labelText: "Write a contest..."),
                  ),
                  trailing: OutlineButton(
                    onPressed: createPostInFirestore,
                    borderSide: BorderSide.none,
                    child: IconButton(
                      icon: Icon(Icons.send),
                      color: Colors.blue,
                    ),
                  ),
                )
              : Divider(),
          Expanded(
            child: ListView(
              children: <Widget>[
                buildProfilePosts(),
                Divider(
                  height: 2.0,
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
