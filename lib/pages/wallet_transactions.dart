import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/models/userLevels.dart';
import 'package:fluttershare/models/wallet.dart';
import 'package:fluttershare/pages/edit_profile.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/sidebar.dart';
import 'package:fluttershare/widgets/header.dart';
// import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share/share.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Wallet_Transactions extends StatefulWidget {
  final String profileId;
  final List<PostValues> postValues;

  Wallet_Transactions({this.profileId, this.postValues});

  @override
  _Wallet_TransactionsState createState() =>
      _Wallet_TransactionsState(postValues: this.postValues);
}

class _Wallet_TransactionsState extends State<Wallet_Transactions> {
  final String currentUserId = currentUser?.id;
  String postOrientation = "list";
  bool isFollowing = false;
  bool isLoading = false;
  bool inprogressOrExpired = true;
  int postCount = 0;
  Uri deepLink;
  int followerCount = 0;
  int followingCount = 0;
  List<Wallet> wallet = [];
  List<Post> filterposts = [];
  final List<PostValues> postValues;

  _Wallet_TransactionsState({this.postValues});
  @override
  void initState() {
    super.initState();
    getWalletCreditInfo();
  }

  getWalletCreditInfo() async {
    setState(() {
      isLoading = true;
      inprogressOrExpired = true;
    });
    QuerySnapshot snapshot = await walletTransactionRef
        // .where("transactionType", isEqualTo: "Credit")
        .where("userId", isEqualTo: widget.profileId)
        .getDocuments();
    setState(() {
      isLoading = false;

      wallet.clear();
      wallet =
          snapshot.documents.map((doc) => Wallet.fromDocument(doc)).toList();
      print(wallet);
    });
  }

  getWalletDebit() async {
    setState(() {
      isLoading = true;
      inprogressOrExpired = false;
    });
    QuerySnapshot snapshot = await walletTransactionRef
        .where("transactionType", isEqualTo: "Debit")
        .where("userId", isEqualTo: widget.profileId)
        .getDocuments();
    setState(() {
      isLoading = false;
      // wallet.clear();
      wallet =
          snapshot.documents.map((doc) => Wallet.fromDocument(doc)).toList();
      print(wallet);
    });
  }

  back() {
    Navigator.pop(context);
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  buildWalletTable() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          value: 100,
          semanticsLabel: 'Linear progress indicator',
        ),
      );
    } else {
      if (wallet.isEmpty) {
        return Center(
            child: Text("No Data Available.",
                style: TextStyle(color: Colors.white)));
      } else {
        return DataTable(
            columns: [
              // DataColumn(
              //     label: Text(
              //   "S.No",
              //   style: TextStyle(color: Colors.white),
              // )),
              DataColumn(
                  label: Text("Type", style: TextStyle(color: Colors.white))),
              // DataColumn(label: Text("Reason")),
              DataColumn(
                  label: Text("Amount", style: TextStyle(color: Colors.white)))
            ],
            rows: wallet
                .map<DataRow>((e) => DataRow(cells: [
                      // DataCell(
                      //     Text(, style: TextStyle(color: Colors.white))),
                      DataCell(
                        Text(e.transactionType.toString(),
                            style: TextStyle(color: Colors.white)),
                      ),
                      //  DataCell(Text(e.reason.toString())),
                      DataCell(Text(e.amount.toString(),
                          style: TextStyle(color: Colors.white)))
                    ]))
                .toList());
      }
    }
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GestureDetector(
          onTap: getWalletCreditInfo,
          child: Container(
            height: 50.0,
            width: 180.0,
            decoration: BoxDecoration(
              color: inprogressOrExpired ? Colors.red : Colors.grey,
              // borderRadius: BorderRadius.circular(7.0),
            ),
            child: Center(
              child: Text(
                "Credit",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: getWalletDebit,
          child: Container(
            height: 50.0,
            width: 180.0,
            decoration: BoxDecoration(
              color: inprogressOrExpired ? Colors.grey : Colors.red,
              // borderRadius: BorderRadius.circular(7.0),
            ),
            child: Center(
              child: Text(
                "Debit",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var value = currentUser?.referralPoints >= postValues[5].postValue
        ? 100
        : currentUser?.referralPoints >= postValues[0].postValue
            ? 80
            : currentUser?.referralPoints >= postValues[3].postValue
                ? 60
                : currentUser?.referralPoints >= postValues[2].postValue
                    ? 40
                    : currentUser?.referralPoints >= postValues[1].postValue
                        ? 20
                        : 0;
    var userLevel = currentUser?.referralPoints >= postValues[5].postValue
        ? "Diamond"
        : currentUser?.referralPoints >= postValues[0].postValue
            ? "Platinum"
            : currentUser?.referralPoints >= postValues[3].postValue
                ? "Gold"
                : currentUser?.referralPoints >= postValues[2].postValue
                    ? "Silver"
                    : currentUser?.referralPoints >= postValues[1].postValue
                        ? "Bronze"
                        : "zero level";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: back),
        title: Text(
          "Wallet",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          FlatButton(
            child: Text(
              currentUser.referralPoints.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 8.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 10.0,
                animation: true,
                percent: currentUser?.referralPoints >= postValues[5].postValue
                    ? 100 / 100
                    : currentUser?.referralPoints >= postValues[0].postValue
                        ? 80 / 100
                        : currentUser?.referralPoints >= postValues[3].postValue
                            ? 60 / 100
                            : currentUser?.referralPoints >=
                                    postValues[2].postValue
                                ? 40 / 100
                                : currentUser?.referralPoints >=
                                        postValues[1].postValue
                                    ? 20 / 100
                                    : 0 / 100,
                center: Text(
                  value.toString() + "%",
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                backgroundColor: Colors.grey[300],
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: currentUser?.referralPoints >=
                        postValues[5].postValue
                    ? Colors.blue
                    : currentUser?.referralPoints >= postValues[4].postValue
                        ? Colors.deepPurple
                        : currentUser?.referralPoints >= postValues[3].postValue
                            ? Colors.yellow
                            : currentUser?.referralPoints >=
                                    postValues[2].postValue
                                ? Colors.orange
                                : currentUser?.referralPoints >=
                                        postValues[1].postValue
                                    ? Colors.brown
                                    : Colors.grey,
              ),
              Column(children: <Widget>[
                Text(
                  currentUser.referralPoints.toString() + " points",
                  style: TextStyle(fontSize: 26.0, color: Colors.white),
                ),
                Padding(padding: EdgeInsets.all(3.0)),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentUser?.referralPoints >=
                                postValues[5].postValue
                            ? Colors.blue
                            : currentUser?.referralPoints >=
                                    postValues[4].postValue
                                ? Colors.deepPurple
                                : currentUser?.referralPoints >=
                                        postValues[3].postValue
                                    ? Colors.yellow
                                    : currentUser?.referralPoints >=
                                            postValues[2].postValue
                                        ? Colors.orange
                                        : currentUser?.referralPoints >=
                                                postValues[1].postValue
                                            ? Colors.brown
                                            : Colors.grey,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(3.0)),
                    Text(
                      userLevel,
                      style: TextStyle(
                          color: currentUser?.referralPoints >=
                                  postValues[5].postValue
                              ? Colors.blue
                              : currentUser?.referralPoints >=
                                      postValues[4].postValue
                                  ? Colors.deepPurple
                                  : currentUser?.referralPoints >=
                                          postValues[3].postValue
                                      ? Colors.yellow
                                      : currentUser?.referralPoints >=
                                              postValues[2].postValue
                                          ? Colors.orange
                                          : currentUser?.referralPoints >=
                                                  postValues[1].postValue
                                              ? Colors.brown
                                              : Colors.grey),
                    )
                  ],
                )
              ])
            ],
          ),
          Padding(padding: EdgeInsets.all(10.0)),
          Text(
            "* Refer your friend and earn coins",
            style: TextStyle(color: Colors.white, fontSize: 12.0),
            textAlign: TextAlign.left,
          ),
          Text("* Posts that you won could earn more coins",
              style: TextStyle(color: Colors.white, fontSize: 12.0)),
          Text("* Posts that you voted could earn more coins",
              style: TextStyle(color: Colors.white, fontSize: 12.0)),
          Text("* Posts that you voted could earn more coins",
              style: TextStyle(color: Colors.white, fontSize: 12.0)),
          Padding(padding: EdgeInsets.all(10.0)),
          // buildTogglePostOrientation(),
          Expanded(
            child: ListView(
              children: <Widget>[
                buildWalletTable(),
                Divider(
                  height: 2.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
