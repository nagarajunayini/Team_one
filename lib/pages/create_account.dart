import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/models/userInfo.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

import 'home.dart';
final usersRef = Firestore.instance.collection('users');

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
        TextEditingController referalCode = TextEditingController();


  final _formKey = GlobalKey<FormState>();
  String username;
  String email;
  String referalApplied="No";
  List<UserInfo> userDetails = [];
  List<dynamic> extraIfo = [];
  List<dynamic> _selectedInterests =[];

    List<User> userData = [];

  var gender = ["Male", "Female", "Others"];
  var religion = ["Hindu", "Muslim", "Christian", "Others"];
  var intersets = ["Politcs", "Sports", "Technology", "Wether","Environment","Mdicine","Journalism","Films","Arts"];
  var city = [
    "Hyderabad",
    "Bangolore",
    "Tamilnadu",
    "Mumbai",
    "Delhi",
    "Kerala",
    "Others"
  ];
  String selectedGender = "Male";
  String selectedReligion = "All";
  String selectedCity = "Hyderabad";
  String validateEmail(String value) {
    Pattern pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value == null)
      return 'Enter a valid email address';
    else
      return null;
  }
  submit() {
    if(displayNameController.text.trim().length < 3 ||  displayNameController.text.isEmpty){
_showMyDialog( "Warning",
          "Please Enter valid user name",
          "User name should contain minimum 3 characters");
    }else{
      if(validateEmail(emailController.text)!=null){
_showMyDialog( "Warning",
          "Please enter valid email",
          "");

      }else{
        this.extraIfo = [
      this.selectedCity,
      this.selectedGender,
      this.selectedReligion,
    ];
    UserInfo  userData = new UserInfo();
    userData.email=emailController.text;
    userData.interests=this._selectedInterests; 
    userData.userName=displayNameController.text;
    userData.extraInfo = this.extraIfo;
    this.userDetails.add(userData);
    // this.userDetails = [displayNameController.text, this.extraIfo];
    String name = displayNameController.text;
    SnackBar snackbar = SnackBar(content: Text("Welcome $name!"));
    _scaffoldKey.currentState.showSnackBar(snackbar);
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context, this.userDetails);
    });
      }
    }
    
  }
  apply(){
    setState(() {
         referalApplied="inProgress";
        });
  
    usersRef
        .where("id", isEqualTo: referalCode.text)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        userData.add(User.fromDocument(doc));
        usersRef.document(userData[0].id).setData({
      "id": userData[0].id,
      "username": userData[0].username,
      "photoUrl": userData[0].photoUrl,
      "email": userData[0].email,
      "displayName": userData[0].displayName,
      "bio": userData[0].bio,
      "timestamp": timestamp,
      "credits":userData[0].credits,
      "referralPoints":
          userData[0].referralPoints +50,
      "extraInfo":userData[0].extraInfo,
    });
    setState(() {
    referalApplied="completed";
        });
      });
    });
  

  }

   Future<void> _showMyDialog(status, message, message1) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
                Text(message1),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,
          titleText: "Set up your profile", removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 20.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    //do what you want here
                  },
                  child: CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.brown.shade800,
                    child: Text('Edit'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: displayNameController,
                    decoration: InputDecoration(labelText: "userName"),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextFormField(
                    validator: validateEmail,
                    controller: emailController,
                    decoration: InputDecoration(labelText: "email"),
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.all(16.0),
                //   child: Container(
                //     child: Form(
                //       key: _formKey,
                //       autovalidate: true,
                //       child: TextFormField(
                //         validator: (val) {
                //           if (val.trim().length < 3 || val.isEmpty) {
                //             return "Username too short";
                //           } else if (val.trim().length > 12) {
                //             return "Username too long";
                //           } else {
                //             return null;
                //           }
                //         },
                //         onSaved: (val) => username = val,
                //         decoration: InputDecoration(
                //           border: OutlineInputBorder(),
                //           labelText: "Username",
                //           labelStyle: TextStyle(fontSize: 15.0),
                //           hintText: "Must be at least 3 characters",
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 0.0, left: 0.0)),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10.0,
                      ),
                      child: Center(
                        child: Text(
                          "Gender:",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: 60.0, left: 150.0, right: 10.0)),
                    DropdownButton<String>(
                      items: gender.map((String dropdownItem) {
                        return DropdownMenuItem<String>(
                            value: dropdownItem, child: Text(dropdownItem));
                      }).toList(),
                      onChanged: (String selectedValue) {
                        setState(() {
                          this.selectedGender = selectedValue;
                        });
                      },
                      value: this.selectedGender,
                    ),
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: <Widget>[
                //     Padding(padding: EdgeInsets.only(top: 0.0, left: 0.0)),
                //     Padding(
                //       padding: EdgeInsets.only(
                //         top: 10.0,
                //       ),
                //       child: Center(
                //         child: Text(
                //           "Age:",
                //           style: TextStyle(fontSize: 20.0),
                //         ),
                //       ),
                //     ),
                //     Padding(
                //         padding: EdgeInsets.only(
                //             top: 60.0, left: 150.0, right: 10.0)),
                //     DropdownButton<String>(
                //       items: gender.map((String dropdownItem) {
                //         return DropdownMenuItem<String>(
                //             value: dropdownItem, child: Text(dropdownItem));
                //       }).toList(),
                //       onChanged: (String selectedValue) {
                //         setState(() {
                //           this.selectedGender = selectedValue;
                //         });
                //       },
                //       value: this.selectedGender,
                //     ),
                //   ],
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 0.0, left: 0.0)),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10.0,
                      ),
                      child: Center(
                        child: Text(
                          "City:",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: 60.0, left: 150.0, right: 10.0)),
                    DropdownButton<String>(
                      items: city.map((String dropdownItem) {
                        return DropdownMenuItem<String>(
                            value: dropdownItem, child: Text(dropdownItem));
                      }).toList(),
                      onChanged: (String selectedValue) {
                        setState(() {
                          this.selectedCity = selectedValue;
                        });
                      },
                      value: this.selectedCity,
                    ),
                  ],
                ),
                MultiSelectChipField(
                        showHeader: true,
                        title: Text('Interests'),
  items: intersets.map((e) => MultiSelectItem(e, e)).toList(),
  icon: Icon(Icons.check),
  headerColor:Colors.white,
  onTap: (values) {
    _selectedInterests = values;
  },
),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     Padding(
//                         padding:
//                             EdgeInsets.only(top: 0.0, left: 0.0, bottom: 20.0)),
//                     Padding(
//                       padding: EdgeInsets.only(
//                         top: 10.0,
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Interests:",
//                           style: TextStyle(fontSize: 20.0),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                         padding: EdgeInsets.only(
//                             top: 60.0, left: 150.0, right: 10.0)),
//                             MultiSelectDialogField(
//   items: religion.map((e) => MultiSelectItem(e, e)).toList(),
//   listType: MultiSelectListType.CHIP,
//   onConfirm: (values) {
//     _selectedInterest = values;
//   },
// ),
//                     // DropdownButton<String>(
//                     //   items: religion.map((String dropdownItem) {
//                     //     return DropdownMenuItem<String>(
//                     //         value: dropdownItem, child: Text(dropdownItem));
//                     //   }).toList(),
//                     //   onChanged: (String selectedValue) {
//                     //     setState(() {
//                     //       this.selectedReligion = selectedValue;
//                     //     });
//                     //   },
//                     //   value: this.selectedReligion,
//                     // ),
//                   ],
//                 ),
                
               
                Row(
  children: <Widget>[
    Flexible(child:
     Padding(
                  padding: EdgeInsets.only(left:16.0,right:30.0,top:16.0,bottom:16.0),
                 child:  TextField(
  controller: referalCode,
  decoration: InputDecoration(
    hintText: "Enter Referal code(if any)",
  ),
),
                ),),
  referalApplied=='No'? GestureDetector(
                  onTap: apply,
                  child: Container(
                    height: 50.0,
                    width: 80.0,
                    child: Center(
                      child: Text(
                        "Apply",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ): referalApplied=='inProgress'?GestureDetector(
                  onTap: apply,
                  child: Container(
                    height: 50.0,
                    width: 80.0,
                    child: Center(
                      child: Text(
                        "Wait",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ):GestureDetector(
                  onTap: apply,
                  child: Container(
                    height: 50.0,
                    width: 80.0,
                    child: Center(
                      child: Text(
                        "Applied",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
  ],
),

                  
                


                    
                
                   
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
