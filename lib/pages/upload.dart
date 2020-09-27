import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/rules.dart';
import 'package:fluttershare/models/teamOneWallet.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/models/userLevels.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

final usersRef = Firestore.instance.collection('users');

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  VideoPlayerController _videoPlayerController;
  File file;
  String fileType = "";
  bool isUploading = false;
  List<Rules> rules = [];
  int userValue = 0;
  File _video;
  List<TeamOneWallet> teamOneWallet = [];
  List<PostValues> postValues = [];
  int selectedPostValue;
  int selectedPostDeductionValue;
  int defaultIndex = 0;
  String postId = Uuid().v4();
  @override
  void initState() {
    super.initState();
    getRules();
  }

  getRules() async {
    QuerySnapshot snapshot = await rulesRef.getDocuments();
    setState(() {
      rules.addAll(
          snapshot.documents.map((doc) => Rules.fromDocument(doc)).toList());

      print(rules[0].applyType);
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

  handleChooseFromGallery() async {
    fileType = "image";
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
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

  _showBottomSheet(context, mediaUrl, location, description) {
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
              GestureDetector(
                onTap: () => createPost(
                      mediaUrl: mediaUrl,
                      location: location,
                      description: description,
                    ),
                child: Icon(
                  Icons.send,
                  size: 28.0,
                  color: Colors.blue[900],
                ),
              ),
            ]);
          });
        });
  }

  buildSplashScreen() {
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 100.0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child: TextField(
                maxLines: 3,
                controller: captionController,
                decoration: InputDecoration(hintText: 'Enter Text Here'),
              ),
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            GestureDetector(
              onTap: () => createPostInFirestore(
                    mediaUrl: "",
                    location: "",
                    description: captionController.text,
                  ),
              child: Icon(
                Icons.send,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0),
        ),
        Row(
          children: [
            Padding(padding: EdgeInsets.only(left: 80.0)),
            RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "Upload Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
                ),
                color: Colors.deepOrange,
                onPressed: () => selectImage(context))
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0),
        ),
        Row(
          children: [
            Padding(padding: EdgeInsets.only(left: 80.0)),
            RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "Upload Video",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
                ),
                color: Colors.deepOrange,
                onPressed: () => selectVideo(context))
          ],
        ),
      ],
    );
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

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
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
    _showBottomSheet(context, mediaUrl, location, description);
  }

  createPost({String mediaUrl, String location, String description}) {
    Navigator.pop(context);
    if (widget.currentUser.referralPoints >= selectedPostValue) {
      userPostRef.document(postId).setData({
        "postId": postId,
        "ownerId": widget.currentUser.id,
        "username": widget.currentUser.username,
        "mediaUrl": mediaUrl,
        "description": description,
        "location": location,
        "timestamp": timestamp,
        "postStatus": "pending",
        "likes": {},
        "disLikes": {},
        "comments": {},
        "postType": fileType,
        "postValue": selectedPostValue,
        "postDeductionValue": selectedPostDeductionValue,
        "noComments": {}
      });
      if (captionController.text != null || captionController.text != "") {
        captionController.clear();
      }
      debitWalletAmount(selectedPostValue);
      addDebitedAmountToPostPoolingAmount(selectedPostValue, postId);
      _showMyDialog("Success", "Your post is yet to verify.",
          "Once verified, it is visible to all.");
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

  debitWalletAmount(userPostdeductionValue) {
    usersRef.document(widget.currentUser.id).setData({
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

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    if (fileType == "image") {
      await compressImage();
    }
    if (fileType == 'image') {
      String mediaUrl = await uploadImage(file);
      callStoringMethod(mediaUrl);
    } else {
      String mediaUrl = await uploadVideo(file);
      callStoringMethod(mediaUrl);
    }
  }

  callStoringMethod(mediaUrl) {
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

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
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                "Use Current Location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
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

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress = "${placemark.locality}, ${placemark.country}";
    locationController.text = formattedAddress;
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
