import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class Mystats extends StatefulWidget {
  final String currentUserId;

  Mystats({this.currentUserId});

  @override
  _MystatsState createState() => _MystatsState();
}

class _MystatsState extends State<Mystats> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  String username;
  final _formKey = GlobalKey<FormState>();
  User user;
  List<Post> posts = [];
  int bronzePosted=0;
  int silverPosted=0;
  int goldPosted=0;
  int platinumPosted=0;
  int daimondPosted=0;
  int d_agreed=0;
  int d_disagreed=0;
  int d_nuetral=0;
  int p_agreed=0;
  int p_disagreed=0;
  int p_nuetral=0;
  int g_agreed=0;
  int g_disagreed=0;
  int g_nuetral=0;
  int s_agreed=0;
  int s_disagreed=0;
  int s_nuetral=0;
  int b_agreed=0;
  int b_disagreed=0;
  int b_nuetral=0;
  List<Post> posts_daimond =[];
  List<Post> posts_daimond_agreed =[];
  List<Post> posts_daimond_disagreed =[];
  List<Post> posts_daimond_nuetral =[];
  List<Post> posts_platinum_agreed =[];
  List<Post> posts_platinum_disagreed =[];
  List<Post> posts_platinum_nuetral =[];
  List<Post> posts_platinum =[];
  List<Post> posts_gold =[];
  List<Post> posts_gold_agreed =[];
  List<Post> posts_gold_disagreed =[];
  List<Post> posts_gold_nuetral =[];
  List<Post> posts_silver =[];
  List<Post> posts_silver_agreed =[];
  List<Post> posts_silver_disagreed =[];
  List<Post> posts_silver_nuetral =[];
  List<Post> posts_bronze =[];
   List<Post> posts_bronze_agreed =[];
  List<Post> posts_bronze_disagreed =[];
  List<Post> posts_bronze_nuetral =[];

  

  @override
  void initState() {
    super.initState();
    getUser();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await userPostRef
        .where("ownerId", isEqualTo:widget.currentUserId)
        .getDocuments();
    setState(() {
      isLoading = false;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
      print(posts.length);
       print("posts");
      print(posts );
      posts_daimond = posts.where((i) => i.postLevel == 'Daimond').toList();
      posts_platinum =posts.where((i) => i.postLevel == 'Platinum').toList();
      posts_gold =posts.where((i) => i.postLevel == 'Gold').toList();
      posts_silver =posts.where((i) => i.postLevel == 'Silver').toList();
      posts_bronze =posts.where((i) => i.postLevel == 'Bronze').toList();
      print("diamond");
      print(posts_daimond );
      print("posts_platinum");
      print(posts_platinum );
      print("posts_gold");
      print(posts_gold );
      print("posts_silver");
      print(posts_silver );
      print("posts_bronze");
      print(posts_bronze );
      posts_daimond_agreed = posts_daimond.where((i)=>i.finalPostStatus=="won").toList();
      posts_daimond_disagreed = posts_daimond.where((i)=>i.finalPostStatus=="lost").toList();
      posts_daimond_nuetral = posts_daimond.where((i)=>i.finalPostStatus=="nuetral").toList();

      posts_platinum_agreed = posts_platinum.where((i)=>i.finalPostStatus=="won").toList();
      posts_platinum_disagreed = posts_platinum..where((i)=>i.finalPostStatus=="lost").toList();
      posts_platinum_nuetral = posts_platinum.where((i)=>i.finalPostStatus=="nuetral").toList();

      posts_gold_agreed = posts_gold.where((i)=>i.finalPostStatus=="won").toList();
      posts_gold_disagreed = posts_gold.where((i)=>i.finalPostStatus=="lost").toList();
      posts_gold_nuetral = posts_gold.where((i)=>i.finalPostStatus=="nuetral").toList();

      posts_silver_agreed = posts_silver.where((i)=>i.finalPostStatus=="won").toList();
      posts_silver_disagreed = posts_silver.where((i)=>i.finalPostStatus=="lost").toList();
      posts_silver_nuetral = posts_silver.where((i)=>i.finalPostStatus=="nuetral").toList();

      posts_bronze_agreed = posts_bronze.where((i)=>i.finalPostStatus=="won").toList();
      posts_bronze_disagreed = posts_bronze.where((i)=>i.finalPostStatus=="lost").toList();
      posts_bronze_nuetral = posts_bronze.where((i)=>i.finalPostStatus=="nuetral").toList();

      d_agreed=posts_daimond_agreed.length;
      d_disagreed=posts_daimond_disagreed.length;
      d_nuetral=posts_daimond_nuetral.length;


      p_agreed=posts_platinum_agreed.length;
      p_disagreed=posts_platinum_disagreed.length;
      p_nuetral=posts_platinum_nuetral.length;

      g_agreed=posts_gold_agreed.length;
      g_disagreed=posts_gold_disagreed.length;
      g_nuetral=posts_gold_nuetral.length;

       s_agreed=posts_silver_agreed.length;
      s_disagreed=posts_silver_disagreed.length;
      s_nuetral=posts_silver_nuetral.length;
        b_agreed=posts_bronze_agreed.length;
      b_disagreed=posts_bronze_disagreed.length;
      b_nuetral=posts_bronze_nuetral.length;

      // setState(() {
        daimondPosted = posts_daimond.length;
        platinumPosted = posts_platinum.length;
        goldPosted = posts_gold.length;
        silverPosted = posts_silver.length;
        bronzePosted = posts_bronze.length;
      // });
    });
  }

  getUser() async {
    // setState(() {
    //   // isLoading = true;
    // });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    // setState(() {
    //   isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.all(15.0),
              child: Text("My Stats",
                  style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold)))
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(children: <Widget>[
              Container(
                  height: 26.61,
                  decoration: BoxDecoration(color: Color(0xFF333333)),
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text("Diamond",
                      style: TextStyle(color: Colors.white, fontSize: 16.0))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      Text("Posted",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(daimondPosted.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF333333),
                      ),
                      Text("Agreed",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(d_agreed.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.highlight_remove_rounded,
                        color: Colors.red,
                      ),
                      Text("Disagreed",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(d_disagreed.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.do_disturb_on_rounded,
                        color: Color(0xFFE1C300),
                      ),
                      Text("Nuetral",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(d_nuetral.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Container(
                  height: 26.61,
                  decoration: BoxDecoration(color: Color(0xFF333333)),
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text("Platinum",
                      style: TextStyle(color: Colors.white, fontSize: 16.0))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      Text("Posted",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(platinumPosted.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF448122),
                      ),
                      Text("Agreed",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(p_agreed.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.highlight_remove_rounded,
                        color: Colors.red,
                      ),
                      Text("Disagreed",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(p_disagreed.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.do_disturb_on_rounded,
                        color: Color(0xFFE1C300),
                      ),
                      Text("Nuetral",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(p_nuetral.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Container(
                  height: 26.61,
                  decoration: BoxDecoration(color: Color(0xFF333333)),
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text("Gold", style: TextStyle(color: Colors.white))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      Text("Posted",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(goldPosted.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF448122),
                      ),
                      Text("Agreed",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(g_agreed.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.highlight_remove_rounded,
                        color: Colors.red,
                      ),
                      Text("Disagreed",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(g_disagreed.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.do_disturb_on_rounded,
                        color: Color(0xFFE1C300),
                      ),
                      Text("Nuetral",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(g_nuetral.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Container(
                  height: 26.61,
                  decoration: BoxDecoration(color: Color(0xFF333333)),
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text("Silver", style: TextStyle(color: Colors.white))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      Text("Posted",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(silverPosted.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF448122),
                      ),
                      Text("Agreed",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(s_agreed.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.highlight_remove_rounded,
                        color: Colors.red,
                      ),
                      Text("Disagreed",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(s_disagreed.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.do_disturb_on_rounded,
                        color: Color(0xFFE1C300),
                      ),
                      Text("Nuetral",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(s_nuetral.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Container(
                  height: 26.61,
                  decoration: BoxDecoration(color: Color(0xFF333333)),
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text("Bronze", style: TextStyle(color: Colors.white))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      Text("Posted",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(bronzePosted.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.red,
                      ),
                      Text("Agreed",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(b_agreed.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.highlight_remove_rounded,
                        color: Colors.red,
                      ),
                      Text("Disagreed",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(b_disagreed.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                    margin: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
                    child: Row(children: [
                      Icon(
                        Icons.do_disturb_on_rounded,
                        color: Color(0xFFE1C300),
                      ),
                      Text("Nuetral",
                          style: TextStyle(color: Colors.white, fontSize: 15.0))
                    ])),
                Container(
                    margin: EdgeInsets.only(right: 25.0, top: 10.0),
                    child: Text(b_nuetral.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15.0))),
              ]),
            ]),
    );
  }
}
