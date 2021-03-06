import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userPostRef.document(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return linearProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        print(post.postId);
        return Center(
          child: Scaffold(
              appBar: header(context, titleText: post.description),
              body: Column(
                children: <Widget>[
                  cachedNetworkImage(post.mediaUrl),
                ],
              )),
        );
      },
    );
  }
}
