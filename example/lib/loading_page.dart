import 'package:flutter/material.dart';
import 'main_page.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingPage extends StatefulWidget{
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>{

  Future<bool> _getLoginStatus() async{
    var status;
    var prefs = await SharedPreferences.getInstance();
    status =  prefs.getBool('login');
    print("_getLoginStatus:" + status.toString());
    return status;
  }

  @override
  void initState() {
    super.initState();

    _getLoginStatus().then((result){
      if(result){
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (context) => new HomePage()),
                (route) => route == null);
      }
      else{
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (context) => new LoginPage()),
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