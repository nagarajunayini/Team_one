import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/rules.dart';
import 'package:fluttershare/models/teamOneWallet.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/models/userLevels.dart';
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
  List<Rules> rules = [];
  int userValue = 0;
  List<TeamOneWallet> teamOneWallet = [];
  var userLevels = ["All", "1 Star", "2 Star", "3 Star", "4 Star", "5 Star"];
  int selectedPostValue;
  int selectedPostDeductionValue;
  int defaultIndex = 0;
  String selecteduserLevel = "All";
  List<PostValues> postValues = [];

  @override
  void initState() {
    super.initState();
    getRules();
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
            radius: 50.0,
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
          );
        });
  }

  getPostDeductionValue() {
    if (currentUser.credits == "0") {
      return userValue = rules[0].nomralUser;
    } else if (currentUser.credits == "1") {
      return userValue = rules[0].oneStarUser;
    } else if (currentUser.credits == "2") {
      return userValue = rules[0].twoStarUser;
    } else if (currentUser.credits == "3") {
      return userValue = rules[0].threeStarUser;
    } else if (currentUser.credits == "4") {
      return userValue = rules[0].fourStarUser;
    } else {
      return userValue = rules[0].fiveStarUser;
    }
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

  _showBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setModalState /*You can rename this!*/) {
            return Column(children: <Widget>[
              Text(
                "Choose Post Value:",
                style: TextStyle(fontSize: 20.0),
              ),
              Container(
                  height: 280,
                  child: SingleChildScrollView(
                      child: Column(
                    children: postValues
                        .map((data) => RadioListTile(
                              title: Text("${data.postValue}"),
                              groupValue: defaultIndex,
                              value: data.index,
                              onChanged: (value) {
                                setModalState(() {
                                  selectedPostValue = data.postValue;
                                  selectedPostDeductionValue =
                                      data.postDeductionValue;
                                  defaultIndex = data.index;
                                  print(selectedPostValue);
                                });
                              },
                              selected: defaultIndex == data.index,
                            ))
                        .toList(),
                  ))),
              RaisedButton(
                  color: Colors.blue,
                  onPressed: createPost,
                  child: Text(
                    'Post',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ]);
          });
        });
  }

  createPost() {
    Navigator.pop(context);
    String postId = Uuid().v4();
    if (widget.currentUser.referralPoints >= selectedPostValue) {
      if (postController.text != "" && postController.text != null) {
        userPostRef.document(postId).setData({
          "postId": postId,
          "ownerId": widget.currentUser.id,
          "username": widget.currentUser.username,
          "mediaUrl": "",
          "description": postController.text,
          "location": "",
          "timestamp": timestamp,
          "postStatus": "pending",
          "postType": "",
          "likes": {},
          "postValue": selectedPostValue,
          "postDeductionValue": selectedPostDeductionValue,
          "noComments": {},
          "disLikes": {},
          "comments": {}
        });
        postController.clear();
        debitWalletAmount(selectedPostValue);
        addDebitedAmountToPostPoolingAmount(selectedPostValue, postId);
        _showMyDialog("Success", "Your post is yet to verify.",
            "Once verified, it is visible to all.");
      }
    } else {
      _showMyDialog(
          "Warning",
          "You do not have enough points to post the content.",
          "Please refer this app to your loved one and earn points.");
    }
  }

  addDebitedAmountToPostPoolingAmount(userPostdeductionValue, postId) {
    poolAmountRef
        .document(postId)
        .setData({"postAmount": userPostdeductionValue, "postId": postId});
  }

  createPostInFirestore() {
    postValues = [
      PostValues(
          index: 0,
          postValue: rules[0].nomralUser,
          postDeductionValue: rules[0].nomralUserPostDeduction),
      PostValues(
          index: 1,
          postValue: rules[0].oneStarUser,
          postDeductionValue: rules[0].oneStarUserPostDeduction),
      PostValues(
          index: 2,
          postValue: rules[0].twoStarUser,
          postDeductionValue: rules[0].twoStarUserPostDeduction),
      PostValues(
          index: 3,
          postValue: rules[0].threeStarUser,
          postDeductionValue: rules[0].threeStarUserPostDeduction),
      PostValues(
          index: 4,
          postValue: rules[0].fourStarUser,
          postDeductionValue: rules[0].fourStarUserPostDeduction),
      PostValues(
          index: 5,
          postValue: rules[0].fiveStarUser,
          postDeductionValue: rules[0].fiveStarUserPostDeduction)
    ];
    _showBottomSheet(context);
  }

  addDebitedAmountToTeamOne(userPostdeductionValue) {
    teamOneWalletRef.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        teamOneWallet.add(TeamOneWallet.fromDocument(doc));
        print(teamOneWallet[0].userId);
        teamOneWalletRef.document(teamOneWallet[0].userId).setData({
          "walletAmount":
              teamOneWallet[0].walletAmount + userPostdeductionValue,
          "userId": teamOneWallet[0].userId
        });
      });
    });
  }

  debitWalletAmount(userPostdeductionValue) {
    usersRef.document(currentUserId).setData({
      "id": widget.currentUser.id,
      "username": widget.currentUser.username,
      "photoUrl": widget.currentUser.photoUrl,
      "email": widget.currentUser.email,
      "displayName": widget.currentUser.displayName,
      "bio": widget.currentUser.bio,
      "timestamp": timestamp,
      "credits": widget.currentUser.credits,
      "referralPoints":
          widget.currentUser.referralPoints - userPostdeductionValue,
      "extraInfo": widget.currentUser.extraInfo,
    });
  }

  Future<void> _showMyDialog(status, message, message1) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
                Text(message1),
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
          // ListTile(
          //   title:Text(
          //                 "Post category:",
          //                 style: TextStyle(fontSize: 20.0, ),
          //               ),
          //   trailing:
          //   DropdownButton<String>(
          //             items: userLevels.map((String dropdownItem) {
          //               return DropdownMenuItem<String>(
          //                   value: dropdownItem, child: Text(dropdownItem));
          //             }).toList(),
          //             onChanged: (String selectedValue) {
          //               setState(() {
          //                 this.selecteduserLevel = selectedValue;
          //               });
          //             },
          //             value: this.selecteduserLevel,
          //           ),
          //   // OutlineButton(
          //   //   onPressed: createPostInFirestore,
          //   //   borderSide: BorderSide.none,
          //   //   child: IconButton(
          //   //     icon: Icon(Icons.send),
          //   //     color: Colors.blue,
          //   //   ),
          //   // ),
          // ),
          // Divider(),
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
}
