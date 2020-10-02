import 'package:cloud_firestore/cloud_firestore.dart';

class Categories {
   List<dynamic> categories;

  Categories({
    this.categories,
  
  });

  factory Categories.fromDocument(DocumentSnapshot doc) {
    return Categories(
      categories: doc['categories']
    );
  }
}