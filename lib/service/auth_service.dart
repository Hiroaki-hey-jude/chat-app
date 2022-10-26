import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat/helper/helper_function.dart';
import 'package:flutter_chat/service/database_service.dart';
import 'package:flutter_chat/widgets/widgets.dart';

import '../shared/enum.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //log in function
  Future<EmailLogInResults> logInUserWithEmailandPassword(
      String email, String password) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user!;
      if (user != null) {
        return EmailLogInResults.LogInCompleted;
      } else {
        print('nani!!!');
        final bool logOutResponse = await signOut();
        if (logOutResponse) return EmailLogInResults.EmailNotVerified;
        return EmailLogInResults.UnexpectedError;
      }
    } on FirebaseAuthException catch (e) {
      print('kokodayone');
      print(e);
      return EmailLogInResults.EmailPasswordInvalid;
    }
  }

  //register
  Future<EmailSignResults> registerUserWithEmailandPassword(
      String fullName, String email, String password) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user!;

      if (user != null) {
        //call our database service to update the user data
        await DataBaseService(uid: user.uid).savingUserData(fullName, email);
        return EmailSignResults.SignUpCompleted;
      }
      return EmailSignResults.SignUpNotCompleted;
    } on FirebaseAuthException catch (e) {
      print(e);
      return EmailSignResults.EmailAlreadyPresent;
    }
  }

  //sign out
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInStatus(false);
      await HelperFunctions.saveUserEmailSF('');
      await HelperFunctions.saveUserNameSF('');
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }
}
