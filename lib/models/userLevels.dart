import 'package:cloud_firestore/cloud_firestore.dart';

class PostValues {
  final int index;
  final int postValue;
  final int postDeductionValue;

  PostValues({
    this.index,
    this.postValue,
    this.postDeductionValue,
  });

  factory PostValues.fromDocument(DocumentSnapshot doc) {
    return PostValues(
      index: doc['index'],
      postValue: doc['postValue'],
      postDeductionValue: doc['postDeductionValue'],
    );
  }
}
