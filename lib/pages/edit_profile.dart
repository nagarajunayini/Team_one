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

  
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  String username;
  final _formKey = GlobalKey<FormState>();
  User user;
  bool _displayNameValid = true;
  bool _bioValid = true;
  var gender = ["Male", "Female", "Others"];
  var religion = ["Hindu", "Muslim", "Christian", "Others"];
  var interests = ["All","Politcs", "Sports", "Technology", "Wether","Environment","Mrdicine","Journalism","Films","Arts"];
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
    displayNameController.text = user.username;
    emailController.text= user.email;
    if(user.interests !=null && user.interests.length !=0){
      this._selectedInterests = user.interests;
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
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
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
        "displayName": displayNameController.text,
        "email":emailController.text,
        "interests": this._selectedInterests,
        "extraInfo": [
          this.selectedCity,
          this.selectedGender,
          this.selectedReligion,
          
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
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 0.0, left: 0.0)),
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
                                  value: dropdownItem,
                                  child: Text(dropdownItem));
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 0.0, left: 0.0)),
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
                                  value: dropdownItem,
                                  child: Text(dropdownItem));
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(
                                  top: 0.0, left: 0.0, bottom: 20.0)),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 10.0,
                            ),
                            child: Center(
                              child: Text(
                                "Religion:",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: 60.0, left: 150.0, right: 10.0)),
                          DropdownButton<String>(
                            items: religion.map((String dropdownItem) {
                              return DropdownMenuItem<String>(
                                  value: dropdownItem,
                                  child: Text(dropdownItem));
                            }).toList(),
                            onChanged: (String selectedValue) {
                              setState(() {
                                this.selectedReligion = selectedValue;
                              });
                            },
                            value: this.selectedReligion,
                          ),
                        ],
                      ),
                      MultiSelectChipField(
                        decoration:BoxDecoration(),
                      headerColor:Colors.white,
                        title: Text("Interests"),
  items: interests.map((e) => MultiSelectItem(e, e)).toList(),
  icon: Icon(Icons.check),
  onTap: (values) {
    this._selectedInterests = values;
  },
),
                      GestureDetector(
                        onTap: updateProfileData,
                        child: Container(
                          height: 50.0,
                          width: 350.0,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          child: Center(
                            child: Text(
                              "Update",
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
