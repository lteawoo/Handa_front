import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Member {
  String email;
  String password;

  Member({
    this.email,
    this.password,
  });

  Map<String, dynamic> toJson() =>
      {
        'email': {
          'value': email,
        },
        'password': {
          'value': password,
        },
      };
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
  });

  final Key fieldKey;
  final String hintText;
  final String labelText;
  final String helperText;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> validator;
  final ValueChanged<String> onFieldSubmitted;

  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      obscureText: _obscureText,
      cursorColor: Theme.of(context).cursorColor,
      maxLength: 12,
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscureText ? '보여줌' : '안보여줌',
          ),
        ),
      ),
    );
  }
}

class SignIn extends StatelessWidget {
  Member member = Member();
  bool _autoValidate = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSubmitted() {
    final form = _formKey.currentState;
    if(!form.validate()) {
      _autoValidate = true;
    } else {
      form.save();
    }
  }

  String _validateEmail(String value) {
    if(value.isEmpty) {
      return 'Email is required.';
    }
    return null;
  }

  String _validatePassword(String value) {
    if(value.isEmpty) {
      return 'Password is required.';
    }
    return null;
  }

  void _signIn(BuildContext context) async{
    if(!_formKey.currentState.validate()) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = member.email;
    String password = member.password;
    String uri = "http://localhost:8080/oauth/token?grant_type=password&username=$username&password=$password";
    String clientId = "taeu_client";
    String clientPw = "taeu_secret";
    String authorization = "Basic " + base64Encode(utf8.encode('$clientId:$clientPw'));
    debugPrint(authorization);

    final response = await http.post(
      uri,
      headers: {
        'Authorization': authorization,
      },
    ).catchError((error) {
      debugPrint(error.toString());
      throw error;
    }).then((response) {
      Map responseMap = jsonDecode(response.body);

      debugPrint(response.statusCode.toString());

      if(response.statusCode == 200) {
        prefs.setString('access_token', responseMap['access_token']);

        Navigator.of(context).pushReplacementNamed('/todo');
      } else {
        debugPrint(responseMap.toString());
      }
    });
  }
  void _signUp(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/sign_up');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Handa'),
      ),
      body: Form(
        key: _formKey,
        autovalidate: _autoValidate,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  onSaved: (String value) {
                    member.email = value;
                  },
                  validator: _validateEmail,
                ),
                PasswordField(
                    labelText: 'Password',
                    validator: _validatePassword,
                    onSaved: (String value) {
                      member.password = value;
                    }
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        child: Text('SIGN IN'),
                        onPressed: () {
                          _handleSubmitted();
                          _signIn(context);
                        },
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        child: Text('SIGN UP'),
                        onPressed: () {
                          _signUp(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}