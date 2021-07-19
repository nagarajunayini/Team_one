import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
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

class Wallet_Transactions extends StatefulWidget {
  final String profileId;

  Wallet_Transactions({this.profileId});

  @override
  _Wallet_TransactionsState createState() => _Wallet_TransactionsState();
}

class _Wallet_TransactionsState extends State<Wallet_Transactions> {
  final String currentUserId = currentUser?.id;
  String postOrientation = "list";
  bool isFollowing = false;
  bool isLoading = false;
  bool inprogressOrExpired= true;
  int postCount = 0;
  Uri deepLink;
  int followerCount = 0;
  int followingCount = 0;
  List<Wallet> wallet = [];
  List<Post> filterposts = [];


  @override
  void initState() {
    super.initState();
    getWalletCreditInfo();
  }

  getWalletCreditInfo() async {
    setState(() {
      isLoading = true;
      inprogressOrExpired=true;
    });
    QuerySnapshot snapshot = await walletTransactionsRef
        .where("transactionType", isEqualTo: "Credit")
        .where("userId", isEqualTo:widget.profileId )
        .getDocuments();
    setState(() {
      isLoading = false;
     
      wallet.clear();
      wallet = snapshot.documents.map((doc) => Wallet.fromDocument(doc)).toList();
      print(wallet);
    });
  }
  getWalletDebit() async{ 
    setState(() {
      isLoading = true;
      inprogressOrExpired=false;
    });
    QuerySnapshot snapshot = await walletTransactionsRef
         .where("transactionType", isEqualTo: "Debit")
        .where("userId", isEqualTo:widget.profileId )
        .getDocuments();
    setState(() {
      isLoading = false;
      wallet.clear();
      wallet = snapshot.documents.map((doc) => Wallet.fromDocument(doc)).toList();
      print(wallet);
    });
  }

 


  

 

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }
  buildWalletTable(){
    if(isLoading){
    return 

        Center(
          child:CircularProgressIndicator(
              value: 100,
              semanticsLabel: 'Linear progress indicator',
            ),
        );
        
      
   
    }else{
      if(wallet.isEmpty){
        return Center(
          child:Text("No Data Available.")
        );
         
      }else{
      return 
    DataTable(columns: [DataColumn(label: Text("S.No")),
    DataColumn(label: Text("Type")),
    // DataColumn(label: Text("Reason")),
    DataColumn(label: Text("Amount"))],
     rows: wallet.map<DataRow>((e) => DataRow(cells: [
       DataCell(Text("1")),
        DataCell(Text(e.transactionType.toString())),
        //  DataCell(Text(e.reason.toString())),
          DataCell(Text(e.amount.toString()))
       ])).toList()
       );
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
                      color:  inprogressOrExpired?Colors.red:Colors.grey,
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
                      color:  inprogressOrExpired?Colors.grey:Colors.red,
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
    return Scaffold(
        appBar: AppBar(
        // backgroundColor: Colors.white70,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
           ),
        title: Text(
          "Wallet",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          FlatButton(
            child: Text(
              "100",
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
          Padding(padding: EdgeInsets.only(top:3.0)),
          buildTogglePostOrientation(),
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
