import 'package:flutter/material.dart';
import 'models/user.dart';

/// User Profile/Settings
class ProfilePage extends StatelessWidget {
  //final GlobalKey<_HomePageState> homeKey = GlobalKey<_HomePageState>();
  final UserModel? user;

  ProfilePage({
    Key? key,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Settings(user: user));
  }
}

/// User Settings
class Settings extends StatelessWidget {
  final UserModel? user;
  Settings({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _mySettings(
      context,
    );
  }

  /// Build helper method - builds settings page
  Widget _mySettings(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        child: ListView(
      children: [
        user == null
            ? CircularProgressIndicator()
            : Container(
                margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10)),
                height: size.height * 0.2,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: [
                      CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.6),
                          radius: size.width * 0.15,
                          child: Text(
                            "${user?.firstName![0].toUpperCase()}${user?.lastName![0].toUpperCase()}",
                            style: TextStyle(fontSize: size.width * 0.12),
                          )),
                    ]),
                    Padding(
                      padding: const EdgeInsets.only(top: 40, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${user!.firstName} ${user!.lastName}"),
                          SizedBox(height: 10),
                          Text("${user!.emailAddress}"),
                        ],
                      ),
                    )
                  ],
                ),
              ),
        ListTile(
          leading: Icon(
            Icons.person,
            color: Colors.blue.withOpacity(0.6),
          ),
          title: Text("Profile"),
          subtitle: Text("User Details"),
          trailing: Container(child: Icon(Icons.arrow_forward_ios)),
        ),
        ListTile(
          leading: Icon(
            Icons.settings,
            color: Colors.blue.withOpacity(0.6),
          ),
          title: Text("Settings"),
          subtitle: Text("System Configuration"),
          trailing: Container(child: Icon(Icons.arrow_forward_ios)),
        ),
        ListTile(
          leading: Icon(
            Icons.data_object,
            color: Colors.blue.withOpacity(0.6),
          ),
          title: Text("Data"),
          subtitle: Text("Data Configuration"),
          trailing: Container(child: Icon(Icons.arrow_forward_ios)),
        ),
        ListTile(
          leading: Icon(Icons.info, color: Colors.blue.withOpacity(0.6)),
          minVerticalPadding: 3,
          title: Text("About"),
          subtitle: Text("System Details"),
          trailing: Container(child: Icon(Icons.arrow_forward_ios)),
        )
      ],
    ));
  }
}
