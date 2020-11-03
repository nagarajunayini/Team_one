import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/postCategory.dart';
import 'package:fluttershare/models/rules.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/activity_feed.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/search.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

//=================================

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  File file;
  String mediaUrl = "";
  String location = "";
  List<Post> posts = [];
  List<User> userData = [];
  List<User> userList = [];
  List<Rules> rules = [];
  int userValue = 0;
  bool isUploading = false;
  bool isUsersLoading = true;
  int defaultIndex = 0;
  List<Categories> postCategories = [];
  String fileType = "";
  String postId = Uuid().v4();
  bool isPostsLoading = true;
   Duration _duration = new Duration();
  Duration _position = new Duration();
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  List<String> filters = [
    "All",
    "Featured Today's",
    "10",
    "100",
    "500",
    "1000",
    "2000",
    "3000",
    "sports",
    "politics",
    "education",
    "technology",
    "job"
  ];
  String selectedFilters = "All";
  @override
  void initState() {
    super.initState();
    getRules();
    getCurrentUser();
    getProfilePosts();
    getPostCategories();
    getAllUsers();
    initPlayer();
  }
void initPlayer() {
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache();

    advancedPlayer.durationHandler = (d) => setState(() {
          _duration = d;
        });

    advancedPlayer.positionHandler = (p) => setState(() {
          _position = p;
        });
    audioCache.play('background.mp3');
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

  // buildProfilePosts() {
  //   if (isLoading) {
  //     return circularProgress();
  //   }
  //   return Column(
  //     children: posts,
  //   );
  // }

  buildDevider() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('TEAM ONE'),
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
          buildFilters(),
          buildDevider(),

          Expanded(
            child: buildProfilePosts(),
            // child: ListView(
            //   children: <Widget>[
            //                               buildLikeStaggered(0,1,2),
            //                               buildLikeStaggered1(3,4,5),
            //                               buildLikeStaggered2(6,5,8),
            //                               buildLikeStaggered2(9,10,11),
            //                                buildLikeStaggered(12,13,14),


               
            //     Divider(
            //       height: 2.0,
            //     ),
            //   ],
            // ),
          ),
          // Divider(),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  buildFilters() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      height: MediaQuery.of(context).size.height * 0.06,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          itemBuilder: (context, index) {
            return Container(
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.grey)),
                color: filters[index] == selectedFilters
                    ? Colors.lightGreen
                    : Colors.white,
                textColor: filters[index] == selectedFilters
                    ? Colors.white
                    : Colors.grey,
                onPressed: () => {
                      setState(() {
                        selectedFilters = filters[index];
                        posts = [];
                        isLoading = true;
                        getDocumentDetails();
                      })
                    },
                child: Text(
                  filters[index].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.0,
                  ),
                ),
              ),
            );
          }),
    );
  }

  buildLikeStaggered1(one,two,three){
  if (isLoading) {
      return Container();
    } else {
     return Container(
       height:300.0,
       width: MediaQuery.of(context).size.width,
       child:Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
         Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child:  Container(width: 242,child:  PostTile(posts[one])),
         
          ),
        Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),

          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Padding(
              padding: const EdgeInsets.only(bottom:2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 148.0, width: MediaQuery.of(context).size.width-244,
                  child:  PostTile(posts[two])),
                ],
              ),
            ),
            Container(height: 148.0,width: MediaQuery.of(context).size.width-244, child:   PostTile(posts[three])),
          ]),
        ),
        
        
      ]) ,);
     
     ;
     
    
  }
}

buildLikeStaggered2(one,two,three){
  if (isLoading) {
      return Container();
    } else {
     return Container(
       height:120.0,
       width: MediaQuery.of(context).size.width,
       child:Row(
         crossAxisAlignment: CrossAxisAlignment.stretch, 
         children: [
        Padding(
          padding: const EdgeInsets.only(top:1.0,right: 2.0,bottom: 2.0),
          child:  Container(  width: MediaQuery.of(context).size.width/3,child:  PostTile(posts[one])),
        ),
        Padding(
          padding: const EdgeInsets.only(top:1.0,right:2.0,bottom: 2.0),
          child:  Container( width: MediaQuery.of(context).size.width/3,child:  PostTile(posts[two])),
         
          ),
          Padding(
          padding: const EdgeInsets.only(top:1.0,bottom: 2.0),
          child:  Container( width: MediaQuery.of(context).size.width/3-4,child:  PostTile(posts[three])),
         
          ),
        
      ]) ,);
     
     ;
     
    
  }
}

buildLikeStaggered(one,two,three){
  if (isLoading) {
      return Container();
    } else {
     return Container(
       height:300.0,
       width: MediaQuery.of(context).size.width,
       child:Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.only(bottom:1.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Padding(
              padding: const EdgeInsets.only(bottom:2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 147.0, width:119, 
                  child:  PostTile(posts[one])),
                ],
              ),
            ),
            Container(height: 148.0,width:119, child:   PostTile(posts[three])),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(left:2.0,bottom: 3.0),
          child:  Container(width:MediaQuery.of(context).size.width-121,child:  PostTile(posts[two])),
         
          ),
        
      ]) ,);
     
     ;
     
    
  }
}
  buildProfilePosts() {
    if (isLoading) {
      return linearProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/no_content.svg', height: 260.0),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                "No Posts",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // List<GridTile> gridTiles = [];
      // posts.forEach((post) {
      //   gridTiles.add(GridTile(child: PostTile(post)));
      // });
      return StaggeredGridView.countBuilder(
      crossAxisCount: 3,
      itemCount: posts.length,
      itemBuilder: (context, index) => PostTile(posts[index]),
      staggeredTileBuilder: (index) => StaggeredTile.count(
          (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
    );
      
      // GridView.count(
      //   crossAxisCount: 3,
      //   childAspectRatio: 1.0,
      //   mainAxisSpacing: 2.5,
      //   crossAxisSpacing: 1.5,
      //   shrinkWrap: true,
      //   physics: NeverScrollableScrollPhysics(),
      //   children: gridTiles,
      // );
    }
  }
}

class ImageCard extends StatelessWidget {
  const ImageCard({this.imageData});

  final ImageData imageData;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Image.network(imageData.imageUrl, fit: BoxFit.cover),
    );
  }
}

class ImageData {
  final String id;
  final String imageUrl;

  const ImageData({
    @required this.id,
    @required this.imageUrl,
  });
}

const imageList = [
  ImageData(
    id: 'id-001',
    imageUrl: 'https://picsum.photos/seed/image001/500/500',
  ),
  ImageData(
    id: 'id-002',
    imageUrl: 'https://picsum.photos/seed/image002/500/800',
  ),
  ImageData(
    id: 'id-003',
    imageUrl: 'https://picsum.photos/seed/image003/500/300',
  ),
  ImageData(
    id: 'id-004',
    imageUrl: 'https://picsum.photos/seed/image004/500/900',
  ),
  ImageData(
    id: 'id-005',
    imageUrl: 'https://picsum.photos/seed/image005/500/600',
  ),
  ImageData(
    id: 'id-006',
    imageUrl: 'https://picsum.photos/seed/image006/500/500',
  ),
  ImageData(
    id: 'id-007',
    imageUrl: 'https://picsum.photos/seed/image007/500/400',
  ),
  ImageData(
    id: 'id-008',
    imageUrl: 'https://picsum.photos/seed/image008/500/700',
  ),
  ImageData(
    id: 'id-009',
    imageUrl: 'https://picsum.photos/seed/image009/500/600',
  ),
  ImageData(
    id: 'id-010',
    imageUrl: 'https://picsum.photos/seed/image010/500/900',
  ),
  ImageData(
    id: 'id-011',
    imageUrl: 'https://picsum.photos/seed/image011/500/900',
  ),
  ImageData(
    id: 'id-012',
    imageUrl: 'https://picsum.photos/seed/image012/500/700',
  ),
  ImageData(
    id: 'id-013',
    imageUrl: 'https://picsum.photos/seed/image013/500/700',
  ),
  ImageData(
    id: 'id-014',
    imageUrl: 'https://picsum.photos/seed/image014/500/800',
  ),
  ImageData(
    id: 'id-015',
    imageUrl: 'https://picsum.photos/seed/image015/500/500',
  ),
  ImageData(
    id: 'id-016',
    imageUrl: 'https://picsum.photos/seed/image016/500/700',
  ),
  ImageData(
    id: 'id-017',
    imageUrl: 'https://picsum.photos/seed/image017/500/600',
  ),
  ImageData(
    id: 'id-018',
    imageUrl: 'https://picsum.photos/seed/image018/500/900',
  ),
  ImageData(
    id: 'id-019',
    imageUrl: 'https://picsum.photos/seed/image019/500/800',
  ),
];
