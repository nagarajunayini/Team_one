import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/postCategory.dart';
import 'package:fluttershare/models/rules.dart';
import 'package:fluttershare/models/teamOneWallet.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/models/userLevels.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/pages/upload.dart';
// import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

//=================================
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  TextEditingController postController = TextEditingController();
  VideoPlayerController _videoPlayerController;
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  File file;
  String mediaUrl = "";
  String location = "";
  List<Post> posts = [];
  List<User> userData = [];
  List<Rules> rules = [];
  int userValue = 0;
  bool isUploading = false;
  List<TeamOneWallet> teamOneWallet = [];
  var userLevels = ["All", "1 Star", "2 Star", "3 Star", "4 Star", "5 Star"];
  int selectedPostValue;
  int selectedPostDeductionValue;
  int defaultIndex = 0;
  String selecteduserLevel = "All";
  List<PostValues> postValues = [];
  bool _isChecked = false;
  List<Categories> postCategories = [];
  List<String> selectedCategories = [];
  List<String> selectedFilters = [];
  String fileType = "";
  String postId = Uuid().v4();

  @override
  void initState() {
    super.initState();
    getRules();
    getCurrentUser();
    getProfilePosts();
    getPostCategories();
  }

  getPostCategories() {
    categoriesRef.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        postCategories.add(Categories.fromDocument(doc));
        print(postCategories);
        print("########################################");
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
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                height: MediaQuery.of(context).size.height * 0.12,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: postValues.length,
                    itemBuilder: (context, index) {
                      return Container(
                        // width: MediaQuery.of(context).size.width * 0.6,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.grey)),
                          color:
                              postValues[index].postValue == selectedPostValue
                                  ? Colors.lightGreen
                                  : Colors.white,
                          textColor:
                              postValues[index].postValue == selectedPostValue
                                  ? Colors.white
                                  : Colors.grey,
                          padding: EdgeInsets.all(8.0),
                          onPressed: () => {
                                setModalState(() {
                                  selectedPostValue =
                                      postValues[index].postValue;
                                  postValues[index].postValue =
                                      selectedPostValue;
                                  selectedPostDeductionValue =
                                      postValues[index].postDeductionValue;
                                })
                              },
                          child: Text(
                            postValues[index]
                                .postValue
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.0,
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              Text(
                "Choose Category:",
                style: TextStyle(fontSize: 20.0),
              ),
              Wrap(
                children: postCategories[0]
                    .categories
                    .map((item) => FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.grey)),
                        color: selectedCategories.indexOf(item) != -1
                            ? Colors.lightGreen
                            : Colors.white,
                        textColor: selectedCategories.indexOf(item) != -1
                            ? Colors.white
                            : Colors.grey,
                        onPressed: () => {
                              setModalState(() {
                                if (selectedCategories.indexOf(item) != -1) {
                                  selectedCategories.remove(item);
                                } else {
                                  selectedCategories.add(item);
                                }
                              })
                            },
                        child: Text(item,style: TextStyle(
                              fontSize: 9.0,
                            ))))
                    .toList()
                    .cast<Widget>(),
              ),
              RaisedButton(
                  color: Colors.blue,
                  onPressed: createPost,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.grey)),
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
      // if (postController.text != "" && postController.text != null) {
      userPostRef.document(postId).setData({
        "postId": postId,
        "ownerId": widget.currentUser.id,
        "username": widget.currentUser.username,
        "mediaUrl": mediaUrl,
        "description": postController.text,
        "location": location,
        "timestamp": timestamp,
        "postStatus": "pending",
        "postType": fileType,
        "likes": {},
        "postValue": selectedPostValue,
        "postDeductionValue": selectedPostDeductionValue,
        "noComments": {},
        "disLikes": {},
        "comments": {},
        "postCategory":this.selectedCategories
      });
      postController.clear();
      debitWalletAmount(selectedPostValue);
      addDebitedAmountToPostPoolingAmount(selectedPostValue, postId);
      _showMyDialog("Success", "Your post is yet to verify.",
          "Once verified, it is visible to all.");
      // }
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

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Photo with Camera"), onPressed: handleTakePhoto),
            SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  handleTakePhoto() async {
    fileType = "image";
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    fileType = "image";
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  createPostInFirestore() {
    postValues = [];
    selectedCategories = [];
    // if (postController.text.trim() != "") {
    if (currentUser.referralPoints >= rules[0].nomralUser) {
      postValues.add(PostValues(
          index: 0,
          postValue: rules[0].nomralUser,
          postDeductionValue: rules[0].nomralUserPostDeduction));
    }
    if (currentUser.referralPoints >= rules[0].oneStarUser) {
      postValues.add(PostValues(
          index: 1,
          postValue: rules[0].oneStarUser,
          postDeductionValue: rules[0].oneStarUserPostDeduction));
    }
    if (currentUser.referralPoints >= rules[0].twoStarUser) {
      postValues.add(PostValues(
          index: 2,
          postValue: rules[0].twoStarUser,
          postDeductionValue: rules[0].twoStarUserPostDeduction));
    }
    if (currentUser.referralPoints >= rules[0].threeStarUser) {
      postValues.add(PostValues(
          index: 3,
          postValue: rules[0].threeStarUser,
          postDeductionValue: rules[0].threeStarUserPostDeduction));
    }
    if (currentUser.referralPoints >= rules[0].fourStarUser) {
      postValues.add(PostValues(
          index: 4,
          postValue: rules[0].fourStarUser,
          postDeductionValue: rules[0].fourStarUserPostDeduction));
    }
    if (currentUser.referralPoints >= rules[0].fiveStarUser) {
      postValues.add(PostValues(
          index: 5,
          postValue: rules[0].fiveStarUser,
          postDeductionValue: rules[0].fiveStarUserPostDeduction));
    }
    _showBottomSheet(context);
    // }
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

  buildDevider() {
    return Container(
      // height: 1.0,
      // decoration: new BoxDecoration(
      //   color: Colors.grey,
      // ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return file == null
        ? Scaffold(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      height: 40.0,
                      margin: EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: postController,
                        
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(color: Colors.grey),
                              //borderSide: const BorderSide(),
                            ),contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),

                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontFamily: "WorkSansLight"),
                            filled: true,
                            
                            fillColor: Colors.white24,
                            hintText: 'Write something here...'),
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                    ),
                    GestureDetector(
                      onTap: () => createPostInFirestore(),
                      child: Icon(
                        Icons.send,
                        size: 28.0,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                Divider(),
                Container(
                  height: 30.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.grey)),
                      color: Colors.white,
                      textColor: Colors.grey,
                      padding: EdgeInsets.all(8.0),
                      onPressed: () => selectImage(context),
                      child: Text(
                        "Photo".toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 10,height: 5,),
                    FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.grey)),
                      color: Colors.white,
                      textColor: Colors.grey,
                      // padding: EdgeInsets.all(8.0),
                      onPressed: () => selectVideo(context),
                      child: Text(
                        "Video".toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.0,
                        ),
                      ),
                    ),
                  ],
                ),
            ),
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
            floatingActionButton: new FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.grey)),
              color: Colors.red,
              textColor: Colors.white,
              padding: EdgeInsets.all(8.0),
              onPressed: () => openFilterBottomSheet(context),
              child: Text(
                "Filter".toUpperCase(),
                style: TextStyle(
                  fontSize: 9.0,
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          )
        : buildUploadForm();
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadVideo(videoFile) async {
    StorageReference ref =
        FirebaseStorage.instance.ref().child("post_$postId.video");
    StorageUploadTask uploadTask =
        ref.putFile(videoFile, StorageMetadata(contentType: 'video/mp4'));
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  callStoringMethod(mediaUrl) {
    createPostInFirestore();
    postController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  openFilterBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setModalState /*You can rename this!*/) {
            return Column(children: <Widget>[
              Text(
                "Choose Category:",
                style: TextStyle(fontSize: 20.0),
              ),
              Wrap(
                children: postCategories[0]
                    .categories
                    .map((item) => FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.grey)),
                        color: selectedFilters.indexOf(item) != -1
                            ? Colors.lightGreen
                            : Colors.white,
                        textColor: selectedFilters.indexOf(item) != -1
                            ? Colors.white
                            : Colors.grey,
                        onPressed: () => {
                              setModalState(() {
                                if (selectedFilters.indexOf(item) != -1) {
                                  selectedFilters.remove(item);
                                } else {
                                  selectedFilters.add(item);
                                }
                              })
                            },
                        child: Text(item)))
                    .toList()
                    .cast<Widget>(),
              ),
              Align(
      alignment: Alignment.bottomCenter,
      child: RaisedButton(
                  color: Colors.blue,
                  onPressed: createPost,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.grey)),
                  child: Text(
                    'Apply',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white),
                  ))
    )
              ,
            ]);
          });
        });
  }

  buildVideoOrImageSpace() {
    if (fileType == 'video') {
      return VideoPlayer(_videoPlayerController);
    } else {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: FileImage(file),
          ),
        ),
      );
    }
  }

  selectVideo(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
                child: Text("Video with camera"), onPressed: handelTakeVideo),
            SimpleDialogOption(
                child: Text("Video from Gallery"),
                onPressed: handleChooseVideoFromGallery),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  handelTakeVideo() async {
    fileType = "video";
    Navigator.pop(context);
    File file = await ImagePicker.pickVideo(source: ImageSource.camera);

    _videoPlayerController = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {
          this.file = file;
        });
        _videoPlayerController.play();
      });
  }

  handleChooseVideoFromGallery() async {
    fileType = "video";
    Navigator.pop(context);
    File file = await ImagePicker.pickVideo(source: ImageSource.gallery);
    _videoPlayerController = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {
          this.file = file;
        });
        _videoPlayerController.play();
      });
  }

  handleSubmit() async {
    postId = Uuid().v4();
    setState(() {
      isUploading = true;
    });
    if (fileType == "image") {
      await compressImage();
    }
    if (fileType == 'image') {
      mediaUrl = await uploadImage(file);
      callStoringMethod(mediaUrl);
    } else {
      mediaUrl = await uploadVideo(file);
      callStoringMethod(mediaUrl);
    }
  }

  bool get wantKeepAlive => true;
  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: clearImage),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                  aspectRatio: 16 / 9, child: buildVideoOrImageSpace()),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: postController,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
