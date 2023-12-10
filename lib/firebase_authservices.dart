import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthServices {
  // Future<AuthController> init() async => this;

  final bool isAuthenticated = false;
  final bool isLogOut = false;

  void refreshAuth() {
    // isAuthenticated.refresh();
  }

  initAuth() async {
    await validateAuth();
    // ever(isAuthenticated, (auth) => handleAuthChange());
  }

  bool initialAuthStateReceived = false;

  // initAuth() {
  //   FirebaseAuth.instance.authStateChanges().listen((User? user) {
  //     if (user == null) {
  //       if (initialAuthStateReceived) {
  //         print('User is currently signed out!');
  //       }
  //     } else {
  //       print('User is signed in!');
  //     }
  //     initialAuthStateReceived = true;
  //   });
  // }

  Future<bool> validateAuth() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        if (initialAuthStateReceived) {
          print('User is currently signed out!');
        }
      } else {
        // isAuthenticated(true);
        // Get.offAllNamed(Routes.HOME);

        print('User is signed in!');
      }
      initialAuthStateReceived = true;
    });

    return isAuthenticated;
  }

  void handleAuthChange() {
    if (isLogOut) {
      // Get.offAllNamed(Routes.SIGNIN);
    } else {
      // print("sffs ${Get.find<AuthController>().isAuthenticated.value}");

      // AppRouteAccess.handleRedirect(Get.currentRoute, isAuthChange: true);
    }
  }

  Future<void> createUser(data) async {
    try {
      var response = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      var userData = {
        "id": response.user!.uid,
        "email": data['email'],
        "username": data['username'],
        "phone": data['phone'],
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(response.user!.uid)
          .set(userData);
      // isAuthenticated(true);
      // Get.offAllNamed(Routes.HOME);
    } catch (e) {
      showErrorMessage("Sign up Failed", e.toString());
    }
  }

  Future<void> login(data) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );

      // isAuthenticated(true);

      // Get.offAllNamed(Routes.HOME);
    } catch (e) {
      showErrorMessage("Login Failed", e.toString());
    }
  }

  void showErrorMessage(String title, String message) {
    // Get.defaultDialog(
    //   title: title,
    //   content: Text(message),
    // );
  }
}
