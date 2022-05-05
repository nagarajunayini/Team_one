import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
   String email;
   String userName;
   String firstName;
   String lastName;
   String dateOfBirth;
   String pincode;
   List<dynamic> extraInfo;
   List<dynamic> interests;
   String geekName;
  String get email_id {
    return email;
  }
  String get first_name {
    return firstName;
  }
  set first_name (String name) {
    this.firstName = name;
  }

   String get last_name {
    return lastName;
  }
  set last_name (String name) {
    this.lastName = name;
  }
   String get dateOf_Birth {
    return dateOfBirth;
  }
  set dateOf_Birth (String name) {
    this.dateOfBirth = name;
  }
   String get pinCode {
    return pincode;
  }
  set pinCode (String name) {
    this.pincode = name;
  }
  set email_id (String name) {
    this.email = name;
  }
  String get user_Name {
    return userName;
  }
  set user_Name (String name) {
    this.userName = name;
  }
  List<dynamic> get extra_Info {
    return extraInfo;
  }
  set extra_Info (List<dynamic> list) {
    this.extraInfo = list;
  }

  List<dynamic> get _interests {
    return interests;
  }

  set _interests (List<dynamic> list) {
    this.interests = list;
  }

  
}
