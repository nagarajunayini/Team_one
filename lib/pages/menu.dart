import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/models/userLevels.dart';
import 'package:fluttershare/pages/create_group.dart';
import 'package:fluttershare/pages/edit_profile.dart';
import 'package:fluttershare/pages/mystats.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:fluttershare/pages/wallet_transactions.dart';
import 'package:share/share.dart';
import 'package:fluttershare/pages/upload.dart';

import 'home.dart';

class Menu extends StatefulWidget {

  final User currentUser;
  List<PostValues> postValues;

  Menu({this.currentUser, this.postValues});

  @override
  _MenuState createState() => _MenuState(postValues: this.postValues,);

}

class _MenuState extends State<Menu> {
    final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int walletPoints = 0;
  
  List<User> userData = [];
  List<PostValues> postValues;
 _MenuState({this.postValues});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

 
  getCurrentUser() async {
    QuerySnapshot snapshot = await usersRef
        .where("id", isEqualTo: currentUserId)
        .getDocuments();
    setState(() {
      isLoading = true;
      userData.addAll(
          snapshot.documents.map((doc) => User.fromDocument(doc)).toList());
          walletPoints =userData[0].referralPoints;
    });
  }
  @override
  Widget build(BuildContext context) {
    return buildWidget();
    
    
  }

  buildWidget(){
    if(!isLoading){
      return Scaffold(
        backgroundColor: Color(0xFF000000),
        body:Center(
          child:CircularProgressIndicator(
              value: 100,
              semanticsLabel: 'Linear progress indicator',
            ),
        )
        
      );
    }else{
 return Scaffold(
    backgroundColor: Color(0xFF000000),
      body: ListView(
        children: <Widget>[
          Row(
            children: [
            IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.menu,
              size: 30.0,
              color: Colors.grey,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left:100.0),
            child:Text("Settings",
          style: TextStyle(color:Color(0xCCFFFFFF), fontSize: 17.0, fontWeight: FontWeight.w600),
          textAlign:TextAlign.center,
          ) ,
          ),
          
            ],
          ),
          Padding(padding: EdgeInsets.all(10.0)),
          Center(
            child:Column(children: [
              GestureDetector(
            onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(profileId: currentUser?.id),
                    ),
                  )
                },
                
               child: CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(currentUser.photoUrl)),
                

              ),
              Text(
                    currentUser.username,
                    style: TextStyle(
                      color: Color(0xE6FFFFFF),
                        fontSize: 25,
                        fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                  ),
                  Text(
                    "See your profile",
                    style: TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
              
              
              


            ],)
            
          ),
          
          Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0, top:15.0),
            // child: Divider(
            //   color: Colors.grey,
            // ),
          ),
          // Card(
          //     margin: EdgeInsets.only(left: 15.0, right: 15.0),
          //     child: ListTile(
          //       title: Text(
          //         "Wallet " + " " + walletPoints.toString(),
          //         style: TextStyle(
          //             color: Colors.black,
          //             fontSize: 15,
          //             fontWeight: FontWeight.bold),
          //       ),
          //       leading: Icon(
          //         Icons.book,
          //         color: Colors.red,
          //       ),
          //     )),
              GestureDetector(
                
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Wallet_Transactions(profileId: currentUser?.id, postValues:postValues),
                    ),
                  )
              },
              child: Card(
                color: Color(0xFF000000),
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Wallet " + " " + currentUser?.referralPoints.toString(),
                      style: TextStyle(
                         color: Color(0xE6FFFFFF),

                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(
                      Icons.wallet_giftcard,
                      color: Colors.red,
                    ),
                  ))),
          SizedBox(
            height: 10.0,
          ),
          GestureDetector(
              onTap: () => {
                 Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Mystats(currentUserId: currentUser?.id)))
              },
              child: Card(
                color: Color(0xFF000000),
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "My Stats",
                      style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(
                      Icons.bar_chart,
                      color: Colors.red,
                    ),
                  ))),
          SizedBox(
            height: 10.0,
          ),
          GestureDetector(
              onTap: () => {
                Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUser?.id)))
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => Groups(currentUser: currentUser),
                //     ),
                //   )
              },
              child: Card(
                color: Color(0xFF000000),
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "My Profile",
                      style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(
                      Icons.people,
                      color: Colors.red,
                    ),
                  ))),
          SizedBox(
            height: 10.0,
          ),
           GestureDetector(
              onTap: () => {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => Groups(currentUser: currentUser),
                //     ),
                //   )
              },
              child: Card(
                color: Color(0xFF000000),
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Feedback",
                      style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(
                      Icons.question_answer,
                      color: Colors.red,
                    ),
                  ))),
          SizedBox(
            height: 10.0,
          ),
          GestureDetector(
              onTap: () => generateShortDeepLink(),
              child: Card(
                color: Color(0xFF000000),
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Refer & Earn",
                      style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Refer this app and earn 50 points",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                    leading: Icon(
                      Icons.share,
                      color: Colors.red,
                    ),
                  ))),
          SizedBox(
            height: 10.0,
          ),
          GestureDetector(
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Upload(
                                  currentUser:  currentUser,
                                  postValue: 200,
                                  postDeductionValue:1,
                                      postLevel:'Brodcast'),
                    ),
                  )
              },
              child: Card(
                color: Color(0xFF000000),
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Brodcast Message",
                      style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(
                      Icons.question_answer,
                      color: Colors.red,
                    ),
                  ))),
          SizedBox(
            height: 10.0,
          ),
          GestureDetector(
              onTap: () => {},
              child: Card(
                color: Color(0xFF000000),
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Buyout Coins",
                      style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(
                      Icons.question_answer,
                      color: Colors.red,
                    ),
                  ))),
          SizedBox(
            height: 10.0,
          ),
          GestureDetector(
              onTap: () => {},
              child: Card(
                color: Color(0xFF000000),
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Privacy",
                      style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(
                      Icons.settings,
                      color: Colors.red,
                    ),
                  ))),
          SizedBox(
            height: 10.0,
          ),
          GestureDetector(
              onTap: () => logout(),
              child: Card(
                color: Color(0xFF000000),
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Logout",
                      style: TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Icon(
                      Icons.exit_to_app,
                      color: Colors.red,
                    ),
                  )))
        ],
      ),
    );
    }
   
  }

  logout() async {
     await FirebaseAuth.instance.signOut();
               final FirebaseUser user = await FirebaseAuth.instance.currentUser();

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                  (route) => false);
    // await googleSignIn.signOut();
    // Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }
  generateShortDeepLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://socialnetworkingsite.page.link',
      link: Uri.parse('https://socialnetworkingsite.page.link'),
      androidParameters: AndroidParameters(
        packageName: 'com.teamone.socialnetworkingsite',
        minimumVersion: 125,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.ios',
        minimumVersion: '1.0.1',
        appStoreId: '123456789',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'example-promo',
        medium: 'social',
        source: 'orkut',
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short),
      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
        providerToken: '123456',
        campaignToken: 'referral-promo',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'App link',
        description: 'Refere this app to your loved one and earn.',
      ),
    );

    final Uri deepLink = await parameters.buildUrl();
    Share.share("https://firebasestorage.googleapis.com/v0/b/stand-iv.appspot.com/o/stand_IV_V1.0.0.apk?alt=media&token=576659b4-885f-4674-9e7b-090e5bf9c95b" + " "+ " use "+ currentUserId+ " code to get the referal bonus");
// _showMyDialog(deepLink);
    print(deepLink);
  }
}
