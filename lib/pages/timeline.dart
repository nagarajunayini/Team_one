import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/search.dart';
// import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:uuid/uuid.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  TextEditingController postController = TextEditingController();

  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
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
      });
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    getDocumentDetails();
    // usersRef.getDocuments().then((QuerySnapshot snapshot) {
    //    print( snapshot.documents);
    //   snapshot.documents.forEach((DocumentSnapshot doc) {
       
    //     // getDocumentDetails(doc.documentID);
    //   });
    // });
  }

  getuserProfile() {
    return FutureBuilder(
        future: usersRef.document(currentUserId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircleAvatar(
            // radius: 50.0,
            // backgroundColor: Colors.grey,
            // backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          );
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
    QuerySnapshot snapshot = await userPostRef
        .orderBy('timestamp', descending: true)
        .where("postStatus", isEqualTo: "verified")
        .getDocuments();
    setState(() {
      isLoading = false;
      posts.addAll(
          snapshot.documents.map((doc) => Post.fromDocument(doc)).toList());
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
       
        String postId= Uuid().v4();
         
    if (postController.text != "" && postController.text != null) {
      userPostRef
          // .document(widget.currentUser.id)
          // .collection("userPosts")
          .document(postId)
          .setData({
        "postId": postId,
        "ownerId": widget.currentUser.id,
        "username": widget.currentUser.username,
        "mediaUrl": "",
        "description": postController.text,
        "location": "",
        "timestamp": timestamp,
        "postStatus": "pending",
        "likes": {},
        "disLikes":{},
        "comments": {}
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
          title: Text("Post uploaded successfully"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your post is yet to verify.'),
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
      children: posts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('TEAM ONE'),
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
          ListTile(
            title: TextFormField(
              controller: postController,
              decoration: InputDecoration(labelText: "Write a post..."),
            ),
            trailing: OutlineButton(
              onPressed: createPostInFirestore,
              borderSide: BorderSide.none,
              child: IconButton(
                icon: Icon(Icons.send),
                color: Colors.blue,
                ),
            ),
          ),
          Divider(),
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
