import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/poolAmount.dart';
import 'package:fluttershare/models/rules.dart';
import 'package:fluttershare/models/teamOneWallet.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/comments.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/home.dart' as prefix0;
import 'package:fluttershare/pages/postExpiryTimer.dart';
import 'package:fluttershare/pages/postreaction_chart.dart';
import 'package:fluttershare/pages/showLikes.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final Timestamp timestamp;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  final dynamic noComments;
  final dynamic disLikes;
  final dynamic comments;
  final String postType;
  final int postValue;
  final int postDeductionValue;
  final String fromPage;
  List<dynamic> postCategory = [];

  Post(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.timestamp,
      this.description,
      this.mediaUrl,
      this.likes,
      this.disLikes,
      this.noComments,
      this.comments,
      this.postType,
      this.postValue,
      this.postDeductionValue,
      this.postCategory,
      this.fromPage});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
        postId: doc['postId'],
        ownerId: doc['ownerId'],
        username: doc['username'],
        location: doc['location'],
        timestamp: doc['timestamp'],
        description: doc['description'],
        mediaUrl: doc['mediaUrl'],
        likes: doc['likes'],
        disLikes: doc['disLikes'],
        noComments: doc['noComments'],
        comments: doc['comments'],
        postType: doc['postType'],
        postValue: doc['postValue'],
        postDeductionValue: doc['postDeductionValue'],
        postCategory: doc['postCategory']);
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  int getNoCommentsCount(noCommetns) {
    if (noCommetns == null) {
      return 0;
    }
    int count = 0;
    noCommetns.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  int getDislikesCount(disLikes) {
    if (disLikes == null) {
      return 0;
    }
    int count = 0;
    disLikes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  int getCommentCount(comment) {
    if (comment == null) {
      return 0;
    }
    int count = 0;
    comment.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      location: this.location,
      timestamp: this.timestamp,
      description: this.description,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      noComments: this.noComments,
      noCommentsCount: getNoCommentsCount(this.noComments),
      disLikes: this.disLikes,
      disLikesCount: getDislikesCount(this.disLikes),
      likeCount: getLikeCount(this.likes),
      comments: this.comments,
      postType: this.postType,
      postValue: this.postValue,
      postDeductionValue: this.postDeductionValue,
      postCategory: this.postCategory,
      fromPage: this.fromPage,
      commentCount: getCommentCount(this.comments));
}

class _PostState extends State<Post> with WidgetsBindingObserver {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final Timestamp timestamp;
  final String description;
  final String mediaUrl;
  bool showHeart = false;
  bool isLiked;
  bool isDisLiked;
  bool isNoComment;
  int likeCount;
  int disLikesCount;
  Map disLikes;
  int commentCount;
  int noCommentsCount;
  Map noComments;
  Map likes;
  Map comments;
  int postValue;
  int postDeductionValue;
  final String fromPage;
  List<dynamic> postCategory = [];
  final String postType;
  List<Rules> rules = [];
  List<TeamOneWallet> teamOneWallet = [];
  List<PoolAmount> poolAmount = [];
  int userValue;
  int userPostdeductionValue;
  List<User> userData = [];
  VideoPlayerController _videoPlayerController;
  Future<void> futureController;
  Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
   CountDownController _controller = CountDownController();

  _PostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.timestamp,
      this.description,
      this.mediaUrl,
      this.likes,
      this.disLikes,
      this.disLikesCount,
      this.likeCount,
      this.commentCount,
      this.comments,
      this.noComments,
      this.noCommentsCount,
      this.postValue,
      this.postDeductionValue,
      this.postCategory,
      this.postType,
      this.fromPage});
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getRules();
    if (fromPage == "postTile") {
      initPlayer();

      Timer(
          Duration(seconds: 20),
          () => {
                if (!isDisLiked && !isLiked && !isNoComment)
                  {handleNoCommentPost()}
              });
    }
  }

 

  @override
  void dispose() {
      WidgetsBinding.instance.removeObserver(this);
       if(advancedPlayer!=null){
      advancedPlayer.setReleaseMode(ReleaseMode.STOP);
      advancedPlayer.stop();
       }
    if (fromPage == "postTile") {
      print(isDisLiked);
      print(isLiked);
      print(isNoComment);
      if (!isDisLiked && !isLiked && !isNoComment) handleNoCommentPost();
    }
    super.dispose();
    
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.paused:
      print("audio paused");
       if(advancedPlayer!=null){
      advancedPlayer.pause();
       }
       break;
       case AppLifecycleState.resumed:
       print("audio resume");
        if(advancedPlayer!=null){
        advancedPlayer.resume();
        }
       break;

      case AppLifecycleState.inactive:
       if(advancedPlayer!=null){
         advancedPlayer.stop();
       }
        break;
      case AppLifecycleState.detached:
       if(advancedPlayer!=null){
        advancedPlayer.stop();
       }
        break;
    }
  }

  void initPlayer() {
    advancedPlayer = new AudioPlayer();
    advancedPlayer.setUrl('https://luan.xyz/files/audio/ambient_c_motion.mp3');
    advancedPlayer.setReleaseMode(ReleaseMode.LOOP);
    advancedPlayer.play("https://luan.xyz/files/audio/ambient_c_motion.mp3");
    // audioCache = new AudioCache(fixedPlayer: advancedPlayer);

    // advancedPlayer.durationHandler = (d) => setState(() {
    //       _duration = d;
    //     });

    // advancedPlayer.positionHandler = (p) => setState(() {
    //       _position = p;
    //     });
    // audioCache.play('background.mp3');
  }

  static List<charts.Series<PostReactions, String>> _createRandomData(
      likes, dislikes, noComments) {
    final likesCountData = [
      new PostReactions('reactions', likes),
    ];
    final disLikesCountData = [
      new PostReactions('reactions', dislikes),
    ];

    final noCommentsCountData = [
      new PostReactions('reactions', noComments),
    ];

    return [
      charts.Series<PostReactions, String>(
          id: 'Likes',
          domainFn: (PostReactions reaction, _) => reaction.type,
          measureFn: (PostReactions reaction, _) => reaction.no,
          data: likesCountData,
          fillColorFn: (PostReactions reaction, _) {
            return charts.MaterialPalette.green.shadeDefault;
          }),
      new charts.Series<PostReactions, String>(
          id: 'Dislikes',
          domainFn: (PostReactions reaction, _) => reaction.type,
          measureFn: (PostReactions reaction, _) => reaction.no,
          data: disLikesCountData,
          fillColorFn: (PostReactions reaction, _) {
            return charts.MaterialPalette.red.shadeDefault;
          }),
      new charts.Series<PostReactions, String>(
          id: 'Nota',
          domainFn: (PostReactions reaction, _) => reaction.type,
          measureFn: (PostReactions reaction, _) => reaction.no,
          data: noCommentsCountData,
          fillColorFn: (PostReactions reaction, _) {
            return charts.MaterialPalette.deepOrange.shadeDefault;
          }),
    ];
  }

  getRules() async {
    QuerySnapshot snapshot = await rulesRef.getDocuments();
    setState(() {
      rules.addAll(
          snapshot.documents.map((doc) => Rules.fromDocument(doc)).toList());
    });
  }

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircleAvatar(
            backgroundColor: Colors.transparent,
          );
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
              onTap: () => showProfile(context, profileId: user.id),
              child: Column(children: <Widget>[
                Row(
                  //ROW 1
                  children: [
                    Container(
                      child: Text(
                        user.username,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        // 0 10 * * FRI
                      ),
                    ),
                    Container(
                      height: 30.0,
                      width: 30.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(user.credits == "1"
                              ? 'assets/images/goldmedal.jpg'
                              : user.credits == "2"
                                  ? 'assets/images/silvermedal.jpg'
                                  : user.credits == "3"
                                      ? 'assets/images/brongemedal.jpg'
                                      : 'assets/images/plainwhite.png'),
                          fit: BoxFit.fill,
                        ),
                        shape: BoxShape.circle,
                      ),
                    )
                  ],
                ),
              ])),
          subtitle: Text(timeago.format(timestamp.toDate())),
          trailing: TimerApp(timestamp: timestamp, expiresIn: 48),
          // OtpTimer(timestamp:timestamp),
          // Text(TimerApp()),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Remove this post?"),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePost();
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  )),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }

  // Note: To delete post, ownerId and currentUserId must be equal, so they can be used interchangeably
  deletePost() async {
    userPostRef.document(postId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // storageRef.child("post_$postId.jpg").delete();
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(postId)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePost() async {
    usersRef
        .where("id", isEqualTo: currentUserId)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        userData.add(User.fromDocument(doc));
        getPostDeductionValueLike(
            postDeductionValue, userData[0].referralPoints);
      });
    });
  }

  handleNoCommentPost() {
    bool _isNoComment = noComments[currentUserId] == true;

    // if (currentUser.referralPoints >= postDeductionValue) {

    if (!_isNoComment) {
      userPostRef
          .document(postId)
          .updateData({'noComments.$currentUserId': true});
      addNoCommentToActivityFeed();
      addNoComment();
      // debitWalletAmount(postDeductionValue);
      // addDebitedAmountToTeamOne(postDeductionValue);
      // walletTransactions("like", postId, postDeductionValue);
      setState(() {
        noCommentsCount += 1;
        isNoComment = true;
        noComments[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
    // } else {
    //   print("ShowDIalog ****************************");
    //   _showMyDialog(
    //       "Warning", "You do not have enough points to react this post.", "");
    // }
  }

  getPostDeductionValueLike(postDeductionValue, userWallet) {
    bool _isLiked = likes[currentUserId] == true;

    // if (_isLiked) {
    //   userPostRef.document(postId).updateData({'likes.$currentUserId': false});
    //   removeLikeFromActivityFeed();
    //   setState(() {
    //     likeCount -= 1;
    //     isLiked = false;
    //     likes[currentUserId] = false;
    //   });
    //   removelike();
    // } else
    if (userWallet >= postDeductionValue) {
      if (!_isLiked) {
        userPostRef.document(postId).updateData({'likes.$currentUserId': true});
        addLikeToActivityFeed();
        addlike();
        debitWalletAmount(postDeductionValue, userWallet);
        addDebitedAmountToPostPoolingAmount(postDeductionValue, postId);
        walletTransactions("like", postId, postDeductionValue);
        setState(() {
          likeCount += 1;
          isLiked = true;
          likes[currentUserId] = true;
          showHeart = true;
        });
        Timer(Duration(milliseconds: 500), () {
          setState(() {
            showHeart = false;
          });
        });
      }
    } else {
      _showMyDialog(
          "Warning", "You do not have enough points to react this post.", "");
    }
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

  handleDisLikePost() async {
    usersRef
        .where("id", isEqualTo: currentUserId)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        userData.add(User.fromDocument(doc));

        getPostDeductionValueForDisLike(
            postDeductionValue, userData[0].referralPoints);
      });
    });
  }

  getPostDeductionValueForDisLike(postDeductionValue, userWallet) {
    bool _isDisLiked = disLikes[currentUserId] == true;
    // if (_isDisLiked) {
    //   userPostRef
    //       .document(postId)
    //       .updateData({'disLikes.$currentUserId': false});
    //   removeDisLikeFromActivityFeed();
    //   setState(() {
    //     disLikesCount -= 1;
    //     isDisLiked = false;
    //     disLikes[currentUserId] = false;
    //     //  LikesAndDislikes(likes: likeCount, disLikes: disLikesCount);
    //   });
    //   removeDislike();
    // } else
    if (userWallet >= postDeductionValue) {
      if (!_isDisLiked) {
        userPostRef
            .document(postId)
            .updateData({'disLikes.$currentUserId': true});
        addDisLikeToActivityFeed();
        addDislike();
        debitWalletAmount(postDeductionValue, userWallet);
        addDebitedAmountToPostPoolingAmount(postDeductionValue, postId);
        walletTransactions("like", postId, postDeductionValue);
        setState(() {
          disLikesCount += 1;
          isDisLiked = true;
          disLikes[currentUserId] = true;
          showHeart = true;
        });
        Timer(Duration(milliseconds: 500), () {
          setState(() {
            showHeart = false;
          });
        });
      }
    } else {
      _showMyDialog(
          "Warning", "You do not have enough points to react this post.", "");
    }
  }

  removelike() {
    likesRef
        .document(postId)
        .collection("Likes")
        .document(ownerId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  removeNoComment() {
    likesRef
        .document(postId)
        .collection("noComments")
        .document(ownerId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  removeDislike() {
    disLikesRef
        .document(postId)
        .collection("DisLikes")
        .document(ownerId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  debitWalletAmount(postDeductionValue, userWallet) {
    usersRef.document(currentUserId).setData({
      "id": currentUser.id,
      "username": currentUser.username,
      "photoUrl": currentUser.photoUrl,
      "email": currentUser.email,
      "displayName": currentUser.displayName,
      "bio": currentUser.bio,
      "timestamp": timestamp,
      "credits": currentUser.credits,
      "referralPoints": userWallet - postDeductionValue,
      "extraInfo": currentUser.extraInfo,
    });
  }

  addlike() {
    likesRef.document(postId).collection("Likes").document(ownerId).setData({
      "username": currentUser.username,
      "liked": true,
      "timestamp": new DateTime.now(),
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });
  }

  addNoComment() {
    likesRef
        .document(postId)
        .collection("noComments")
        .document(ownerId)
        .setData({
      "username": currentUser.username,
      "noComment": true,
      "timestamp": new DateTime.now(),
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });
  }

  addDislike() {
    disLikesRef
        .document(postId)
        .collection("DisLikes")
        .document(ownerId)
        .setData({
      "username": currentUser.username,
      "disliked": true,
      "timestamp": new DateTime.now(),
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });
  }

  walletTransactions(action, postId, postDeductionValue) {
    walletTransactionRef.document(postId).setData({
      "userId": ownerId,
      "transactionType": "Debit",
      "amount": postDeductionValue,
      "reason":
          action == "like" ? getLikeReason(postId) : getDisLikeReason(postId),
    });
  }

  addDebitedAmountToPostPoolingAmount(userPostdeductionValue, postId) {
    poolAmountRef
        .where('postId', isEqualTo: postId)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        poolAmount.add(PoolAmount.fromDocument(doc));

        poolAmountRef.document(poolAmount[0].postId).setData({
          "postAmount": poolAmount[0].postAmount + userPostdeductionValue,
          "postId": postId
        });
      });
    });
  }

  getLikeReason(postId) {
    return "you liked the post:" + postId.toString();
  }

  getDisLikeReason(postId) {
    return "you DisLiked the post:" + postId.toString();
  }

  addNoCommentToActivityFeed() {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "noComment",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeNoCommentFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  addLikeToActivityFeed() {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  addDisLikeToActivityFeed() {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "Dislike",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeDisLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildDescription() {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            Expanded(child: Text(description))
          ],
        ),
        
      ],
    );
  }

  emptyWidget() {
    return Column();
  }

  
buildDesciptionImage(description, context) {

  return  Stack(
        alignment: Alignment.center,
        children: <Widget>[
Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height - 280,
    decoration: BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.redAccent, Colors.pinkAccent]),
    ),
    child: Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
              child: Text(
            description,
            maxLines: 3,
            style: TextStyle(color: Colors.white, fontSize: 25.0),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ))
        ],
      ),
    ),
  ),
  !isDisLiked && !isLiked && !isNoComment? Positioned(
                                  right:0.0,                                    
                                   top:0.0,
                                      child: countDownTimer(),
                                    ):Text(""),
        ]);
   
}

  buildPostImage() {
    return GestureDetector(
      // onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
             !isDisLiked && !isLiked && !isNoComment? Positioned(
                                  right:0.0,                                    
                                   top:0.0,
                                      child: countDownTimer(),
                                    ):Text(""),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 300),
                  tween: Tween(begin: 0.8, end: 1.4),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (anim) => Transform.scale(
                        scale: anim.value,
                        child: Icon(
                          Icons.favorite,
                          size: 80.0,
                          color: Colors.red,
                        ),
                      ),
                )
              : Text(""),
        ],
      ),
    );
  }


countDownTimer(){
  return CircularCountDownTimer(
        // Countdown duration in Seconds
        duration: 20,

        // Controller to control (i.e Pause, Resume, Restart) the Countdown
        controller: _controller,

        // Width of the Countdown Widget
        width: MediaQuery.of(context).size.width / 5,

        // Height of the Countdown Widget
        height: MediaQuery.of(context).size.height / 5,

        // Default Color for Countdown Timer
        color: Colors.grey,

        // Filling Color for Countdown Timer
        fillColor: Colors.red,

        // Background Color for Countdown Widget
        backgroundColor: Colors.black12,

        // Border Thickness of the Countdown Circle
        strokeWidth: 0.0,

        // Text Style for Countdown Text
        textStyle: TextStyle(
            fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.bold),

        // true for reverse countdown (max to 0), false for forward countdown (0 to max)
        isReverse: true,

        // true for reverse animation, false for forward animation

        // Optional [bool] to hide the [Text] in this widget.
        isTimerTextShown: true,

        // Function which will execute when the Countdown Ends
        onComplete: () {
          // Here, do whatever you want
          print('Countdown Ended');
        },
      );
}
  buildPostVideo() {
    _videoPlayerController = VideoPlayerController.network(
      mediaUrl,
    );
    futureController = _videoPlayerController.initialize();
    _videoPlayerController.play();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.setVolume(25.0);
    return   Stack(
        alignment: Alignment.center,
        children: <Widget>[
      FutureBuilder(
      future: futureController,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController),
          );
        } else {
          return Center(child: linearProgress());
        }
      },
    ),
   !isDisLiked && !isLiked && !isNoComment? Positioned(
                                  right:0.0,                                    
                                   top:0.0,
                                      child: countDownTimer(),
                                    ):Text(""),
          
        ]);
    
    
  }

  getvideo(mediaUrl) {
    _videoPlayerController = VideoPlayerController.network(mediaUrl);
    futureController = _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.setVolume(25.0);
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            isLiked
                ? GestureDetector(
                    onTap: handleLikePost,
                    child: Icon(
                      Icons.thumb_up,
                      size: 28.0,
                      color: Colors.green,
                    ))
                : isDisLiked
                    ? GestureDetector(
                        onTap: handleDisLikePost,
                        child: Icon(
                          Icons.thumb_down,
                          size: 28.0,
                          color: Colors.red,
                        ))
                    : isNoComment
                        ? GestureDetector(
                            onTap: handleNoCommentPost,
                            child: Icon(
                              Icons.not_interested,
                              size: 28.0,
                              color: Colors.deepOrange,
                            ))
                        : Row(
                            children: <Widget>[
                              GestureDetector(
                                  onTap: handleLikePost,
                                  child: Icon(
                                    Icons.thumb_up,
                                    size: 28.0,
                                    color: Colors.grey,
                                  )),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: 40.0, left: 80.0)),
                              GestureDetector(
                                  onTap: handleDisLikePost,
                                  child: Icon(
                                    Icons.thumb_down,
                                    size: 28.0,
                                    color: Colors.grey,
                                  )),
                              Padding(
                                  padding:
                                      EdgeInsets.only(top: 40.0, left: 80.0)),
                              GestureDetector(
                                  onTap: handleNoCommentPost,
                                  child: Icon(
                                    Icons.not_interested,
                                    size: 28.0,
                                    color: Colors.grey,
                                  ))
                            ],
                          ),
            Padding(padding: EdgeInsets.only(top: 40.0, left: 10.0)),
            GestureDetector(
              onTap: () => showComments(
                    context,
                    postId: postId,
                    ownerId: ownerId,
                    mediaUrl: mediaUrl,
                  ),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        currentUserId == ownerId || isDisLiked || isLiked || isNoComment
            ? Divider(
                color: Colors.black,
              )
            : Divider(
                color: Colors.transparent,
              ),
        currentUserId == ownerId || isDisLiked || isLiked || isNoComment
            ? Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 70.0,
                          child: barChart(
                              likeCount, disLikesCount, noCommentsCount),
                        )
                      ],
                    ),
                  )
                ],
              )
            : emptyWidget(),
      ],
    );
  }

  barChart(likes, dislikes, noComments) {
    return new charts.BarChart(
      _createRandomData(likes, dislikes, noComments),
      animate: true,
      barGroupingType: charts.BarGroupingType.stacked,
      vertical: false,
      primaryMeasureAxis: new charts.NumericAxisSpec(
        renderSpec: new charts.NoneRenderSpec(),
        tickProviderSpec: new charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            charts.TickSpec<num>(0),
            charts.TickSpec<num>(5),
            charts.TickSpec<num>(10),
          ],
        ),
      ),
      domainAxis: new charts.OrdinalAxisSpec(
          showAxisLine: true, renderSpec: new charts.NoneRenderSpec()),
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    isDisLiked = (disLikes[currentUserId] == true);
    isNoComment = (noComments[currentUserId] == true);
    if (fromPage == "postTile") {
      return Scaffold(
          appBar: header(context, titleText: "Post Details"),
          body: ListView(
            children: <Widget>[
              buildPostHeader(),
              postType == ""
                  ? buildDesciptionImage(description, context)
                  : description != "" ? buildDescription() : emptyWidget(),
              postType == ""
                  ? emptyWidget()
                  : postType == "image" ? buildPostImage() : buildPostVideo(),
              buildPostFooter(),
              // buildDevider()
            ],
          ));
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildPostHeader(),
          postType == ""
              ? buildDesciptionImage(description, context)
              : description != "" ? buildDescription() : emptyWidget(),
          postType == ""
              ? emptyWidget()
              : postType == "image" ? buildPostImage() : buildPostVideo(),
          buildPostFooter(),
          buildDevider()
        ],
      );
    }
  }
}


showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}

buildDevider() {
  return Container(
    height: 10.0,
    decoration: new BoxDecoration(
      color: Colors.grey,
    ),
  );
}

showlikes(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Likes(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
