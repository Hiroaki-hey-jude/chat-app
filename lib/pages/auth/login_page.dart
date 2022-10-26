import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/helper/helper_function.dart';
import 'package:flutter_chat/pages/auth/register_page.dart';
import 'package:flutter_chat/service/auth_service.dart';
import 'package:flutter_chat/service/database_service.dart';

import '../../shared/enum.dart';
import '../../widgets/widgets.dart';
import '../home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isloading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isloading
            ? Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor))
            : SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                  child: Form(
                    key: formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Groupie',
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text('Login now to see what they are talking!',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          Image.asset("assets/login.png"),
                          TextFormField(
                            decoration: textInputDecoration.copyWith(
                                labelText: "Email",
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Theme.of(context).primaryColor,
                                )),
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },

                            // check tha validation
                            validator: (val) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val!)
                                  ? null
                                  : "Please enter a valid email";
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            obscureText: true,
                            decoration: textInputDecoration.copyWith(
                                labelText: "Password",
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Theme.of(context).primaryColor,
                                )),
                            validator: (val) {
                              if (val!.length < 6) {
                                return "Password must be at least 6 characters";
                              } else {
                                return null;
                              }
                            },
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              onPressed: () {
                                login();
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text.rich(TextSpan(
                              text: "Dont't have an account? ",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Register here',
                                    style: TextStyle(
                                        color: Colors.black,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        nextScreen(
                                            context, const RegisterPage());
                                      })
                              ]))
                        ]),
                  ),
                ),
              ));
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });
      final EmailLogInResults emailLogInResults =
          await authService.logInUserWithEmailandPassword(email, password);
      String message = '';
      if (emailLogInResults == EmailLogInResults.LogInCompleted) {
      QuerySnapshot snapshot =
          await DataBaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .gettingUserData(email);
        await HelperFunctions.saveUserLoggedInStatus(true);
        await HelperFunctions.saveUserEmailSF(email);
        await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);//naze
        print(snapshot.docs[0]['fullName']);
        nextScreenReplacement(context, const HomePage());
      } else if (emailLogInResults == EmailLogInResults.EmailNotVerified) {
        message =
            'Email not verified. \nPlease Verify your Email and then log in';
      } else if (emailLogInResults == EmailLogInResults.EmailPasswordInvalid) {
        message = 'Email Or Password Invalid';
      } else
        message = 'Log in not completed';

      if (message != '')
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));

      setState(() {
        _isloading = false;
      });
    } else {
      print('not validated ');
    }
  }
}
