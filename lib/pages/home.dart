import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/phone_number.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/stats.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'contest_timeLine.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final userPostRef = Firestore.instance.collection('userPosts');
final userContestRef = Firestore.instance.collection('Contests');
final commentsRef = Firestore.instance.collection('comments');
final currentWeekInfluencersRef =
    Firestore.instance.collection('currentWeekInfluencers');
final likesRef = Firestore.instance.collection('likes');
final disLikesRef = Firestore.instance.collection('Dislikes');
final walletTransactionRef =
    Firestore.instance.collection('walletTransactions');
final teamOneWalletRef = Firestore.instance.collection('teamoneWallet');
final poolAmountRef = Firestore.instance.collection('poolAmount');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');
final rulesRef = Firestore.instance.collection('rules');
final categoriesRef = Firestore.instance.collection('categories');
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String isAuth = "";
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = "true";
      });
      configurePushNotifications();
    } else {
      setState(() {
        isAuth = "false";
      });
    }
  }

  configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser;
    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      // print("Firebase Messaging Token: $token\n");
      usersRef
          .document(user.id)
          .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async {},
      // onResume: (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
        // print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == user.id) {
          // print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: Text(
            body,
            overflow: TextOverflow.ellipsis,
          ));
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
        // print("Notification NOT shown");
      },
    );
  }

  getiOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(alert: true, badge: true, sound: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      // print("Settings registered: $settings");
    });
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      List<dynamic> userDetails = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      print(userDetails);
      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": userDetails[0] is String ? userDetails[0] : userDetails[1],
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp,
        "credits": "0",
        "referralPoints": 0,
        "extraInfo": userDetails[0] is String ? userDetails[1] : userDetails[0],
      });
      // make new user their own follower (to include their posts in their timeline)
      await followersRef
          .document(user.id)
          .collection('userFollowers')
          .document(user.id)
          .setData({});

      doc = await usersRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  openPhonePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.jumpToPage(
      pageIndex,
      // duration: Duration(milliseconds: 300),
      // curve: Curves.easeInOut,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        children: <Widget>[
          Timeline(currentUser: currentUser),
          ContestTimeline(currentUser: currentUser),
          // Upload(currentUser: currentUser),
          // Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
          currentIndex: pageIndex,
          onTap: onTap,
          activeColor: Theme.of(context).primaryColor,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home)),
            BottomNavigationBarItem(icon: Icon(Icons.stars)),
            // BottomNavigationBarItem(
            //   icon: Icon(
            //     Icons.photo_camera,
            //     size: 35.0,
            //   ),
            // ),
            // BottomNavigationBarItem(icon: Icon(Icons.search)),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
          ]),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }
  Scaffold buildSpalshScreen(){
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 50.0,
  backgroundImage: AssetImage('assets/images/appicon.png'),
),

                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      Text(
                        "Team One",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    // Text(
                    //   Flutkart.store,
                    //   softWrap: true,
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 18.0,
                    //       color: Colors.white),
                    // )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'TEAM ONE',
              style: TextStyle(
                fontSize: 50.0,
                color: Colors.white,
              ),
            ),
            // GestureDetector(
            //   onTap: openPhonePage,
            //   child: Container(
            //     width: 260.0,
            //     height: 360.0,
            //     decoration: BoxDecoration(
            //       image: DecorationImage(
            //         image: AssetImage(
            //           'assets/images/appicon.png',
            //         ),
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),
            // ),

            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/google_signin_button.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth=="" ? buildSpalshScreen():isAuth=="true"? buildAuthScreen() : buildUnAuthScreen();
  }
}
