import 'package:flutter/material.dart';
import 'main_page.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingPage extends StatefulWidget{
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>{

  String userName;
  String password;

  Future<bool> _getLoginStatus() async{
    var status;
    var prefs = await SharedPreferences.getInstance();

    userName = prefs.getString('user_name');
    password = prefs.getString('password');
    status =  prefs.getBool('login');

    print("_getLoginStatus:" + status.toString());
    return status;
  }

  @override
  void initState() {
    super.initState();

    _getLoginStatus().then((result){
      if(!result || (userName == null) || (password == null)){
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (context) => new LoginPage()),
                (route) => route == null);

      }
      else{
        //重新通过服务器验证账号名和密码是否正确
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (context) => new HomePage(userName, password)),
                (route) => route == null);
      }
    });

/*    new Future.delayed(Duration(seconds: 3),(){
      Navigator.of(context).pushAndRemoveUntil(
          new MaterialPageRoute(builder: (context) => new HomePage()),
              (route) => route == null);
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}