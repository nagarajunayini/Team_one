import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/create_group.dart';
import 'package:fluttershare/pages/groups.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';

import 'home.dart';

class Menu extends StatefulWidget {
  final Widget child;
  final User currentUser;
  Menu({Key key, this.child, this.currentUser}) : super(key: key);

  _MenuState createState() => _MenuState(currentUser: this.currentUser);
}

class _MenuState extends State<Menu> {
  final User currentUser;
  _MenuState({this.currentUser});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(profileId: currentUser?.id),
                    ),
                  )
                },
            child: Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: ListTile(
                  title: Text(
                    currentUser.username,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    "See your profile",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  leading: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          CachedNetworkImageProvider(currentUser.photoUrl)),
                )),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            child: Divider(
              color: Colors.grey,
            ),
          ),
          Card(
              margin: EdgeInsets.only(left: 15.0, right: 15.0),
              child: ListTile(
                title: Text(
                  "Wallet " + " " + currentUser.referralPoints.toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                leading: Icon(
                  Icons.book,
                  color: Colors.red,
                ),
              )),
          SizedBox(
            height: 10.0,
          ),
          GestureDetector(
              onTap: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateGroup(currentUser: currentUser),
                    ),
                  )
              },
              child: Card(
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Create group",
                      style: TextStyle(
                          color: Colors.black,
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Groups(currentUser: currentUser),
                    ),
                  )
              },
              child: Card(
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Groups",
                      style: TextStyle(
                          color: Colors.black,
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
              onTap: () => generateShortDeepLink(),
              child: Card(
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Refer & Earn",
                      style: TextStyle(
                          color: Colors.black,
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
              onTap: () => {},
              child: Card(
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Help & Support",
                      style: TextStyle(
                          color: Colors.black,
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
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Settings & Privacy",
                      style: TextStyle(
                          color: Colors.black,
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
                  margin: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: ListTile(
                    title: Text(
                      "Logout",
                      style: TextStyle(
                          color: Colors.black,
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
    Share.share(deepLink.toString());
// _showMyDialog(deepLink);
    print(deepLink);
  }
}
