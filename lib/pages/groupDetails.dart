import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/group.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';

class GroupDetails extends StatefulWidget {
  final String groupId;
  final Widget child;

  GroupDetails({Key key, this.child, this.groupId}) : super(key: key);
  _GroupDetailsState createState() => _GroupDetailsState(groupId: this.groupId);
}

class _GroupDetailsState extends State<GroupDetails> {
  final String groupId;
  _GroupDetailsState({this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Group Deatils"),
      body: Column(
        children: <Widget>[
          buildProfileHeader(),
          Center(
            child: Container(
              child: Text("No Posts",
              style: TextStyle(fontSize: 25.0),
              ),
              )
              ,)
      ],
      ),
    );
  }

  buildProfileHeader() {
    return FutureBuilder(
        future: groupsRef.document(widget.groupId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              height: 270.0,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.redAccent, Colors.pinkAccent])),
            );
          }
          return Column(
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.redAccent, Colors.pinkAccent])),
                  child: Container(
                    width: double.infinity,
                    height: 270.0,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            // backgroundImage: NetworkImage(
                            //   // currentUser.photoUrl,
                            // ),
                            radius: 50.0,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "STAND IV",
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: buildButton(
                                  text: "Like",
                                ),
                              ),
                              Expanded(
                                child: buildButton(
                                  text: "Follow",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        });
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 250.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color:Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }
}
