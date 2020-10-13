import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/group.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/home.dart' as prefix0;
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

class Groups extends StatefulWidget {
  final Widget child;
  final User currentUser;
  Groups({Key key, this.child, this.currentUser}) : super(key: key);
  _GroupState createState() => _GroupState(currentUser: this.currentUser);
}

class _GroupState extends State<Groups> {
  final User currentUser;
  List<Group> groups=[];
  bool isLoading=true;
  _GroupState({this.currentUser});
  @override
  void initState() {
    super.initState();
  }
 buildGroups() {
    return StreamBuilder(
        stream: groupsRef
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<Group> group = [];
          snapshot.data.documents.forEach((doc) {
            group.add(Group.fromDocument(doc));
          });
          return ListView(
            children: group,
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: header(context,titleText: "groups"), 
    body:Column(
        children: <Widget>[
          Expanded(child: buildGroups())]), 
    );
  }
  
}
