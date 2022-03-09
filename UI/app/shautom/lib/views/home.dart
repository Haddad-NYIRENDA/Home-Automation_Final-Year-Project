import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:shautom/control.dart';
import 'package:shautom/models/user.dart';
import 'package:shautom/monitor.dart';
import 'package:shautom/profile.dart';
import 'package:shautom/views/components/logo.dart';

import 'package:shautom/views/welcome.dart';
import 'package:shautom/views/top_sliver_widget.dart';

class LandingPage extends StatelessWidget {
  UserModel? user;
  bool loaded;

  LandingPage({
    Key? key,
    required this.user,
    required this.loaded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: loaded
                    ? RichText(
                        text: TextSpan(
                            style: TextStyle(
                                fontSize: 30, fontStyle: FontStyle.italic),
                            children: <InlineSpan>[
                            TextSpan(
                                text: "Welcome, ",
                                style: TextStyle(color: Colors.black)),
                            TextSpan(
                                text: "${user!.firstName}",
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontStyle: FontStyle.italic))
                          ]))
                    : Text('Loading...'),
              ),
            ],
          )
        ]);
  }
}

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoaded = false;

  User? _user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WelcomePage()));
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(_user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {
        _isLoaded = true;
      });
    });
  }

  UserModel getUser() {
    return this.loggedInUser;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //Media Device data config

    Map<int, Map<String, dynamic>> _pages = {
      0: {
        'title': 'Home',
        'widget': LandingPage(
          loaded: _isLoaded,
          user: loggedInUser,
        )
      },
      1: {
        'title': 'Profile',
        'widget': ProfilePage(
          user: loggedInUser,
        )
      },
      2: {'title': 'Control Dashboard', 'widget': ControlPage()},
      3: {'title': 'Monitoring Dashboard', 'widget': MonitorPage()}
    };

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
        //resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: CustomScrollView(slivers: [
          CustomSliverAppBar(
              childWidget: LogoWidget(
                widthFactor: 0.8,
              ),
              pageTitle: Text(_pages[_selectedIndex]!['title']),
              logOut: _signOut),
          SliverFillRemaining(child: _pages[_selectedIndex]!['widget']),
        ])),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          backgroundColor: Colors.grey.withAlpha(50),
          elevation: 0, //Color(0xFF3F51B5)
          iconSize: 30,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: ImageIcon(Svg('assets/images/icons/home.svg')),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  size: 30,
                ), //ImageIcon(Svg('assets/images/icons/person.svg',),ize: 30),
                label: 'Settings'),
            BottomNavigationBarItem(
                icon: ImageIcon(Svg('assets/images/icons/control.svg')),
                label: "Control"),
            BottomNavigationBarItem(
                icon: ImageIcon(Svg('assets/images/icons/monitor.svg')),
                label: 'Monitor'),
          ],
        ));
  }
}
