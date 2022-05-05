import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/postCategory.dart';
import 'package:fluttershare/models/rules.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/models/userLevels.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
//=================================
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

import 'home.dart';

final usersRef1 = Firestore.instance.collection('users');

class Upload extends StatefulWidget {
  final User currentUser;
  final int postValue;
  final int postDeductionValue;
  final String postLevel;
  Upload({this.currentUser, this.postValue, this.postDeductionValue, this.postLevel});
  @override
  _UploadState createState() => _UploadState(currentUser: this.currentUser, postValue: this.postValue, postDeductionValue:this.postDeductionValue, postLevel:this.postLevel);
}

class _UploadState extends State<Upload> {
  TextEditingController captionController = TextEditingController();
    VideoPlayerController _videoPlayerController;

  List<PostValues> postValues = [];
  List<String> selectedCategories = [];
  List<String> selectedFilters = [];
  List<String> cities=["Hyderabad","bangolore","Tamilnadu","kerala","Pune","Delhi","warangal","vijayawada","Tirupathi","Siddipet"];
  String selectedCity="";
  List<Categories> postCategories = [];
  int selectedPostValue=0;
  int selectedPostDeductionValue;
  int defaultIndex = 0;
  bool isLoading =true;
    bool isUploading = false;
  List<Rules> rules = [];
    String fileType = "";
      String mediaUrl = "";

     String postId = Uuid().v4();
File file;
  final User currentUser;
  final int postValue;
  final int postDeductionValue;
  final String postLevel;
  _UploadState({this.currentUser, this.postValue, this.postDeductionValue, this.postLevel});
  @override
  void initState() {
    super.initState();
    getRules();
    getPostCategories();
  }
 @override
  void dispose() {
      _videoPlayerController.dispose();
    super.dispose();
    
  }

  getRules() async {

    print(this.postValue.toString()+"@@@@@@@@@@@@@@@@@@@"+ this.postDeductionValue.toString());
    QuerySnapshot snapshot = await rulesRef.getDocuments();
    setState(() {
      isLoading=false;
      rules.addAll(
          snapshot.documents.map((doc) => Rules.fromDocument(doc)).toList());
      print(rules[0].applyType);
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
    });
  }

  getPostCategories() {
    categoriesRef.getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        postCategories.add(Categories.fromDocument(doc));
        print(postCategories);
      });
    });
  }

  @override
  Widget build(BuildContext context) {

   return file == null?
     Scaffold(
       backgroundColor: Color(0xFF000000),
        appBar: AppBar(
          title: new Text('Create Post'),
          actions: [
            Padding(
                padding: EdgeInsets.all(15.0),
                child: GestureDetector(
                  onTap:()=>selectImage(context),
                  child: Icon(
                    Icons.photo_camera,
                  ),
                )),
            Padding(
                padding: EdgeInsets.all(15.0),
                child: GestureDetector(
                  onTap:()=>createPost(),
                  child: Text(
                    "Post",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ))
          ],
        ),
        body: ListView(children: <Widget>[
          _buildTextField(),
          postDetails()
          // postValues.length > 0 ? postDetails() : Divider(),
        ])):buildUploadForm();
  }

  getPostValues() {
    setState(() {
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
      print(postValues);
    });
  }

  Widget postDetails() {
   if (isLoading) {
      return linearProgress();
    }
    return Column(children: <Widget>[
      Text(
        "Choose City :",
        style: TextStyle(color:Colors.white,fontSize: 20.0),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        height: MediaQuery.of(context).size.height * 0.12,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cities.length,
            itemBuilder: (context, index) {
              return Container(
                // width: MediaQuery.of(context).size.width * 0.6,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.grey)),
                  color: cities[index] == selectedCity
                      ? Colors.lightGreen
                      : Colors.white,
                  textColor: cities[index] == selectedCity
                      ? Colors.white
                      : Colors.grey,
                  padding: EdgeInsets.all(8.0),
                  onPressed: () => {
                        setState(() {
                          selectedCity = cities[index];
                          cities[index] = selectedCity;
                        })
                      },
                  child: Text(
                    cities[index].toString().toUpperCase(),
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
        style: TextStyle(color:Colors.white,fontSize: 20.0),
      ),
      Wrap(
        children: postCategories[0]
            .categories
            .map((item) => 
            Container(
              child:FlatButton(
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
                      setState(() {
                        if (selectedCategories.indexOf(item) != -1) {
                          selectedCategories.remove(item);
                        } else {
                          selectedCategories.add(item);
                        }
                      })
                    },
                child: Text(item,
                    style: TextStyle(
                      fontSize: 9.0,
                    )))))
            .toList()
            .cast<Widget>(),
      ),
    ]);
  }

  createPost() {
    
    if(this.postValue!=0){
      if (widget.currentUser.referralPoints >= this.postValue) {
      // if (captionController.text != "" && captionController.text != null) {
      userPostRef.document(postId).setData({
        "postId": postId,
        "ownerId": widget.currentUser.id,
        "username": widget.currentUser.username,
        "mediaUrl":mediaUrl,
        "description": captionController.text,
        "location": "",
        "timestamp": timestamp,
        "postStatus": "pending",
        "finalPostStatus":"",
        "postType":fileType,
        "likes": {},
        "postValue": this.postValue,
         "postLevel":this.postLevel,
        "postDeductionValue": this.postDeductionValue,
        "noComments": {},
        "disLikes": {},
        "comments": {},
        "postCategory":this.selectedCategories,
        "postDestination":this.selectedCity
      });
      captionController.clear();
      mediaUrl ="";
      debitWalletAmount(this.postValue);
      addDebitedAmountToPostPoolingAmount(this.postValue, postId);
       walletTransactions("upload", postId, this.postValue);
      showSuccessDailog();
      // _showMyDialog("Success", "Your post is yet to verify.",
      //     "Once verified, it is visible to all.");
      // }
    } else {
      _showMyDialog(
          "Warning",
          "You do not have enough points to post the content.",
          "Please refer this app to your loved one and earn points.");
    }
    }else{
      _showMyDialog(
          "Warning",
          "Please select the post value.",
          "");
    }
    
  }

  walletTransactions(action, postId, postDeductionValue) {
    walletTransactionRef.document(postId).setData({
      "userId": widget.currentUser.id,
      "transactionType": "Debit",
      "amount": postDeductionValue,
      "reason":"uploaded a Post"
    });
  }

  addDebitedAmountToPostPoolingAmount(userPostdeductionValue, postId) {
    poolAmountRef
        .document(postId)
        .setData({"postAmount": userPostdeductionValue, "postId": postId});
  }

   debitWalletAmount(userPostdeductionValue) {
    usersRef1.document(currentUser.id).updateData({
      "referralPoints":widget.currentUser.referralPoints - userPostdeductionValue,
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
                Navigator.of(context).maybePop();
                selectedCategories.length=0;
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> showSuccessDailog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:Colors.grey,
          content: Stack(
        children: [
          Positioned(
           
            child: Image.asset(
              "assets/images/successpopup.png",
              fit: BoxFit.cover,
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.all(24),
          //   child: Container(
          //     height: 60,
          //     width: 240,
          //     color: Colors.white.withOpacity(.3),
          //   ),
          // )
        ],
      ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok', style:TextStyle(
                      fontSize: 20.0, color:Colors.white
                    ), textAlign: TextAlign.center),
              onPressed: () {
                 Navigator.pop(context);
                Navigator.of(context).maybePop();
                selectedCategories.length=0;
              },
            ),
          ],
        );
      },
    );
  }
//  Future<void> showSuccessDailog() async {
//     return showDialog(
//   context: context,
//   builder: (context) {
//     return AlertDialog(
//       backgroundColor:Colors.transparent,
//       content: Stack(
//         children: [
//           Positioned(
           
//             child: Image.asset(
//               "assets/images/successpopup.png",
//               fit: BoxFit.cover,
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(24),
//             child: Container(
//               height: 60,
//               width: 240,
//               color: Colors.white.withOpacity(.3),
//             ),
//           )
//         ],
//       ),
//                actions: <Widget>[
//             FlatButton(
//               child: Text('Ok'),
//               onPressed: () {
//                 Navigator.of(context).maybePop();
//                 selectedCategories.length=0;
//               },
//             ),
//           ],
//       contentPadding: EdgeInsets.zero,
//       clipBehavior: Clip.antiAlias,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//     );
//   },
// );}
  Widget _buildTextField() {
    final maxLines = 10;

    return Container(
      margin: EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextField(
        controller: captionController,
        maxLines: maxLines,
      style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 18.0),
      inputFormatters: [
    new LengthLimitingTextInputFormatter(500),
  ],
        decoration: InputDecoration(
         border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                             labelStyle: TextStyle(
                                color: Color(0xB3FFFFFF), fontSize: 18.0),
          hintText: "What do you want to talk about?",
          hintStyle:TextStyle(
                                color: Color(0xB3FFFFFF), fontSize: 18.0), 
          filled: true,
        ),
      ),
    );
  }
  selectImage(parentContext) {

    showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                color: Color(0xFF1D1C1C),
                // child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        padding: EdgeInsets.only(bottom: 50.0),
                        child: Divider(
                        
                       
                  color: Colors.white,
                ) ,
                      ),
                     

                     GestureDetector(
                        onTap: handleTakePhoto,
                        child: Container(
                            padding: EdgeInsets.only(left: 20.0, bottom: 50.0),
                            width: 377.0,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFFB3B3B3),
                                ),
                                Text(
                                  "   Capture Photo",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ))),
                            GestureDetector(
                        onTap: handleChooseFromGallery,
                        child: Container(
                            padding: EdgeInsets.only(left: 20.0, bottom: 50.0),
                            width: 377.0,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_album,
                                  color: Color(0xFFB3B3B3),
                                ),
                                Text(
                                  "   Upload Photo from Gallery",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ))),
                            GestureDetector(
                        onTap: handelTakeVideo,
                        child: Container(
                            padding: EdgeInsets.only(left: 20.0, bottom: 50.0),
                            width: 377.0,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam_outlined ,
                                  color: Color(0xFFB3B3B3),
                                ),
                                Text(
                                  "   Capture video",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ))),

                             GestureDetector(
                        onTap: handleChooseVideoFromGallery,
                        child: Container(
                            padding: EdgeInsets.only(left: 20.0, bottom: 50.0),
                            width: 377.0,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam_outlined ,
                                  color: Color(0xFFB3B3B3),
                                ),
                                Text(
                                  "   Upload video from Gallery",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ))),

                      // const Text('Modal BottomSheet'),
                      // ElevatedButton(
                      //   child: const Text('Close BottomSheet'),
                      //   onPressed: () => Navigator.pop(context),
                      // )
                    ],
                  ),
                // ),
              );
            },
          );


    // return showDialog(
    //   context: parentContext,
    //   builder: (context) {
    //     return SimpleDialog(
    //       title: Text("Create Post"),
    //       children: <Widget>[
    //         SimpleDialogOption(
    //             child: Text("Photo with Camera"), onPressed: handleTakePhoto),
    //         SimpleDialogOption(
    //             child: Text("Image from Gallery"),
    //             onPressed: handleChooseFromGallery),
    //               SimpleDialogOption(
    //             child: Text("Video with camera"), onPressed: handelTakeVideo),
    //         SimpleDialogOption(
    //             child: Text("Video from Gallery"),
    //             onPressed: handleChooseVideoFromGallery),
    //         SimpleDialogOption(
    //           child: Text("Cancel"),
    //           onPressed: () => Navigator.pop(context),
    //         )
    //       ],
    //     );
    //   },
    // );
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

   bool get wantKeepAlive => true;
  Scaffold buildUploadForm() {
     final maxLines = 10;
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            icon: Icon(Icons.cancel, color: Colors.white),
            onPressed: clearImage),
        title: Text(
          "Create Post",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(
                color: Colors.white,
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
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: Text(
                widget.currentUser.username,
                style: TextStyle(color:Color(0xFFFFFFFF), fontSize: 16.0 ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left:20.0, right: 20.0),
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
         Container(
           padding: EdgeInsets.all(20.0),
              width: 250.0,
               height: 5 * 24.0,
              child: TextField(
               maxLines: maxLines,
                controller: captionController,
                style: TextStyle(color: Color(0xFFFFFFFF),fontSize: 18.0),
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  labelStyle:TextStyle(color: Colors.white,fontSize: 18.0) ,
                  hintStyle: TextStyle(color: Colors.white,fontSize: 18.0),
                  border: InputBorder.none,
                ),
              ),
            ),
          Divider(),
          Column(children: <Widget>[
             Text(
        "Choose City:",
        style: TextStyle(color:Colors.white, fontSize: 20.0),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        height: MediaQuery.of(context).size.height * 0.12,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cities.length,
            itemBuilder: (context, index) {
              return Container(
                // width: MediaQuery.of(context).size.width * 0.6,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.grey)),
                  color: cities[index] == selectedCity
                      ? Colors.lightGreen
                      : Colors.white,
                  textColor: cities[index] == selectedCity
                      ? Colors.white
                      : Colors.grey,
                  padding: EdgeInsets.all(8.0),
                  onPressed: () => {
                        setState(() {
                          selectedCity = cities[index];
                          cities[index] = selectedCity;
                        })
                      },
                  child: Text(
                    cities[index].toString().toUpperCase(),
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
                style: TextStyle(fontSize: 20.0, color: Colors.white),
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
                              setState(() {
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
              )
              ,
            ])
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
    createPost();
    captionController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }
   clearImage() {
    setState(() {
      file = null;
    });
  }
}
