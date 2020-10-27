import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/contest_timeLine.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostTile extends StatelessWidget {
  final Post post;
  VideoPlayerController _videoPlayerController;
  Future<void> futureController;
  PostTile(this.post);

  showPost(context) {
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

  @override
  Widget build(BuildContext context) {
    OverlayEntry _popupDialog;
    return GestureDetector(
      onLongPress: () {
        _popupDialog = _createPopupDialog(post, context);
        Overlay.of(context).insert(_popupDialog);
      },
      onLongPressEnd: (details) => _popupDialog?.remove(),
      onDoubleTap: () => showPost(context),
      child: post.postType == ""
          ? buildDescription(post.description)
          : post.postType == "image"
              ? ClipRRect(
  borderRadius: BorderRadius.circular(0.0),
  child: 
              cachedNetworkImage(post.mediaUrl))
              : Container(
     
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey, Colors.black]),
               border: Border.all(
      color: Colors.red[500],
    ),
   borderRadius: BorderRadius.circular(0)
              ),
              
             child: buildPostVideo(post.mediaUrl),)
    );
  }

 

  buildPostVideo(mediaUrl) {
    _videoPlayerController = VideoPlayerController.network(
      mediaUrl,
    );
    futureController = _videoPlayerController.initialize();
    _videoPlayerController.play();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.setVolume(25.0);
    return FutureBuilder(
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
    );
  }

  buildDescription(description) {
    return Container(
     
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey, Colors.black]),
               
   borderRadius: BorderRadius.circular(0)
              ),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: Text(
              description,
              maxLines: 3,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ))
          ],
        ),
      ),
    );
  }

  buildDescriptionforpopup(description, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 280,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey, Colors.black])),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 10.0)),
            Expanded(
                child: Text(
              description,
              maxLines: 3,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ))
          ],
        ),
      ),
    );
  }

  OverlayEntry _createPopupDialog(Post post, context) {
    return OverlayEntry(
      builder: (context) => AnimatedDialog(
            child: _createPopupContent(post, context),
          ),
    );
  }

  Widget _createPopupContent(post, context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildPostHeader(post.ownerId, post.timestamp),
              post.postType == ""
                  ? buildDescriptionforpopup(post.description, context)
                  : post.postType == "image"
                      ? buildImgae(post.mediaUrl, context)
                      : buildPostVideo(post.mediaUrl),
              // _createActionBar(),
            ],
          ),
        ),
      );

  buildImgae(mediaUrl, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width + 100,
      child: cachedNetworkImage(mediaUrl),
    );
  }

  buildPostHeader(ownerId, timestamp) {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircleAvatar(
            backgroundColor: Colors.transparent,
          );
        }
        User user = User.fromDocument(snapshot.data);
        return Container(
          color: Colors.white,
          child: ListTile(
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
            // trailing: TimerApp(timestamp: post.timestamp, expiresIn: 48),
            // OtpTimer(timestamp:timestamp),
            // Text(TimerApp()),
          ),
        );
      },
    );
  }

  Widget _createActionBar() => Container(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.favorite_border,
              color: Colors.white,
            ),
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
            ),
            Icon(
              Icons.send,
              color: Colors.white,
            ),
          ],
        ),
      );
}

class AnimatedDialog extends StatefulWidget {
  const AnimatedDialog({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => AnimatedDialogState();
}

class AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> opacityAnimation;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.easeOutExpo);
    opacityAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutExpo));

    controller.addListener(() => setState(() {}));
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(opacityAnimation.value),
      child: Center(
        child: FadeTransition(
          opacity: scaleAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
