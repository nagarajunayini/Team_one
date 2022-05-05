import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/models/userInfo.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:intl/intl.dart';
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
  TextEditingController _dateController = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController nickName = TextEditingController();
    TextEditingController pinCode = TextEditingController();


  TextEditingController countryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String username;
  String email;
  String pageNumber = "1";
  String referalApplied = "No";
  List<UserInfo> userDetails = [];
  List<dynamic> extraIfo = [];
  List<dynamic> _selectedInterests = [];
  List<User> userData = [];

  var gender = ["Male", "Female", "Others"];
  var knowledge = [
    "Math",
    "Covid-19",
    "Science",
    "Biology",
    "History",
    "Physics"
  ];
  var hustle = [
    "TokTok",
    "Clubhouse",
    "Stocks",
    "Instagram",
    "Entrepreneurship"
  ];
  var worldAffairs = [
    "Current Events",
    "Climate",
    "Us Politics",
    "Geo Politcs"
  ];
  var sports = ["Soccer", "Tennis", "Cricket", "Basketball", "Cycling"];
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
  // String selectedReligion = "All";
  // String selectedCity = "Hyderabad";
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
    this.extraIfo = [
      this.selectedGender,
      countryController.text,
    ];
    UserInfo userData = new UserInfo();
    userData.email = emailController.text;
    userData.firstName = firstName.text;
    userData.lastName = lastName.text;
    userData.dateOfBirth = _dateController.text;
    userData.interests = this._selectedInterests;
    userData.userName = nickName.text;
    userData.extraInfo = this.extraIfo;
    userData.pincode = pinCode.text;
    this.userDetails.add(userData);
    String name = nickName.text;
    SnackBar snackbar = SnackBar(content: Text("Welcome $name!"));
    _scaffoldKey.currentState.showSnackBar(snackbar);
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context, this.userDetails);
    });
  }
  // submit() {
  //   if (displayNameController.text.trim().length < 3 ||
  //       displayNameController.text.isEmpty) {
  //     _showMyDialog("Warning", "Please Enter valid user name",
  //         "User name should contain minimum 3 characters");
  //   } else {
  //     if (validateEmail(emailController.text) != null) {
  //       _showMyDialog("Warning", "Please enter valid email", "");
  //     } else {
  //       this.extraIfo = [
  //         this.selectedGender,
  //         countryController.text,
  //       ];
  //       UserInfo userData = new UserInfo();
  //       userData.email = emailController.text;
  //       userData.firstName = firstName.text;
  //       userData.lastName = lastName.text;
  //       userData.dataOfBirth = _dateController.text;
  //       userData.interests = this._selectedInterests;
  //       userData.userName = nickName.text;
  //       userData.extraInfo = this.extraIfo;
  //       this.userDetails.add(userData);
  //       String name = nickName.text;
  //       SnackBar snackbar = SnackBar(content: Text("Welcome $name!"));
  //       _scaffoldKey.currentState.showSnackBar(snackbar);
  //       Timer(Duration(seconds: 2), () {
  //         Navigator.pop(context, this.userDetails);
  //       });
  //     }
  //   }
  // }

  next(number) {
    if (number == "2") {
      if (firstName.text.isEmpty || lastName.text.isEmpty) {
        _showMyDialog("Warning", "Please Enter valid Name",
            "User name should contain minimum 3 characters");
      } else {
        setState(() {
          pageNumber = number;
        });
      }
    }

    if (number == "3") {
      if (nickName.text.isEmpty) {
        _showMyDialog("Warning", "Please Enter valid calling name",
            "name should contain minimum 3 characters");
      } else {
        setState(() {
          pageNumber = number;
        });
      }
    }
    if (number == "4") {
      setState(() {
        pageNumber = number;
      });
    }
    if (number == "5") {
      if (validateEmail(emailController.text) != null) {
        _showMyDialog("Warning", "Please enter valid email", "");
      } else {
        setState(() {
          pageNumber = number;
        });
      }
    }
    if(number == "6"){
      if (countryController.text.isEmpty) {
        _showMyDialog("Warning", "Please select your country", "");
      } else {
        setState(() {
          pageNumber = number;
        });
      }
    }
    if (number == "7") {
      if (pinCode.text.isEmpty) {
        _showMyDialog("Warning", "Please enter Pincode", "");
      } else {
        setState(() {
          pageNumber = number;
        });
      }
    }
    if (number == "8") {
      if (_dateController.text.isEmpty) {
        _showMyDialog("Warning", "Please select your DOB", "");
      } else {
        setState(() {
          pageNumber = number;
        });
      }
    }
    if (number == "9") {
      if (this._selectedInterests.length == 0) {
        _showMyDialog("Warning", "Please select at least one choise", "");
      } else {
        setState(() {
          pageNumber = number;
        });
      }
    }
  }
  skip(number){
    setState(() {
          pageNumber = number;
        });
  }

  backTologing(number) {
    // setState(() {
    //   pageNumber = number;
    // });
  }

  back(number) {
    setState(() {
      pageNumber = number;
    });
  }

  apply() {
    setState(() {
      referalApplied = "inProgress";
    });

    usersRef
        .where("id", isEqualTo: referalCode.text)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((DocumentSnapshot doc) {
        userData.add(User.fromDocument(doc));
        usersRef.document(userData[0].id).setData({
           "id": userData[0].id,
        "firstName": userData[0].firstName,
        "lastName":  userData[0].lastName,
        "dateOfBirth":  userData[0].dataOfBirth,
        "username":  userData[0].username,
        "photoUrl":   userData[0].photoUrl,
        "email":  userData[0].email,
        "displayName":  userData[0].displayName,
        "bio":  userData[0].bio,
        "phoneNumber": userData[0].phoneNumber,
        "timestamp": timestamp,
        "credits": userData[0].credits, 
        "referralPoints": userData[0].referralPoints + 50,
        "extraInfo":  userData[0].extraInfo,
        "interests":  userData[0].interests
        });
        setState(() {
          referalApplied = "completed";
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
      backgroundColor: Color(0xFF000000),
      key: _scaffoldKey,
      // appBar: header(context,
      //     titleText: "Set up your profile", removeBackButton: true),
      body: ListView(
        children: <Widget>[
          pageNumber == "1"
              ? Container(
                  padding: EdgeInsets.only(top: 40.0),
                  child: Column(children: <Widget>[
                    GestureDetector(
                        // onTap: () => backTologing("2"),
                        child: Container(
                            padding: EdgeInsets.only(left: 20.0),
                            width: 377.0,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                              
                                Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                  children: [
                                     GestureDetector(
                        onTap: () => backTologing("2"),
                                    child:Row(children: [
Icon(
                                  Icons.arrow_back_ios,
                                  color: Color(0xFFB3B3B3),
                                ),
                                Text(
                                  "Back",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                    ],),
                                ),

                                 GestureDetector(
                        onTap: () => skip("2"),

                                   child: Text(
                                  "Skip",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),), 
                                  ],

                                ),
                                
                              ],
                            ))),
                    Container(
                      padding: EdgeInsets.only(top: 30.0, left: 20.0),
                      width: 370.0,
                      child: Text(
                        "What is Your official name?",
                        style:
                            TextStyle(color: Color(0xFFFFFFFF), fontSize: 25.0),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 100.0, left: 20.0),
                        width: 350.0,
                        child: TextFormField(
                          controller: firstName,
                          style: TextStyle(
                              color: Color(0xB3FFFFFF), fontSize: 18.0),
                          decoration: const InputDecoration(
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 0.0),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 0.0),
                            ),
                            labelText: 'First Name',
                            labelStyle: TextStyle(
                                color: Color(0xB3FFFFFF), fontSize: 18.0),
                          ),
                        )),
                    Container(
                        padding: EdgeInsets.only(left: 20.0, top: 20.0),
                        width: 350.0,
                        child: TextFormField(
                          controller: lastName,
                          style: TextStyle(
                              color: Color(0xB3FFFFFF), fontSize: 18.0),
                          decoration: const InputDecoration(
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 0.0),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 0.0),
                            ),
                            labelText: 'Last Name',
                            labelStyle: TextStyle(
                                color: Color(0xB3FFFFFF), fontSize: 18.0),
                          ),
                        )),
                    Padding(padding: EdgeInsets.all(40)),
                    GestureDetector(
                      onTap: () => next("2"),
                      child: Container(
                        height: 45.0,
                        width: 112.67,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23.0),
                            border: Border.all(
                                color: Color(0xFFB3B3B3), width: 3.0)),
                        child: Center(
                          child: Text(
                            "Next",
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ]))
              : pageNumber == '2'
                  ? Container(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Column(children: <Widget>[
                        GestureDetector(
                            onTap: () => back("1"),
                            child: Container(
                                padding: EdgeInsets.only(left: 20.0),
                                width: 377.0,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios,
                                      color: Color(0xFFB3B3B3),
                                    ),
                                    Text(
                                      "back",
                                      style: TextStyle(
                                          color: Color(0xFFB3B3B3),
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ))),
                        Container(
                          padding: EdgeInsets.only(top: 30.0, left: 20.0),
                          width: 370.0,
                          child: Text(
                            "How would you like people to call you?",
                            style: TextStyle(
                                color: Color(0xFFFFFFFF), fontSize: 25.0),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(top: 100.0, left: 20.0),
                            width: 350.0,
                            child: TextFormField(
                              controller: nickName,
                              style: TextStyle(
                                  color: Color(0xB3FFFFFF), fontSize: 18.0),
                              decoration: const InputDecoration(
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                labelText: 'Nick Name',
                                labelStyle: TextStyle(
                                    color: Color(0xB3FFFFFF), fontSize: 18.0),
                              ),
                            )),
                        Padding(padding: EdgeInsets.all(40)),
                        GestureDetector(
                          onTap: () => next("3"),
                          child: Container(
                            height: 45.0,
                            width: 112.67,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(23.0),
                                border: Border.all(
                                    color: Color(0xFFB3B3B3), width: 3.0)),
                            child: Center(
                              child: Text(
                                "Next",
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ]))
                  : pageNumber == '3'
                      ? Container(
                          padding: EdgeInsets.only(top: 40.0),
                          child: Column(children: <Widget>[
                            Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                  children: [
                                     GestureDetector(
                        onTap: () => back("2"),
                                    child:Row(children: [
Icon(
                                  Icons.arrow_back_ios,
                                  color: Color(0xFFB3B3B3),
                                ),
                                Text(
                                  "Back",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                    ],),
                                ),

                                 GestureDetector(
                        onTap: () => skip("4"),

                                   child: Text(
                                  "Skip",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),), 
                                  ],

                                ),
                            Container(
                              padding: EdgeInsets.only(
                                  top: 30.0, left: 20.0, bottom: 30.0),
                              width: 370.0,
                              child: Text(
                                "What is your gender?",
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF), fontSize: 25.0),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Wrap(
                              children: gender
                                  .map((item) => Container(
                                      padding: EdgeInsets.only(right: 10.0),
                                      child: FlatButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              side: BorderSide(
                                                  color: selectedGender == item
                                                      ? Colors.red
                                                      : Colors.white)),
                                          color: selectedGender == item
                                              ? Colors.red
                                              : Colors.black,
                                          textColor: selectedGender == item
                                              ? Colors.white
                                              : Colors.white,
                                          onPressed: () => {
                                                setState(() {
                                                  selectedGender = item;
                                                })
                                              },
                                          child: Text(item,
                                              style: TextStyle(
                                                fontSize: 9.0,
                                              )))))
                                  .toList()
                                  .cast<Widget>(),
                            ),
                            Padding(padding: EdgeInsets.all(40)),
                            GestureDetector(
                              onTap: () => next("4"),
                              child: Container(
                                height: 45.0,
                                width: 112.67,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(23.0),
                                    border: Border.all(
                                        color: Color(0xFFB3B3B3), width: 3.0)),
                                child: Center(
                                  child: Text(
                                    "Next",
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ]))
                      : pageNumber == '4'
                          ? Container(
                              padding: EdgeInsets.only(top: 40.0),
                              child: Column(children: <Widget>[
                                GestureDetector(
                                    onTap: () => back("3"),
                                    child: Container(
                                        padding: EdgeInsets.only(left: 20.0),
                                        width: 377.0,
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_back_ios,
                                              color: Color(0xFFB3B3B3),
                                            ),
                                            Text(
                                              "back",
                                              style: TextStyle(
                                                  color: Color(0xFFB3B3B3),
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ))),
                                Container(
                                  padding:
                                      EdgeInsets.only(top: 30.0, left: 20.0),
                                  width: 370.0,
                                  child: Text(
                                    "Where can we write to you?",
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 25.0),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Container(
                                    padding:
                                        EdgeInsets.only(top: 80.0, left: 20.0),
                                    width: 350.0,
                                    child: TextFormField(
                                      controller: emailController,
                                      style: TextStyle(
                                          color: Color(0xB3FFFFFF),
                                          fontSize: 18.0),
                                      decoration: const InputDecoration(
                                        enabledBorder:
                                            const UnderlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 0.0),
                                        ),
                                        focusedBorder:
                                            const UnderlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 0.0),
                                        ),
                                        labelText: 'Email',
                                        labelStyle: TextStyle(
                                            color: Color(0xB3FFFFFF),
                                            fontSize: 18.0),
                                      ),
                                    )),
                                Padding(padding: EdgeInsets.all(40)),
                                GestureDetector(
                                  onTap: () => next("5"),
                                  child: Container(
                                    height: 45.0,
                                    width: 112.67,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(23.0),
                                        border: Border.all(
                                            color: Color(0xFFB3B3B3),
                                            width: 3.0)),
                                    child: Center(
                                      child: Text(
                                        "Next",
                                        style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ]))
                          : pageNumber == '5'
                              ? Container(
                                  padding: EdgeInsets.only(top: 40.0),
                                  child: Column(children: <Widget>[
                                   Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                  children: [
                                     GestureDetector(
                        onTap: () => back("4"),
                                    child:Row(children: [
Icon(
                                  Icons.arrow_back_ios,
                                  color: Color(0xFFB3B3B3),
                                ),
                                Text(
                                  "Back",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                    ],),
                                ),

                                 GestureDetector(
                        onTap: () => skip("6"),

                                   child: Text(
                                  "Skip",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),), 
                                  ],

                                ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: 30.0, left: 20.0),
                                      width: 370.0,
                                      child: Text(
                                        "Where do u live?",
                                        style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 25.0),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(
                                            top: 50.0, left: 20.0),
                                        width: 350.0,
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: countryController,
                                          style: TextStyle(
                                              color: Color(0xB3FFFFFF),
                                              fontSize: 18.0),
                                          decoration: const InputDecoration(
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 0.0),
                                            ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 0.0),
                                            ),
                                            labelText: 'Select Country',
                                            labelStyle: TextStyle(
                                                color: Color(0xB3FFFFFF),
                                                fontSize: 18.0),
                                          ),
                                          onTap: () async {
                                            showCountryPicker(
                                              context: context,
                                              showPhoneCode:
                                                  false, // optional. Shows phone code before the country name.
                                              onSelect: (Country country) {
                                                setState(() {
                                                  countryController.text =
                                                      country.displayName;
                                                });
                                              },
                                            );
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter date.';
                                            }
                                            return null;
                                          },
                                        )),
                                    Padding(padding: EdgeInsets.all(40)),
                                    GestureDetector(
                                      onTap: () => next("6"),
                                      child: Container(
                                        height: 45.0,
                                        width: 112.67,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(23.0),
                                            border: Border.all(
                                                color: Color(0xFFB3B3B3),
                                                width: 3.0)),
                                        child: Center(
                                          child: Text(
                                            "Next",
                                            style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]))
                                  : pageNumber == '6'
                              ? Container(
                                  padding: EdgeInsets.only(top: 40.0),
                                  child: Column(children: <Widget>[
                                    GestureDetector(
                                        onTap: () => back("5"),
                                        child: Container(
                                            padding:
                                                EdgeInsets.only(left: 20.0),
                                            width: 377.0,
                                            child: Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.arrow_back_ios,
                                                  color: Color(0xFFB3B3B3),
                                                ),
                                                Text(
                                                  "back",
                                                  style: TextStyle(
                                                      color: Color(0xFFB3B3B3),
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ))),
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: 30.0, left: 20.0),
                                      width: 370.0,
                                      child: Text(
                                        "Where do u live( Area Pincode )",
                                        style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 25.0),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(
                                            top: 50.0, left: 20.0),
                                        width: 350.0,
                                        child: TextFormField(
                              controller: pinCode,
                              style: TextStyle(
                                  color: Color(0xB3FFFFFF), fontSize: 18.0),
                              decoration: const InputDecoration(
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                labelText: 'Pincode',
                                labelStyle: TextStyle(
                                    color: Color(0xB3FFFFFF), fontSize: 18.0),
                              ),
                            )),
                                    Padding(padding: EdgeInsets.all(40)),
                                    GestureDetector(
                                      onTap: () => next("7"),
                                      child: Container(
                                        height: 45.0,
                                        width: 112.67,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(23.0),
                                            border: Border.all(
                                                color: Color(0xFFB3B3B3),
                                                width: 3.0)),
                                        child: Center(
                                          child: Text(
                                            "Next",
                                            style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]))
                              : pageNumber == '7'
                                  ? Container(
                                      padding: EdgeInsets.only(top: 40.0),
                                      child: Column(children: <Widget>[
                                        Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                  children: [
                                     GestureDetector(
                        onTap: () => back("6"),
                                    child:Row(children: [
Icon(
                                  Icons.arrow_back_ios,
                                  color: Color(0xFFB3B3B3),
                                ),
                                Text(
                                  "Back",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                    ],),
                                ),

                                 GestureDetector(
                        onTap: () => skip("8"),

                                   child: Text(
                                  "Skip",
                                  style: TextStyle(
                                      color: Color(0xFFB3B3B3),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),), 
                                  ],

                                ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 30.0, left: 20.0),
                                          width: 370.0,
                                          child: Text(
                                            "What's the lucky day that you were born?",
                                            style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontSize: 25.0),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Container(
                                            padding: EdgeInsets.only(
                                                top: 50.0, left: 20.0),
                                            width: 350.0,
                                            child: TextFormField(
                                              readOnly: true,
                                              controller: _dateController,
                                              style: TextStyle(
                                                  color: Color(0xB3FFFFFF),
                                                  fontSize: 18.0),
                                              decoration: const InputDecoration(
                                                enabledBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey,
                                                      width: 0.0),
                                                ),
                                                focusedBorder:
                                                    const UnderlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.grey,
                                                      width: 0.0),
                                                ),
                                                labelText: 'YYYY-MM-DD',
                                                labelStyle: TextStyle(
                                                    color: Color(0xB3FFFFFF),
                                                    fontSize: 18.0),
                                              ),
                                              onTap: () async {
                                                await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(1940),
                                                  lastDate: DateTime.now(),
                                                ).then((selectedDate) {
                                                  if (selectedDate != null) {
                                                    _dateController.text =
                                                        DateFormat('yyyy-MM-dd')
                                                            .format(
                                                                selectedDate);
                                                  }
                                                });
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter date.';
                                                }
                                                return null;
                                              },
                                            )),
                                        Padding(padding: EdgeInsets.all(40)),
                                        GestureDetector(
                                          onTap: () => next("8"),
                                          child: Container(
                                            height: 45.0,
                                            width: 112.67,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(23.0),
                                                border: Border.all(
                                                    color: Color(0xFFB3B3B3),
                                                    width: 3.0)),
                                            child: Center(
                                              child: Text(
                                                "Next",
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontSize: 18.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]))
                                  : pageNumber == '8'
                                      ? Container(
                                          padding: EdgeInsets.only(top: 40.0),
                                          child: Column(children: <Widget>[
                                            GestureDetector(
                                                onTap: () => back("7"),
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 20.0),
                                                    width: 377.0,
                                                    child: Wrap(
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.arrow_back_ios,
                                                          color:
                                                              Color(0xFFB3B3B3),
                                                        ),
                                                        Text(
                                                          "back",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFFB3B3B3),
                                                              fontSize: 16.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ))),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 30.0,
                                                  bottom: 10.0,
                                                  left: 30),
                                              width: 370.0,
                                              child: Text(
                                                "Knowledge",
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontSize: 25.0),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Wrap(
                                              children: knowledge
                                                  .map((item) => Container(
                                                      padding: EdgeInsets.only(
                                                          right: 10.0),
                                                      child: FlatButton(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      10.0),
                                                              side: BorderSide(
                                                                  color: _selectedInterests.indexOf(item) !=
                                                                          -1
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .white)),
                                                          color: _selectedInterests
                                                                      .indexOf(
                                                                          item) !=
                                                                  -1
                                                              ? Colors.red
                                                              : Colors.black,
                                                          textColor: _selectedInterests
                                                                      .indexOf(item) !=
                                                                  -1
                                                              ? Colors.white
                                                              : Colors.white,
                                                          onPressed: () => {
                                                                setState(() {
                                                                  if (_selectedInterests
                                                                          .indexOf(
                                                                              item) !=
                                                                      -1) {
                                                                    _selectedInterests
                                                                        .remove(
                                                                            item);
                                                                  } else {
                                                                    _selectedInterests
                                                                        .add(
                                                                            item);
                                                                  }
                                                                })
                                                              },
                                                          child: Text(item,
                                                              style: TextStyle(
                                                                fontSize: 9.0,
                                                              )))))
                                                  .toList()
                                                  .cast<Widget>(),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 30.0,
                                                  bottom: 10.0,
                                                  left: 30),
                                              width: 370.0,
                                              child: Text(
                                                "Hustle",
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontSize: 25.0),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Wrap(
                                              children: hustle
                                                  .map((item) => Container(
                                                      padding: EdgeInsets.only(
                                                          right: 10.0),
                                                      child: FlatButton(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      10.0),
                                                              side: BorderSide(
                                                                  color: _selectedInterests.indexOf(item) !=
                                                                          -1
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .white)),
                                                          color: _selectedInterests
                                                                      .indexOf(
                                                                          item) !=
                                                                  -1
                                                              ? Colors.red
                                                              : Colors.black,
                                                          textColor: _selectedInterests
                                                                      .indexOf(item) !=
                                                                  -1
                                                              ? Colors.white
                                                              : Colors.white,
                                                          onPressed: () => {
                                                                setState(() {
                                                                  if (_selectedInterests
                                                                          .indexOf(
                                                                              item) !=
                                                                      -1) {
                                                                    _selectedInterests
                                                                        .remove(
                                                                            item);
                                                                  } else {
                                                                    _selectedInterests
                                                                        .add(
                                                                            item);
                                                                  }
                                                                })
                                                              },
                                                          child: Text(item,
                                                              style: TextStyle(
                                                                fontSize: 9.0,
                                                              )))))
                                                  .toList()
                                                  .cast<Widget>(),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 30.0,
                                                  bottom: 10.0,
                                                  left: 30),
                                              width: 370.0,
                                              child: Text(
                                                "World Affairs",
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontSize: 25.0),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Wrap(
                                              children: worldAffairs
                                                  .map((item) => Container(
                                                      padding: EdgeInsets.only(
                                                          right: 10.0),
                                                      child: FlatButton(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      10.0),
                                                              side: BorderSide(
                                                                  color: _selectedInterests.indexOf(item) !=
                                                                          -1
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .white)),
                                                          color: _selectedInterests
                                                                      .indexOf(
                                                                          item) !=
                                                                  -1
                                                              ? Colors.red
                                                              : Colors.black,
                                                          textColor: _selectedInterests
                                                                      .indexOf(item) !=
                                                                  -1
                                                              ? Colors.white
                                                              : Colors.white,
                                                          onPressed: () => {
                                                                setState(() {
                                                                  if (_selectedInterests
                                                                          .indexOf(
                                                                              item) !=
                                                                      -1) {
                                                                    _selectedInterests
                                                                        .remove(
                                                                            item);
                                                                  } else {
                                                                    _selectedInterests
                                                                        .add(
                                                                            item);
                                                                  }
                                                                })
                                                              },
                                                          child: Text(item,
                                                              style: TextStyle(
                                                                fontSize: 9.0,
                                                              )))))
                                                  .toList()
                                                  .cast<Widget>(),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 30.0,
                                                  bottom: 10.0,
                                                  left: 30),
                                              width: 370.0,
                                              child: Text(
                                                "Sports",
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontSize: 25.0),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Wrap(
                                              children: sports
                                                  .map((item) => Container(
                                                      padding: EdgeInsets.only(
                                                          right: 10.0),
                                                      child: FlatButton(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      10.0),
                                                              side: BorderSide(
                                                                  color: _selectedInterests.indexOf(item) !=
                                                                          -1
                                                                      ? Colors
                                                                          .red
                                                                      : Colors
                                                                          .white)),
                                                          color: _selectedInterests
                                                                      .indexOf(
                                                                          item) !=
                                                                  -1
                                                              ? Colors.red
                                                              : Colors.black,
                                                          textColor: _selectedInterests
                                                                      .indexOf(item) !=
                                                                  -1
                                                              ? Colors.white
                                                              : Colors.white,
                                                          onPressed: () => {
                                                                setState(() {
                                                                  if (_selectedInterests
                                                                          .indexOf(
                                                                              item) !=
                                                                      -1) {
                                                                    _selectedInterests
                                                                        .remove(
                                                                            item);
                                                                  } else {
                                                                    _selectedInterests
                                                                        .add(
                                                                            item);
                                                                  }
                                                                })
                                                              },
                                                          child: Text(item,
                                                              style: TextStyle(
                                                                fontSize: 9.0,
                                                              )))))
                                                  .toList()
                                                  .cast<Widget>(),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.all(40)),
                                            GestureDetector(
                                              onTap: () => next("9"),
                                              child: Container(
                                                height: 45.0,
                                                width: 112.67,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            23.0),
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFFB3B3B3),
                                                        width: 3.0)),
                                                child: Center(
                                                  child: Text(
                                                    "Next",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFFFFFFF),
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]))
                                      : pageNumber == '9'
                                          ? Container(
                                              padding:
                                                  EdgeInsets.only(top: 40.0),
                                              child: Column(children: <Widget>[
                                                GestureDetector(
                                                    onTap: () => back("8"),
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20.0),
                                                        width: 377.0,
                                                        child: Wrap(
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .arrow_back_ios,
                                                              color: Color(
                                                                  0xFFB3B3B3),
                                                            ),
                                                            Text(
                                                              "back",
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFFB3B3B3),
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ))),
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      top: 30.0, left: 20.0),
                                                  width: 370.0,
                                                  child: Text(
                                                    "Referral code(If any)",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFFFFFFF),
                                                        fontSize: 25.0),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 45.0,
                                                                right: 30.0,
                                                                top: 16.0,
                                                                bottom: 16.0),
                                                        child: TextField(
                                                          controller:
                                                              referalCode,
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xB3FFFFFF),
                                                              fontSize: 18.0),
                                                          decoration:
                                                              const InputDecoration(
                                                            enabledBorder:
                                                                const UnderlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .grey,
                                                                      width:
                                                                          0.0),
                                                            ),
                                                            focusedBorder:
                                                                const UnderlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .grey,
                                                                      width:
                                                                          0.0),
                                                            ),
                                                            labelText:
                                                                'Enter Referral code',
                                                            labelStyle: TextStyle(
                                                                color: Color(
                                                                    0xB3FFFFFF),
                                                                fontSize: 18.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    referalApplied == 'No'
                                                        ? GestureDetector(
                                                            onTap: apply,
                                                            child: Container(
                                                              height: 50.0,
                                                              width: 80.0,
                                                              child: Center(
                                                                child: Text(
                                                                  "Apply",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontSize:
                                                                          20.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : referalApplied ==
                                                                'inProgress'
                                                            ? GestureDetector(
                                                                onTap: apply,
                                                                child:
                                                                    Container(
                                                                  height: 50.0,
                                                                  width: 80.0,
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Wait",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontSize:
                                                                              20.0,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : GestureDetector(
                                                                onTap: apply,
                                                                child:
                                                                    Container(
                                                                  height: 50.0,
                                                                  width: 80.0,
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Applied",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontSize:
                                                                              20.0,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                  ],
                                                ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.all(40)),
                                                GestureDetector(
                                                  onTap: submit,
                                                  child: Container(
                                                    height: 45.0,
                                                    width: 112.67,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(23.0),
                                                        border: Border.all(
                                                            color: Color(
                                                                0xFFB3B3B3),
                                                            width: 3.0)),
                                                    child: Center(
                                                      child: Text(
                                                        "Submit",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFFFFFFFF),
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]))
                                          : Container()
        ],
      ),
    );
  }
}
