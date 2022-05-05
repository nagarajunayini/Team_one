import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/postCategory.dart';
import 'package:fluttershare/models/rules.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/models/userLevels.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/postPopup.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;

//=================================

final usersRef = Firestore.instance.collection('users');

class LandingPage extends StatefulWidget {
  final User currentUser;

  LandingPage({this.currentUser});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  OverlayEntry _popupDialog;
  final String currentUserId = currentUser?.id;
  List<PostValues> postValues = [];
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  List<User> userData = [];
  List<User> userList = [];
  List<Rules> rules = [];
  int userValue = 0;

  bool isUsersLoading = true;
  List<Categories> postCategories = [];
  bool isPostsLoading = true;
  Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getRules();
    getCurrentUser();
    getProfilePosts();
    getPostCategories();
    getAllUsers();
    // initPlayer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (advancedPlayer != null) {
      advancedPlayer.setReleaseMode(ReleaseMode.STOP);
      advancedPlayer.stop();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        print("audio paused -----@@@@@@@@@@@@@@@@");
        if (advancedPlayer != null) {
          advancedPlayer.pause();
        }

        break;
      case AppLifecycleState.resumed:
        print("audio resume --------------@@@@@@@@@@@@@");
        if (advancedPlayer != null) {
          advancedPlayer.resume();
        }
        break;

      case AppLifecycleState.inactive:
        print("audio inactive ---------------@@@@@@@@@@");
        if (advancedPlayer != null) {
          advancedPlayer.stop();
        }
        break;
      case AppLifecycleState.detached:
        print("audio detached ---- @@@@@@@@@@@@@@@@@@@@");
        if (advancedPlayer != null) {
          advancedPlayer.stop();
        }
        break;
    }
  }

  void initPlayer() {
    advancedPlayer = new AudioPlayer();
    advancedPlayer = new AudioPlayer();
    advancedPlayer.setUrl(
        'https://firebasestorage.googleapis.com/v0/b/socialnetworkingsite-d535f.appspot.com/o/background.mp3?alt=media&token=a65a7c8f-56cb-4b32-8257-229a471a9010');
    advancedPlayer.setReleaseMode(ReleaseMode.LOOP);
    advancedPlayer.play(
        "https://firebasestorage.googleapis.com/v0/b/socialnetworkingsite-d535f.appspot.com/o/background.mp3?alt=media&token=a65a7c8f-56cb-4b32-8257-229a471a9010");
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
      isLoading = false;
      rules.addAll(
          snapshot.documents.map((doc) => Rules.fromDocument(doc)).toList());
      print(rules[0].applyType);
      postValues = [];
      // if (postController.text.trim() != "") {
      // if (currentUser.referralPoints >= rules[0].nomralUser) {
      postValues.add(PostValues(
          index: 0,
          postValue: rules[0].nomralUser,
          postDeductionValue: rules[0].nomralUserPostDeduction));
      // }
      // if (currentUser.referralPoints >= rules[0].oneStarUser) {
      postValues.add(PostValues(
          index: 1,
          postValue: rules[0].oneStarUser,
          postDeductionValue: rules[0].oneStarUserPostDeduction));
      // }
      // if (currentUser.referralPoints >= rules[0].twoStarUser) {
      postValues.add(PostValues(
          index: 2,
          postValue: rules[0].twoStarUser,
          postDeductionValue: rules[0].twoStarUserPostDeduction));
      // }
      // if (currentUser.referralPoints >= rules[0].threeStarUser) {
      postValues.add(PostValues(
          index: 3,
          postValue: rules[0].threeStarUser,
          postDeductionValue: rules[0].threeStarUserPostDeduction));
      // }
      // if (currentUser.referralPoints >= rules[0].fourStarUser) {
      postValues.add(PostValues(
          index: 4,
          postValue: rules[0].fourStarUser,
          postDeductionValue: rules[0].fourStarUserPostDeduction));
      // }
      // if (currentUser.referralPoints >= rules[0].fiveStarUser) {
      postValues.add(PostValues(
          index: 5,
          postValue: rules[0].fiveStarUser,
          postDeductionValue: rules[0].fiveStarUserPostDeduction));
      // }
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

  buildDevider() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      key: _scaffoldKey,
      appBar: AppBar(
        // title: new Text('STAND IV'),
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
          Container(
              child: Row(
            children: [
              Image(
                image: AssetImage('assets/images/coinsymbol.png'),
              ),
              Container(
                child: Text("300",
                    style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        backgroundColor: Color(0xFF666666),
                        fontSize: 32.0)),
              ),
              Image(
                image: AssetImage('assets/images/add_button.png'),
              ),
            ],
          ))
          // IconButton(
          //   icon: Icon(Icons.search),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => Search()),
          //     );
          //   },
          // ),
        ],

        leading: Padding(
            padding: EdgeInsets.only(left: 10.0), child: getuserProfile()),
      ),
      body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 10.0)),
          Expanded(child: buildCard()),
          // buildDevider(),
          // Padding(padding: EdgeInsets.only(top:30.0)),
          Container(
            padding: EdgeInsets.only(top: 10.0, left: 10.0),
            width: 377.0,
            child: Text(
              "Trending Users",
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.left,
            ),
          ),

          buildRecomendedUser()
        ],
      ),
    );
  }

  showPost(context, post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Post(
          postId: post.postId,
          ownerId: post.ownerId,
          username: post.username,
          location: post.location,
          timestamp: post.timestamp,
          description: post.description,
          mediaUrl: post.mediaUrl,
          likes: post.likes,
          noComments: post.noComments,
          disLikes: post.disLikes,
          comments: post.comments,
          postType: post.postType,
          postValue: post.postValue,
          postDeductionValue: post.postDeductionValue,
          postCategory: post.postCategory,
          fromPage: "postTile",
        ),
      ),
    );
  }

  getRespectivePost(category) {
    print(posts.length);
    print(currentUserId);
    var isPostPresent = "No";
    for (var i = 0; i < posts.length; i++) {
      if (category.postValue == posts[i].postValue) {
        print(posts[i].likes);
        print(posts[i].comments);
        print(posts[i].noComments);
        print(isPostAvailable(posts[i]));
        if (isPostAvailable(posts[i])) {
          // _popupDialog = _createPopupDialog(posts[i], context);
          // Overlay.of(context).insert(_popupDialog);
           showPost(context, posts[i]);
          //
          isPostPresent = "Yes";
          break;
        }
      }
    }

    if (isPostPresent == 'No') {
      SnackBar snackbar = SnackBar(content: Text("No posts"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  isPostAvailable(post) {
    if (post.likes[currentUserId] != null) {
      return false;
    } else {
      if (post.disLikes[currentUserId] != null) {
        return false;
      } else {
        if (post.noComments[currentUserId] != null) {
          return false;
        } else {
          return true;
        }
      }
    }
  }

  OverlayEntry _createPopupDialog(Post post, context) {
    return OverlayEntry(
      builder: (context) => AnimatedDialog(
        child: _createPopupContent(post, context),
      ),
    );
  }

  cancel() {
    print("fdasfsafasdf");
    print(_popupDialog);
    if (_popupDialog != null) {
      _popupDialog?.remove();
    }
  }

  Widget _createPopupContent(post, context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [buildAppBar(), buildImgae(post, context)],
          ),
        ),
      );

  buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text("Post"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.cancel),
          tooltip: "cancel",
          onPressed: () {
            cancel();
          },
        )
      ],
    );
  }

  buildImgae(post, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 150,
      child: PostPopup(
        postId: post.postId,
        ownerId: post.ownerId,
        username: post.username,
        location: post.location,
        timestamp: post.timestamp,
        description: post.description,
        mediaUrl: post.mediaUrl,
        likes: post.likes,
        noComments: post.noComments,
        disLikes: post.disLikes,
        comments: post.comments,
        postType: post.postType,
        postValue: post.postValue,
        postDeductionValue: post.postDeductionValue,
        postCategory: post.postCategory,
        fromPage: "postTile",
        popupDialog: _popupDialog,
      ),
    );
  }

  buildRecomendedUser() {
    return Container(
      // padding: EdgeInsets.only(horizontal: 10.0),
      height: MediaQuery.of(context).size.height * 0.22,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: userList.length,
          itemBuilder: (context, index) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () =>
                        showProfile(context, profileId: userList[index].id),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        userList[index].photoUrl,
                      ),
                      radius: 30.0,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                    width: 10.0,
                  ),
                  Text(
                    userList[index].username,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                ]);

            // Container(
            //   // width: MediaQuery.of(context).size.width * 0.6,
            //   child: FlatButton(
            //     shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(18.0),
            //         side: BorderSide(color: Colors.grey)),
            //     // color: postValues[index].postValue == selectedPostValue
            //     //     ? Colors.lightGreen
            //     //     : Colors.white,
            //     // textColor: postValues[index].postValue == selectedPostValue
            //     //     ? Colors.white
            //     //     : Colors.grey,
            //     padding: EdgeInsets.all(8.0),
            //     onPressed: () => {
            //           // setState(() {
            //           //   selectedPostValue = postValues[index].postValue;
            //           //   postValues[index].postValue = selectedPostValue;
            //           //   selectedPostDeductionValue =
            //           //       postValues[index].postDeductionValue;
            //           // })
            //         },
            //     child: Text(
            //       userList[index].username.toString().toUpperCase(),
            //       style: TextStyle(
            //         fontSize: 9.0,
            //       ),
            //     ),
            //   ),
            // );
          }),
    );
  }

  buildCard() {
    final double itemHeight =
        (MediaQuery.of(context).size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = MediaQuery.of(context).size.width / 1.8;
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(4),
      crossAxisSpacing: 5,
      childAspectRatio: (itemWidth / itemHeight),
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      children: postValues.map((value) {
        return value.postValue > currentUser.referralPoints
            ? GestureDetector(
                child: Container(
                child: Container(
                  // width: 50.0,
                  // height: 50.0,
                  decoration: BoxDecoration(
                    // color:Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                    border: Border.all(color: Color(0xFFFFFFFF), width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://www.freeiconspng.com/uploads/lock-icon-12.png',
                      ),
                    ),
                    //  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  image: DecorationImage(
                    image: AssetImage('assets/images/card' +
                        (value.index + 1).toString() +
                        '.png'),
                    fit: BoxFit.fill,
                  ),
                  shape: BoxShape.rectangle,
                ),
              ))
            : GestureDetector(
                onTap: () => getRespectivePost(value),
                child: Container(
                  child: const Text(""),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFFFFFFF), width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    image: DecorationImage(
                      image: AssetImage('assets/images/card' +
                          (value.index + 1).toString() +
                          '.png'),
                      fit: BoxFit.fill,
                    ),
                    shape: BoxShape.rectangle,
                  ),
                ));
      }).toList(),
    );
  }
}
