import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firebase = FirebaseAuth.instance;  // instance of FirebaseAuth

// AuthScreen is a StatefulWidget, meaning that it can change its state
// said in other words: it has internal data tha can be changed
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key}); 
  // constructor with a named parameter {} a key from the parent class super

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>(); // form key, to be learned from previous lessons

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  var _isAuthenticating = false;
  var _enteredUsername = '';

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || (!_isLogin && _selectedImage == null)) {
      // if the form is not valid or if the user is trying to sign up without an image
      // show an error message
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if(_isLogin) {
        // Log user in
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        // Sign user up
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        print(imageUrl); // to be removed in the final version

        await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
            'username': _enteredUsername,
            'email': _enteredEmail,
            'image_url': imageUrl,
          });

      }
    } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          //...
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Authentication failed.'),
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(onPickImage: (pickedImage) {
                              _selectedImage = pickedImage;
                            },),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator:(value) {
                              if (value == null || 
                                  value.trim().isEmpty || 
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                ),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null || 
                                    value.trim().isEmpty || 
                                    value.trim().length < 4) {
                                  return 'Username must be at least 4 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || 
                                  value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              ),
                              child: Text(_isLogin 
                                ? 'Login' 
                                : 'SignUp'),
                              ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                    _isLogin = !_isLogin;
                                });
                              }, 
                              child: Text( _isLogin 
                                ? 'Create an account' 
                                : 'I already have an account.'),
                              ),
                        ],
                      ),
                    ),
                ),
              ),
            ),
            ],
          ),
        ),
        ),
    );
  }
}