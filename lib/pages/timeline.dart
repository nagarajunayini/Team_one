import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/postCategory.dart';
import 'package:fluttershare/models/rules.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:uuid/uuid.dart';


//=================================

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  File file;
  String mediaUrl = "";
  String location = "";
  List<Post> posts = [];
  List<User> userData = [];
  List<User> userList = [];
  List<Rules> rules = [];
  int userValue = 0;
  bool isUploading = false;
  bool isUsersLoading = true;
  int defaultIndex = 0;
  List<Categories> postCategories = [];
  String fileType = "";
  String postId = Uuid().v4();
  bool isPostsLoading = true;
  List<String> filters = [
    "All",
    "Featured Today's",
    "10",
    "100",
    "500",
    "1000",
    "2000",
    "3000",
    "sports",
    "politics",
    "education",
    "technology",
    "job"
  ];
  String selectedFilters = "All";
  @override
  void initState() {
    super.initState();
    getRules();
    getCurrentUser();
    getProfilePosts();
    getPostCategories();
    getAllUsers();
  }

  getPostCategories() {
    categoriesRef.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        setState(() {
          isPostsLoading = false;
          postCategories.add(Categories.fromDocument(doc));
        });
      });
    });
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

  getAllUsers() {
    usersRef.getDocuments().then((QuerySnapshot snapshot) {
      setState(() {
        isUsersLoading = false;
        snapshot.documents.forEach((DocumentSnapshot doc) {
          userList.add(User.fromDocument(doc));
        });
      });
    });
  }

  getRules() async {
    QuerySnapshot snapshot = await rulesRef.getDocuments();
    setState(() {
      rules.addAll(
          snapshot.documents.map((doc) => Rules.fromDocument(doc)).toList());
      print(rules[0].applyType);
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
            radius: 80.0,
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

  // buildProfilePosts() {
  //   if (isLoading) {
  //     return circularProgress();
  //   }
  //   return Column(
  //     children: posts,
  //   );
  // }

  buildDevider() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('TEAM ONE'),
        actions: [
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
          buildFilters(),
          buildDevider(),
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
          // Divider(),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  buildFilters() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      height: MediaQuery.of(context).size.height * 0.06,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          itemBuilder: (context, index) {
            return Container(
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.grey)),
                color: filters[index] == selectedFilters
                    ? Colors.lightGreen
                    : Colors.white,
                textColor: filters[index] == selectedFilters
                    ? Colors.white
                    : Colors.grey,
                onPressed: () => {
                      setState(() {
                        selectedFilters = filters[index];
                        posts = [];
                        isLoading = true;
                        getDocumentDetails();
                      })
                    },
                child: Text(
                  filters[index].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.0,
                  ),
                ),
              ),
            );
          }),
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return linearProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/no_content.svg', height: 260.0),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
  }
}
