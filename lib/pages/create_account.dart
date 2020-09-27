import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String username;
  List<dynamic> userDetails = [];
  List<dynamic> extraIfo = [];
  var gender = ["Male", "Female", "Others"];
  var religion = ["Hindu", "Muslim", "Christian", "Others"];
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
  String selectedReligion = "Hindu";
  String selectedCity = "Hyderabad";

  submit() {
    this.extraIfo = [
      this.selectedCity,
      this.selectedGender,
      this.selectedReligion
    ];
    this.userDetails = [displayNameController.text, this.extraIfo];
    String name = displayNameController.text;
    SnackBar snackbar = SnackBar(content: Text("Welcome $name!"));
    _scaffoldKey.currentState.showSnackBar(snackbar);
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context, this.userDetails);
    });
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                        padding:
                            EdgeInsets.only(top: 0.0, left: 0.0, bottom: 20.0)),
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
                            value: dropdownItem, child: Text(dropdownItem));
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
