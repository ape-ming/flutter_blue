

import 'dart:convert';

import 'package:flutter/material.dart';
import 'http_helper.dart';
import 'main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget{
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey _formKey = new GlobalKey<FormState>();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _pwdController = new TextEditingController();
  FocusNode _nameFocusNode = new FocusNode();
  FocusNode _pwdFocusNode  = new FocusNode();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
      duration: Duration(seconds: 3),
    ));
  }

  TextFormField buildUserName(){
    return TextFormField(
      //autofocus: true,
      keyboardType: TextInputType.text,
      focusNode: _nameFocusNode,
      controller: _nameController,
      decoration: InputDecoration(
        //hintText: '请输入用户名',
        labelText: '请输入用户名',
        prefixIcon: Icon(Icons.person),
      ),

      // 校验用户名
      validator: (v) {
        return v
            .trim()
            .length > 0 ? null : "用户名不能为空";
      }
    );
  }

  TextFormField buildPassword(){
    return TextFormField(
      focusNode: _pwdFocusNode,
      controller: _pwdController,
      decoration: InputDecoration(
        //hintText: '请输入密码',
        labelText: '请输入密码',
        prefixIcon: Icon(Icons.lock)
      ),

      obscureText: true,
      //校验密码
      validator: (v) {
        return v
            .trim()
            .length > 5 ? null : "密码不能少于6位";
      }
    );
  }

  Widget buildLoginButton({VoidCallback onPressed}){
    return Padding(
      padding: EdgeInsets.only(top: 50),
      child: Row(
        //mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: RaisedButton(
              color: Colors.blue,
              highlightColor: Colors.blue[700],
              colorBrightness: Brightness.dark,
              shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              child: new Padding(
                padding: new EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                child: Text(
                  '登录',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .button
                      .copyWith(color: Colors.white),
                ),
              ),
              onPressed: onPressed,
            ),
          ),

        ],
      ),
    );
  }

  _setLoginStatus(String userName, String password, int role) async{
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login', true);
    await prefs.setString('user_name', userName);
    await prefs.setString('password', password);
    await prefs.setInt('role', role);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            //autovalidate: true,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center, //垂直方向居中对齐
              children: <Widget>[
                SizedBox(
                  height: 160,
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('请登录',
                      style: Theme.of(context).textTheme.display1.copyWith(color: Colors.black)),
                ),

                SizedBox(
                  height: 40,
                ),

                buildUserName(),
                buildPassword(),
                buildLoginButton(
                    onPressed: (){
                      _nameFocusNode.unfocus();
                      _pwdFocusNode.unfocus();
                      if((_formKey.currentState as FormState).validate()){

                        //验证通过提交数据
                        _waitLoginRequest(_nameController.text, _pwdController.text).then((e){
                          //print('_waitLoginRequest');
                        });
                      }
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

   _loginRequest(String name, String password, callBack(t)) async{
    var response = await HttpHelper().request("Login?username=$name&password=$password");

    if(response != null){
      callBack(response.data);
    }else{
      showInSnackBar('网络连接失败，请检查网络连接！');
    }
  }

  Future<void> _waitLoginRequest(String name, String password) async {
    await _loginRequest(name, password, (t) {

      Map<String, dynamic> user = json.decode(t);

      if(user.containsKey('isExist')){
        if(user['isExist']){
          int role =  user['role'];
          _setLoginStatus(name, password, role);
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(builder: (context) => new HomePage(name, password, role)),
                  (route) => route == null);
        }
      }
      showInSnackBar('用户名或密码错误！');
    });
  }
}
