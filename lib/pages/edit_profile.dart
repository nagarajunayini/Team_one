import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
  TextEditingController nickName = TextEditingController();

  
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  String username;
  final _formKey = GlobalKey<FormState>();
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;
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
  String selectedGender;
  String selectedReligion;
  String selectedCity;

  List<dynamic> _selectedInterests = [];

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    nickName.text = user.username;
    emailController.text= user.email;
    if(user.interests !=null && user.interests.length !=0){
      this._selectedInterests.addAll(user.interests);
    }else{
      this._selectedInterests =[];
    }
    if (user.extraInfo != null && user.extraInfo.length >= 1) {
      user.extraInfo.forEach((a) => {
            if (this.city.indexOf(a) > -1)
              {this.selectedCity = a}
            else if(this.gender.indexOf(a) > -1)
                {this.selectedGender = a}
              else
                {this.selectedReligion = a}
          });
    } else {
      this.selectedGender = "Male";
      this.selectedReligion = "All";
      this.selectedCity = "Hyderabad";
    }

    setState(() {
      isLoading = false;
    });
  }

  updateProfileData() {
    setState(() {
      nickName.text.trim().length < 3 ||
              nickName.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
    });

    print(validateEmail(emailController.text));

    if (_displayNameValid && _bioValid ) {
      if(validateEmail(emailController.text) == null){
        usersRef.document(widget.currentUserId).updateData({
        "displayName": nickName.text,
        "email":emailController.text,
        "interests": this._selectedInterests,
        "extraInfo": [
          this.selectedCity,
          this.selectedGender,          
        ],
      });
      SnackBar snackbar = SnackBar(content: Text("Profile updated!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);  
      }else{
 SnackBar snackbar = SnackBar(content: Text("Enter Valid Email"));
      _scaffoldKey.currentState.showSnackBar(snackbar); 
      }
      
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              size: 30.0,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
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
                          radius: 50.0,
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoUrl),
                        ),
                      ),
                      Container(
                            padding: EdgeInsets.only(top: 50.0, left: 20.0),
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
                             Container(
                                    padding:
                                        EdgeInsets.only(top: 30.0, left: 20.0),
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
                                             Padding(padding: EdgeInsets.all(40)),
                GestureDetector(
                  onTap: updateProfileData,
                  child: Container(
                    height: 45.0,
                    width: 112.67,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23.0),
                        border:
                            Border.all(color: Color(0xFFB3B3B3), width: 3.0)),
                    child: Center(
                      child: Text(
                        "Update",
                        style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(40)),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
