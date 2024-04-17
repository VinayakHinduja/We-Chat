// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/widgets/constants.dart';

import '../main.dart';
import '../api/apis.dart';
import 'package:we_chat/helpers/helpers.dart';
import 'package:we_chat/screens/screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 500),
      () => setState(() => _isAnimate = true),
    );
  }

  _handleGoogleButtonClick() {
    _signInWithGoogle().then(
      (user) async {
        if (user != null) {
          if (await APIs.userExists()) {
            await APIs.getSelfInfo().then(
              (_) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
            );
          } else {
            await APIs.createUser().then(
              (_) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
            );
          }
        }
      },
    );
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      LoadingScreen()
          .show(context: context, text: 'Please Wait While I Sign You In');

      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow

      final googleSignIn = GoogleSignIn(scopes: ['openid', 'email', 'profile']);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      var cred = await FirebaseAuth.instance.signInWithCredential(credential);
      LoadingScreen().hide();
      return cred;
    } catch (e) {
      log('\n_signInWithGoogle = $e');
      Dialogs.showSnackbar(context, 'Something went wrong');
      LoadingScreen().hide();
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to We Chat'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mobileMq.height * .15,
            // right: _isAnimate ? mobileMq.width * .25 : -mobileMq.width * .5,
            right: _isAnimate ? mobileMq.width * .20 : -mobileMq.width * .30,
            width: mobileMq.width * .6,
            duration: const Duration(seconds: 1),
            child: Image.asset(iconPng),
          ),
          AnimatedPositioned(
            bottom: _isAnimate ? mobileMq.height * .15 : -mobileMq.height * .05,
            left: mobileMq.width * .05,
            width: mobileMq.width * .9,
            height: mobileMq.height * .06,
            duration: const Duration(seconds: 1),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              onPressed: () => _handleGoogleButtonClick(),
              icon: Image.asset(googlePng, height: mobileMq.height * .03),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    TextSpan(text: ' Login With '),
                    TextSpan(
                      text: 'Google',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
