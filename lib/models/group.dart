import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/groupDetails.dart';

class Group extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String createdBy;
  final List<dynamic> groupMembers;
  final Timestamp timestamp;
  final int groupSize;
  final String groupType;

  Group(
      {this.groupId,
      this.groupName,
      this.createdBy,
      this.groupMembers,
      this.timestamp,
      this.groupSize,
      this.groupType});

  factory Group.fromDocument(DocumentSnapshot doc) {
    return Group(
        groupId: doc['groupId'],
        groupName: doc['groupName'],
        createdBy: doc['createdBy'],
        groupMembers: doc['groupMembers'],
        timestamp: doc['timestamp'],
        groupSize: doc['groupSize'],
        groupType: doc['groupType']);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          onTap: ()=>{
            Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupDetails(groupId: groupId),
                    ),
                  )
          },
          title: Text(groupName),
          // leading: CircleAvatar(
          //   backgroundImage: CachedNetworkImageProvider(avatarUrl),
          // ),
          subtitle: Text(groupMembers.length.toString() + " Members"),
        ),
        Divider(),
      ],
    );
  }
}
