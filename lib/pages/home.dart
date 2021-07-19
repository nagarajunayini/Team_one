import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/landingPage.dart';
import 'package:fluttershare/pages/playHistory.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/stats.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'contest_timeLine.dart';
import 'menu.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final usersRef = Firestore.instance.collection('users');
final groupsRef = Firestore.instance.collection('groups');
final postsRef = Firestore.instance.collection('posts');
final userPostRef = Firestore.instance.collection('userPosts');
final walletTransactionsRef = Firestore.instance.collection('walletTransactions');
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
  TextEditingController phoneNumberController = TextEditingController();
  String isAuth = "";
  PageController pageController;
  int pageIndex = 0;
  String phoneNo;
  String tempPhone;
  String smsCode;
  String verificationId;

  @override
  void initState()  { 
    super.initState();
    pageController = PageController();

    // userSignIn check
handleSignIn();

      

    // Detects when user signed in
    
    // code for google login
    // 
    // googleSignIn.onCurrentUserChanged.listen((account) {
    //   handleSignIn(account);
    // }, onError: (err) {
    //   setState(() {
    //     isAuth = "false";
    //   });
    //   print('Error signing in: $err');
    // });
    // Reauthenticate user when app is opened
    //  // code for google login
    // googleSignIn.signInSilently(suppressErrors: false).then((account) {
    //   handleSignIn(account);
    // }).catchError((err) {
    // setState(() {
    //     isAuth = "false";
    //   });
    //   print('Error signing in: $err');
    // });
  }
  Future<bool> smsCodeDialog(BuildContext context) async  {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter sms Code'),
            content: TextField(
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Done'),
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    if (user != null) {
                      Navigator.of(context).pop();
                       createUserInFirestore1(user);
      setState(() {
        isAuth = "true";
      });
      configurePushNotifications1(user);
                      // Navigator.push(
                      // context, MaterialPageRoute(builder: (context) => CreateAccount()));
                    } else {
                      Navigator.of(context).pop();
                      signIn();
                    }
                  });
                },
              )
            ],
          );
        });
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsCodeDialog(context).then((value) {
        print('Signed in');
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      print('verified');
      createUserInFirestore1(user);
      setState(() {
        isAuth = "true";
      });
      configurePushNotifications1(user);
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  signIn() async { 
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final FirebaseUser user = await FirebaseAuth.instance.signInWithCredential(credential);
    final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    print(user);
    if(user!=null){
       
                             createUserInFirestore1(user);
                             configurePushNotifications1(user);
                             setState(() {
        isAuth = "true";
      });

    }
  }


// code for google signIn
// 
  // handleSignIn(GoogleSignInAccount account) async {
  //   if (account != null) {
  //     await createUserInFirestore();
  //     setState(() {
  //       isAuth = "true";
  //     });
  //     // configurePushNotifications();
  //   } else {
  //     setState(() {
  //       isAuth = "false";
  //     });
  //   }
  // }
  // 
  // 
  handleSignIn() async {
        final FirebaseUser user = await FirebaseAuth.instance.currentUser();

    if (user != null) {
      await createUserInFirestore1(user);
      setState(() {
        isAuth = "true";
      });
      configurePushNotifications1(user);
    } else {
      setState(() {
        isAuth = "false";
      });
    }
  }


 //  code for google signIn
  // configurePushNotifications() {
  //   final GoogleSignInAccount user = googleSignIn.currentUser;
  //   if (Platform.isIOS) getiOSPermission();

  //   _firebaseMessaging.getToken().then((token) {
  //     // print("Firebase Messaging Token: $token\n");
  //     usersRef
  //         .document(user.id)
  //         .updateData({"androidNotificationToken": token});
  //   });

  //   _firebaseMessaging.configure(
  //     // onLaunch: (Map<String, dynamic> message) async {},
  //     // onResume: (Map<String, dynamic> message) async {},
  //     onMessage: (Map<String, dynamic> message) async {
  //       // print("on message: $message\n");
  //       final String recipientId = message['data']['recipient'];
  //       final String body = message['notification']['body'];
  //       if (recipientId == user.id) {
  //         // print("Notification shown!");
  //         SnackBar snackbar = SnackBar(
  //             content: Text(
  //           body,
  //           overflow: TextOverflow.ellipsis,
  //         ));
  //         _scaffoldKey.currentState.showSnackBar(snackbar);
  //       }
  //       // print("Notification NOT shown");
  //     },
  //   );
  // }
  configurePushNotifications1(user) {
    // final GoogleSignInAccount user = googleSignIn.currentUser;
        String substring1 = user.phoneNumber.substring(3);

    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      // print("Firebase Messaging Token: $token\n");
      usersRef
          .document("1"+substring1 + substring1)
          .updateData({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      // onLaunch: (Map<String, dynamic> message) async {},
      // onResume: (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
        // print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];
        if (recipientId == "1"+substring1 + substring1) {
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

  // createUserInFirestore() async {
  //   // 1) check if user exists in users collection in database (according to their id)
  //   final GoogleSignInAccount user = googleSignIn.currentUser;
  //   print(user.id);
  //   DocumentSnapshot doc = await usersRef.document(user.id).get();

  //   if (!doc.exists) {
  //     // 2) if the user doesn't exist, then we want to take them to the create account page
  //     List<dynamic> userDetails = await Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => CreateAccount()));
  //     // 3) get username from create account, use it to make new user document in users collection
  //     usersRef.document(user.id).setData({
  //       "id": user.id,
  //       "username": userDetails[0].user_Name,
  //       "photoUrl": user.photoUrl,
  //       "email": user.email,
  //       "displayName": user.displayName,
  //       "bio": "",
  //       "phoneNumber":this.phoneNo,
  //       "timestamp": timestamp,
  //       "credits": "0",
  //       "referralPoints": 500,
  //       "extraInfo": userDetails[0].extra_Info,
  //     });
  //     // make new user their own follower (to include their posts in their timeline)
  //     await followersRef
  //         .document(user.id)
  //         .collection('userFollowers')
  //         .document(user.id)
  //         .setData({});

  //     doc = await usersRef.document(user.id).get();
  //   }

  //   currentUser = User.fromDocument(doc);
  // }
  // 
  // 
  getRandomElement<T>(List<T> list) {
    final random = new Random();
    var i = random.nextInt(list.length);
    return list[i];
}


    createUserInFirestore1(user) async {
    // 1) check if user exists in users collection in database (according to their id)
    // final GoogleSignInAccount user = googleSignIn.currentUser;
        final FirebaseUser user = await FirebaseAuth.instance.currentUser();

    print(user.uid);
    var listOfImages =[
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image10.jpg?alt=media&token=9bd9ba49-51f7-4198-956b-d507b9374e19",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image1.png?alt=media&token=08bde7d6-0d72-40e5-a6d1-53477b05bda1",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image11.png?alt=media&token=b79a997f-8b21-40ae-8d3f-30d075f6d7fe",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image4.png?alt=media&token=9c21e1ab-217d-481c-ac01-85c165af1df5",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image3.jpg?alt=media&token=d9ea9616-da2c-4d2c-9eb1-565732d1da91",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image20.jpg?alt=media&token=7054ad7b-6a33-4cda-b5b9-ff86607ae8c8",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image2.png?alt=media&token=63b1ed4d-f3f6-454b-adb9-d7d8fb8042d4",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image19.png?alt=media&token=4c5b4226-9c82-4ef5-973e-4d86b6fdce94",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image13.png?alt=media&token=1bf5a642-1ea0-4913-adca-d309ecb9d464",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image12.png?alt=media&token=e06e31b3-0294-46a8-bb06-a3995a4c78dd",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/images17.jpg?alt=media&token=5228189c-b57f-4840-a1b2-8938bef27a49",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/images15.jpg?alt=media&token=423c0c15-9002-4578-87e6-3b0d7c6ac391",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/images14.jpg?alt=media&token=9ea870d7-2b8a-4ace-bc2f-9832199e5ea1",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image9.jpg?alt=media&token=17dca710-c9db-4a14-9d84-d0e4e0800b7b",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image8.png?alt=media&token=a978633c-81b8-494d-ab98-629b3f75cd31",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image6.jpg?alt=media&token=19bc4f62-8f63-4b59-8a15-633342c6ee69",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image7.png?alt=media&token=c0b10b98-acf1-4cd3-bf5d-cfbe70ea064a",
      "https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/image5.jpg?alt=media&token=d776d0c2-a530-4d86-9d13-9d5f68478dc7"



    ];
    String substring = user.phoneNumber.substring(3);
     
    DocumentSnapshot doc = await usersRef.document("1"+substring + substring).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      List<dynamic> userDetails = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      print(userDetails);
      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document("1"+substring + substring).setData({
        "id": "1"+substring + substring,
        "username": userDetails[0].user_Name,
        "photoUrl": getRandomElement(listOfImages),
        "email":userDetails[0].email_id,
        "displayName": userDetails[0].user_Name,
        "bio": "",
        "phoneNumber":this.phoneNo,
        "timestamp": timestamp,
        "credits": "0",
        "referralPoints": 500,
        "extraInfo": userDetails[0].extra_Info,
      });
      // make new user their own follower (to include their posts in their timeline)
      await followersRef
          .document("1"+substring + substring)
          .collection('userFollowers')
          .document("1"+substring + substring)
          .setData({});

      doc = await usersRef.document("1"+substring + substring).get();
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
          LandingPage(currentUser: currentUser),
          // Timeline(currentUser: currentUser),
          // ContestTimeline(currentUser: currentUser),
          History(profileId: currentUser?.id),
          Upload(currentUser: currentUser),
          // Search(),
          Menu(currentUser: currentUser),
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
            BottomNavigationBarItem(icon: Icon(Icons.history)),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_box,
                size: 35.0,
                
              ),
            ),
            // BottomNavigationBarItem(icon: Icon(Icons.search,color: Colors.transparent,)),
            BottomNavigationBarItem(icon: Icon(Icons.menu)),
          ]),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }

  Scaffold buildSpalshScreen() {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
               Colors.black,
                Colors.black,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        child:ListView(
           children: <Widget>[
            Container(
              alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              child: Container(
                width: 260.0,
                height: 360.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/standfor.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top:120.0),),
             CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
          ],
        ),
            ) 
           ]
        )
        
      ),
    );
    // return Scaffold(
    //   body: Stack(
    //     fit: StackFit.expand,
    //     children: <Widget>[
    //       Container(
    //         decoration: BoxDecoration(
    //           gradient: LinearGradient(
    //             begin: Alignment.topRight,
    //             end: Alignment.bottomLeft,
    //             colors: [
    //               Theme.of(context).accentColor,
    //               Theme.of(context).primaryColor,
    //             ],
    //           ),
    //         ),
    //       ),
    //       Column(
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         children: <Widget>[
    //           Expanded(
    //             flex: 2,
    //             child: Container(
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: <Widget>[
    //                   CircleAvatar(
    //                     backgroundColor: Colors.white,
    //                     radius: 50.0,
    //                     backgroundImage:
    //                         AssetImage('assets/images/standfor.png'),
    //                   ),
    //                   Padding(
    //                     padding: EdgeInsets.only(top: 10.0),
    //                   ),
    //                   Text(
    //                     "STAND IV",
    //                     style: TextStyle(
    //                         color: Colors.white,
    //                         fontWeight: FontWeight.bold,
    //                         fontSize: 24.0),
    //                   )
    //                 ],
    //               ),
    //             ),
    //           ),
    //           Expanded(
    //             flex: 1,
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: <Widget>[
    //                 CircularProgressIndicator(
    //                   valueColor:
    //                       new AlwaysStoppedAnimation<Color>(Colors.white),
    //                 ),
    //                 Padding(
    //                   padding: EdgeInsets.only(top: 20.0),
    //                 ),
    //                 // Text(
    //                 //   Flutkart.store,
    //                 //   softWrap: true,
    //                 //   textAlign: TextAlign.center,
    //                 //   style: TextStyle(
    //                 //       fontWeight: FontWeight.bold,
    //                 //       fontSize: 18.0,
    //                 //       color: Colors.white),
    //                 // )
    //               ],
    //             ),
    //           )
    //         ],
    //       )
    //     ],
    //   ),
    // );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
               Colors.black,
                Colors.black,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        child:ListView(
           children: <Widget>[
            Container(
              alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              child: Container(
                width: 260.0,
                height: 360.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/standfor.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // GestureDetector(
            //   onTap: login,
            //   child: Container(
            //     width: 260.0,
            //     height: 40.0,
            //     decoration: BoxDecoration(
            //       image: DecorationImage(
            //         image: AssetImage(
            //           'assets/images/google_signin_button.png',
            //         ),
            //         fit: BoxFit.cover,
            //       ),
            //     ),
            //   ),
            // ),
            // Padding(
            // padding: EdgeInsets.only(
            //                 top: 12.0,bottom:12.0),
            //                 child:Center(
            //                   child:Text("OR", style:TextStyle(color:Colors.white))
            //                 )            ),
                            Container(
  padding: EdgeInsets.only(top:12.0, left:50.0,right:50.0, bottom:12.0),
  child: Column(
    children: <Widget>[
      TextField(
         style: TextStyle(
      height: 0.1,
      color: Colors.black                  
    ),
        decoration: InputDecoration(
           filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
  borderRadius: BorderRadius.circular(10.0),
  ),
  hintStyle: TextStyle(color: Colors.black),
                // labelStyle: TextStyle(color: Colors.blue[800], fontSize: 30.0, fontWeight: FontWeight.bold),
                hintText: "Enter Phone Number", 
          // labelText: 'Phone Number',
           prefix: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('+91'),
                  ),
        ),
         onChanged: (value) {
                    this.tempPhone = value;
                    this.phoneNo ="+91"+ value;
                  },
        maxLength: 10,
        keyboardType: TextInputType.number,
      )
    ],
  ),
),
            GestureDetector(
                  onTap: verifyPhone,
                  child: Container(
                    height: 40.0,
                    width: 150.0,
                    decoration: BoxDecoration(
                      color:Colors.blue[800],
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),



          ],
        ),
            ) 
           ]
        )
        
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth == ""
        ? buildSpalshScreen()
        : isAuth == "true" ? buildAuthScreen() : buildUnAuthScreen();
  }
}
