import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/edit_profile.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/sidebar.dart';
import 'package:fluttershare/widgets/header.dart';
// import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';

class History extends StatefulWidget {
  final String profileId;

  History({this.profileId});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final String currentUserId = currentUser?.id;
  String postOrientation = "list";
  bool isFollowing = false;
  bool isLoading = false;
  bool inprogressOrExpired= true;
  int postCount = 0;
  Uri deepLink;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];
  List<Post> filterposts = [];


  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
      inprogressOrExpired=true;
    });
    QuerySnapshot snapshot = await userPostRef
        .orderBy('timestamp', descending: true)
        .where("postStatus", isEqualTo: "verified")
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts.clear();
      filterposts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
      for(var i =0; i<filterposts.length; i++){
        if(widget.profileId != filterposts[i].ownerId){
          if(!isPostAvailable(filterposts[i])){
         posts.add(filterposts[i]);
       }
        }
       
     
   }
    });
  }
  getExpiredPost() async{
    setState(() {
      isLoading = true;
      inprogressOrExpired=false;
    });
    QuerySnapshot snapshot = await userPostRef
        .orderBy('timestamp', descending: true)
        .where("postStatus", isEqualTo: "expired")
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts.clear();
      filterposts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
      for(var i =0; i<filterposts.length; i++){
        if(widget.profileId != filterposts[i].ownerId){
          if(!isPostAvailable(filterposts[i])){
         posts.add(filterposts[i]);
       }
        }
       
     
   }
    });
  }
isPostAvailable(post){ 
    if(post.likes[currentUserId]!=null){
      return false;
        
       }else{
         if(post.disLikes[currentUserId]!=null){
            return false;
        
       }else{
         if(post.noComments[currentUserId]!=null){
        return false;
       }else{
         return true;
       }
       }
       }
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
    } else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        // if (post.mediaUrl != null && post.mediaUrl != "") {
          gridTiles.add(GridTile(child: PostTile(post)));
        // }
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
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

 

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
       GestureDetector(

                  onTap: getProfilePosts,
                  child: Container(
                    height: 50.0,
                     width: 180.0,
                    decoration: BoxDecoration(
                      color:  inprogressOrExpired?Colors.red:Colors.grey,
                      // borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "INPROGRESS",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
        GestureDetector(
                  onTap: getExpiredPost,
                  child: Container(
                    height: 50.0,
                     width: 180.0,
                    decoration: BoxDecoration(
                      color:  inprogressOrExpired?Colors.grey:Colors.red,
                      // borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "EXPIRED",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, titleText: "History"),
        body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top:3.0)),
          buildTogglePostOrientation(),
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
        ],
      ),
        );
  }
}
