import 'package:agh_soccer/src/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  final User user;

  ProfileView({Key key, this.user}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(
                'assets/billy.jpeg',
              ),
            ),
          ),
          height: 300.0,
        ),
        SizedBox(
          width: double.infinity,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: userInfo(),
            ),
            decoration: BoxDecoration(
              color: Colors.black26
            ),
          ),
        ),
      ],
    );
  }

  Widget userInfo() {
    return Column(
      children: <Widget>[
        Text(
            user.nickname,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 20.0,
        ),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7)
          ),
          textAlign: TextAlign.center,

        )
      ],
    );
  }
}