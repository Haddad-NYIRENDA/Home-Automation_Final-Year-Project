import 'package:flutter/material.dart';
import 'package:shautom/views/home.dart';
import 'package:shautom/views/welcome.dart';

/// Firebase initialization imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Runs MiHome application asynchronically
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      //options : DefaultFirebaseOptions.currentPlatform,
      );
  runApp(MiHome());
}

/// MiHome Entry application
class MiHome extends StatelessWidget {
  static final String title = "MiHome - SHAUTOM";
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<
      NavigatorState>(); // Navigator key for handling routes and app navigation

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      navigatorKey: navigatorKey,
      theme: ThemeData(
          fontFamily: 'Poppins',
          primaryColor: Colors.white,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.blue)),
      home: MainPage(),
    );
  }
}

/// MiHome MainPage
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        /// Uses streambuilder to determine app initial redirection
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Something went wrong!'))) as Widget;
              } else if (snapshot.hasData) {
                return HomePage();
              } else {
                return WelcomePage();
              }
            }));
  }
}
