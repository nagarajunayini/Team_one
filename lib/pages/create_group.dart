import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart' as prefix0;
import 'package:fluttershare/widgets/header.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'home.dart';

class CreateGroup extends StatefulWidget {
  final Widget child;
  final User currentUser;
  CreateGroup({Key key, this.child, this.currentUser}) : super(key: key);
  _CreateGroupState createState() =>
      _CreateGroupState(currentUser: this.currentUser);
}

class _CreateGroupState extends State<CreateGroup> {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController groupNameController = TextEditingController();
  final User currentUser;
  String selectedType = "Public";
  _CreateGroupState({this.currentUser});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Create Group"),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextFormField(
              controller: groupNameController,
              decoration: InputDecoration(labelText: "group name"),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 10.0, left:12.0 
                ),
                child: Center(
                  child: Text(
                    "Group Type:",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              ),
              // Padding(
              //     padding:
              //         EdgeInsets.only(top: 60.0, left: 150.0, right: 50.0)),
              Container(
                padding: EdgeInsets.only(right:12.0,top:8.0),
                child:DropdownButton<String>(
                items: ["Public", "Private"].map((String dropdownItem) {
                  return DropdownMenuItem<String>(
                      value: dropdownItem, child: Text(dropdownItem));
                }).toList(),
                onChanged: (String selectedValue) {
                  setState(() {
                    this.selectedType = selectedValue;
                  });
                },
                value: this.selectedType,
              ) ,)
              
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: GestureDetector(
                onTap: ()=>create(),
                child: Container(
                  height: 50.0,
                  width: 350.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Center(
                    child: Text(
                      "Create",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
 create() {
    String id =Uuid().v4();
    groupsRef.document(id).setData({
        "groupId":id,
        "groupName": groupNameController.text,
        "createdBy": currentUser.id,
        "groupMembers": [currentUser.id],
        "timestamp": timestamp,
        "groupSize": 250,
        "groupType": this.selectedType
      });
 Navigator.pop(context);
    //  SnackBar snackbar = SnackBar(content: Text("Group Created Succesfully."));
    // _scaffoldKey.currentState.showSnackBar(snackbar);
    
  }
  
}
