import 'package:cloud_firestore/cloud_firestore.dart';

class PoolAmount {
  final String postId;
  final int postAmount;

  PoolAmount({
    this.postId,
    this.postAmount,
  });

  factory PoolAmount.fromDocument(DocumentSnapshot doc) {
    return PoolAmount(postId: doc['postId'], postAmount: doc['postAmount']);
  }
}
