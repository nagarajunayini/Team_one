import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
   String email;
   String userName;
   List<dynamic> extraInfo;

  // UserInfo(this.email, this.userName, this.extraInfo);
   String geekName;
    
  // Using the getter
  // method to take input
  String get email_id {
    return email;
  }
    
  // Using the setter method
  // to set the input
  set email_id (String name) {
    this.email = name;
  }
  String get user_Name {
    return userName;
  }
    
  // Using the setter method
  // to set the input
  set user_Name (String name) {
    this.userName = name;
  }
  List<dynamic> get extra_Info {
    return extraInfo;
  }
    
  // Using the setter method
  // to set the input
  set extra_Info (List<dynamic> list) {
    this.extraInfo = list;
  }

  
}
