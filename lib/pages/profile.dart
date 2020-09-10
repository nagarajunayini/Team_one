import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/edit_profile.dart';
import 'package:fluttershare/pages/home.dart';
// import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';

class Profile extends StatefulWidget {
  final String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  String postOrientation = "list";
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  Uri deepLink;
  int followerCount = 0;
  int followingCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await userPostRef
        // .document(widget.profileId)
        // .collection('userPosts')
        .orderBy('timestamp', descending: true)
         .where("ownerId", isEqualTo: widget.profileId)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
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

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 250.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // viewing your own profile - should show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    // remove follower
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // remove following
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    // Make auth user follower of THAT user (update THEIR followers collection)
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
    // Put THAT user on YOUR following collection (update your following collection)
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});
    // add activity feed item for that user to notify about new follower (us)
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "userId": currentUserId,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
        future: usersRef.document(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(user.photoUrl),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildCountColumn("posts", postCount),
                              buildCountColumn("followers", followerCount),
                              buildCountColumn("following", followingCount),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: buildProfileButton(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    user.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    user.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                 Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                   "Wallet Points: " + user.referralPoints.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //  Container(
                //   alignment: Alignment.centerLeft,
                //   padding: EdgeInsets.only(top: 4.0),
                //   child: Text(
                //     deepLink.toString(),
                //     style: TextStyle(
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 2.0),
                  child: Text(
                    user.bio,
                  ),
                ),
                Container(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: RaisedButton(
                      onPressed: () => generateShortDeepLink(),
                      child: Text('refer a friend'),
                      textColor: Colors.white,
                      color: Colors.green,
                      padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                    )),
              ],
            ),
          );
        });
  }

  generateShortDeepLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://socialnetworkingsite.page.link',
      link: Uri.parse('https://socialnetworkingsite.page.link'),
      androidParameters: AndroidParameters(
        packageName: 'com.teamone.socialnetworkingsite',
        minimumVersion: 125,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.ios',
        minimumVersion: '1.0.1',
        appStoreId: '123456789',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'example-promo',
        medium: 'social',
        source: 'orkut',
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short),
      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
        providerToken: '123456',
        campaignToken: 'example-promo',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'App link',
        description: 'Refer the app to get the rewards',
      ),
    );

    final Uri deepLink = await parameters.buildUrl();
    Share.share(deepLink.toString());
// _showMyDialog(deepLink);
    print(deepLink);
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
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
        if (post.mediaUrl != null && post.mediaUrl != "") {
          gridTiles.add(GridTile(child: PostTile(post)));
        }
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

  Future<void> _showMyDialog(deepLink) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(deepLink.toString()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == 'grid'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == 'list'
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//       appBar: AppBar(

// ),
      // appBar: header(context, titleText: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
