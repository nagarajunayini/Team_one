import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/comments.dart';
import 'package:fluttershare/pages/contest_comments.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/home.dart' as prefix0;
import 'package:fluttershare/pages/postreaction_chart.dart';
import 'package:fluttershare/pages/showLikes.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class Contests extends StatefulWidget {
  final String contestId;
  final String ownerId;
  final String username;
  final String location;
  final Timestamp timestamp;
  final String description;
  final String mediaUrl;
  final dynamic likes;
  final dynamic disLikes;
  final dynamic comments;
  final String contestType;
  final bool contestExpired;
  final int contestExpiredIn;

  Contests(
      {this.contestId,
      this.ownerId,
      this.username,
      this.location,
      this.timestamp,
      this.description,
      this.mediaUrl,
      this.likes,
      this.disLikes,
      this.comments,
      this.contestType,
      this.contestExpired,
      this.contestExpiredIn});

  factory Contests.fromDocument(DocumentSnapshot doc) {
    return Contests(
      contestId: doc['contestId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      timestamp: doc['timestamp'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
      disLikes: doc['disLikes'],
      comments: doc['comments'],
      contestType: doc['contestType'],
      contestExpired: doc['contestExpired'],
      contestExpiredIn: doc['contestExpiredIn'],
    );
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
  _ContestsState createState() => _ContestsState(
      contestId: this.contestId,
      ownerId: this.ownerId,
      username: this.username,
      location: this.location,
      timestamp: this.timestamp,
      description: this.description,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      disLikes: this.disLikes,
      disLikesCount: getDislikesCount(this.disLikes),
      likeCount: getLikeCount(this.likes),
      comments: this.comments,
      contestType: this.contestType,
      contestExpired: this.contestExpired,
      contestExpiredIn: this.contestExpiredIn,
      commentCount: getCommentCount(this.comments));
}

class _ContestsState extends State<Contests> {
  final String currentUserId = currentUser?.id;
  final String contestId;
  final String ownerId;
  final String username;
  final String location;
  final Timestamp timestamp;
  final String description;
  final String mediaUrl;
  bool showHeart = false;
  bool isLiked;
  bool isDisLiked;
  int likeCount;
  int disLikesCount;
  Map disLikes;
  int commentCount;
  Map likes;
  Map comments;
  final String contestType;
  final bool contestExpired;
  final int contestExpiredIn;

  _ContestsState(
      {this.contestId,
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
      this.contestType,
      this.contestExpired,
      this.contestExpiredIn});

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
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context),
                  icon: Icon(Icons.more_horiz),
                )
              : Text(''),
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
    userContestRef.document(contestId).get().then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // storageRef.child("post_$postId.jpg").delete();
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(ownerId)
        .collection("feedItems")
        .where('contestId', isEqualTo: contestId)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // then delete all comments
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(contestId)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    if (_isLiked) {
      userContestRef
          .document(contestId)
          .updateData({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
      removelike();
    } else if (!_isLiked) {
      userContestRef
          .document(contestId)
          .updateData({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      addlike();
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
  }

  handleDisLikePost() {
    bool _isDisLiked = disLikes[currentUserId] == true;

    if (_isDisLiked) {
      userContestRef
          .document(contestId)
          .updateData({'disLikes.$currentUserId': false});
      removeDisLikeFromActivityFeed();
      setState(() {
        disLikesCount -= 1;
        isDisLiked = false;
        disLikes[currentUserId] = false;
      });
      removeDislike();
    } else if (!_isDisLiked) {
      userContestRef
          .document(contestId)
          .updateData({'disLikes.$currentUserId': true});
      addDisLikeToActivityFeed();
      addDislike();
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
  }

  removelike() {
    likesRef
        .document(contestId)
        .collection("Likes")
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
        .document(contestId)
        .collection("DisLikes")
        .document(ownerId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  addlike() {
    likesRef.document(contestId).collection("Likes").document(ownerId).setData({
      "username": currentUser.username,
      "liked": true,
      "timestamp": timestamp,
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });
  }

  addDislike() {
    disLikesRef
        .document(contestId)
        .collection("DisLikes")
        .document(ownerId)
        .setData({
      "username": currentUser.username,
      "disliked": true,
      "timestamp": timestamp,
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });
  }

  addLikeToActivityFeed() {
    // add a notification to the postOwner's activity feed only if comment made by OTHER user (to avoid getting notification for our own like)
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(contestId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": contestId,
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
          .document(contestId)
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
          .document(contestId)
          .setData({
        "type": "Dislike",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": contestId,
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
          .document(contestId)
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

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
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
                : GestureDetector(
                    onTap: handleLikePost,
                    child: Icon(
                      Icons.thumb_up,
                      size: 28.0,
                      color: Colors.grey,
                    )),
            Padding(padding: EdgeInsets.only(top: 40.0, left: 150.0)),
            GestureDetector(
              onTap: () => showComments(
                    context,
                    contestId: contestId,
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
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 200.0),
              child: Text(
                "$commentCount comments",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    isDisLiked = (disLikes[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        description != "" ? buildDescription() : emptyWidget(),
        mediaUrl != "" ? buildPostImage() : emptyWidget(),
        buildPostFooter(),
        // buildLikesDislikesGraph(likeCount, disLikesCount),
        buildDevider()
      ],
    );
  }
}

showComments(BuildContext context,
    {String contestId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return ContestComments(
      postId: contestId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}

buildLikesDislikesGraph(likes, dislikes) {
  return Container(
    height: 100.0,
    child: LikesAndDislikes(likes: likes, disLikes: dislikes),
  );
}

buildDevider() {
  return Container(
      child: Divider(
    color: Colors.black,
  ));
}

showlikes(BuildContext context,
    {String contestId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Likes(
      postId: contestId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
