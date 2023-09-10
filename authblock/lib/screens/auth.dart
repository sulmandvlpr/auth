//auth screen responsible for user input data for auth
//statful caus display some form and collect user data
import 'dart:io';

import 'package:authblock/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//this FirebaseAuth is Firebase Object and we store it in global valiable
//outside of classes to use throught this same object in this project
final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
//gloaba key to idenfity form fileds
  final _form = GlobalKey<FormState>();

//varabel save the entred email  inintally emty
  var _entredEmail = '';
//varabel save the entred passowd inintally emty
  var _entredPassword = '';
//variabel to hold image from file system
  File? _selectedImage;

//this varialbe controls we are in login mode or not
  var _isLogin = true;
//loaidng spinner while uploading to firebase
  var _isAuthenticating = false;

//enterd name
  var _enterdUserName = '';

//pressing Eleviated button with submit  will  hold of Entered values in Text filed, validate the value
//and create a new user in firebase database
//we need to sign up first cause we need to create user first then we login with that user
  void _submit() async {
    //triger validadator and make sure data entred is save
    final isValid = _form.currentState!.validate();
//if the endted data is not valid we retun and dont exuecte other thins like saveing,creating user in fb

    //only show image if we are SignUp state

    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }

    _form.currentState!.save();
    //the user we creat may have erros so try catch to save my ass

    try {
      setState(() {
        _isAuthenticating = true;
      });

      //log user in
      if (_isLogin) {
        //log user in
        final UserCredential = await _firebase.signInWithEmailAndPassword(
            email: _entredEmail, password: _entredPassword);
      }
      //sign up
      else {
        //sign up

        //firebase Object.methods() in my case i wnt to creat user with email and pass
        final UserCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _entredEmail, password: _entredPassword);

        //once we crtea a new user we also want to uplad image of that user
        //uplaod image to Firebase
        //1st create a path/folder inside firebase database
        //.ref() give us Access to firebasae storage
        //.child('Path/folder path  inside firebase')
        //get the user id uid of that user which we create as UserCreadinatls

        //2nd uplad taken Image from user to firebase
        final storageRef = await FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${UserCredentials.user!.uid}.jpg');
        //2nd uplad taken Image from user to firebase
        //putFile to upload file to firebase database
        //and (file) here is user selected image
        //putFile returns a thing whih is somthig to wait for
        await storageRef.putFile(_selectedImage!);
        //give us a URL whihc is later to disply that image that was stored on Firebase
        //as we are storing this in online server not on device so we can
        //downlaod and use on every device so we use download url link
        //getDonwload return string Image url
        final imageUrl = await storageRef.getDownloadURL();
        //3rd go to firebase refresh and check image is availe on Storage tap

        //firestore works with collections , folders that contains data
        //this collection('users') users folder contains users data
        await FirebaseFirestore.instance
            .collection('users')
            .doc(UserCredentials.user!.uid)
            .set({
          'username': _enterdUserName,
          'email': _entredEmail,
          'image_url': imageUrl,
        });
      }

      //we need to sign up first cause we need to create user first then we login with that user
      //so first we need to find out whihc mood curent we are in login or signup
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-alredy-in-use') {
        //...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentatication failed'),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text('Login Screen'),
      ),
      //Display/render Form
      body: Center(
        child:
            //scoller caus i have column with multile fields/text input files
            SingleChildScrollView(
          child: Column(
            //center everything inside this column
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //container display image
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              //Styling auth from input with card
              Card(
                //margin arround the card
                margin: const EdgeInsets.all(20),
                child:
                    //input filed scroll easily
                    SingleChildScrollView(
                  child: Form(
                      key: _form,
                      child:
                          //two fields verticaly
                          Column(
                        //take only size wich this contnet needed
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //image selection shows only if we are Signup not show in if we are log in
                          if (!_isLogin)
                            UserImagePicker(
                              onPickedImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),

                          //email text field
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              //codition on entred value to check the validation
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter valid email address';
                              }
                              //return String if error or return Null if No error
                              return null;
                            },
                            onSaved: (value) {
                              //i am gona save this value as protpry
                              _entredEmail = value!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'User name'),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Entered Name must be contain 4 letters';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enterdUserName = value!;
                              },
                            ),

                          //password text field
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Pass***'),
                            //hide the text as we enterd
                            obscureText: true,
                            validator: (value) {
                              //codition on entred value to check the validation
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be atleast 6 characters long ';
                              }
                              //return String if error or return Null if No error
                              return null;
                            },
                            onSaved: (value) {
                              //i am gona save this value as protpry
                              _entredPassword = value!;
                            },
                          ),

                          //BUTTONS login signup
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)

                            //on pressing this button data will collecd and send to firebase
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              //on pressing this user will login or Sign up with new id
                              child: Text(_isLogin ? 'Login' : 'SignUp'),
                            ),
                          if (!_isAuthenticating)

                            //this is a toogle button whihc swicht btw login or sign mode
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  //by pressing it will  switch  isLogin property to if true then false or flase to true
                                  _isLogin = _isLogin ? false : true;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            ),
                        ],
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
