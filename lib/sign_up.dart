
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:handa/layout/adaptive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Member {
  String email;
  String name;
  String password;

  Member({
    this.email,
    this.name,
    this.password,
  });

  Map<String, dynamic> toJson() =>
      {
        'email': {
          'value': email,
        },
        'name': {
          'value': name,
        },
        'password': {
          'value': password,
        },
      };
}

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignInState();
}

class _SignInState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: _MainView(),
        )
    );
  }
}

class _MainView extends StatelessWidget {
  final Member member = Member();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<_ErrorMsgState> _errorMsgKey = GlobalKey<_ErrorMsgState>();

  String _validateEmail(String value) {
    if(value.isEmpty) {
      return 'Email is required.';
    }
    return null;
  }

  String _validateName(String value) {
    if(value.isEmpty) {
      return 'Name is required.';
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

        Navigator.of(context).pushReplacementNamed('/');
      } else {
        _errorMsgKey.currentState.setErrorMsg(response.statusCode.toString() + ', ' + responseMap['error'] + ': ' + responseMap['error_description']);
        debugPrint(responseMap.toString());
      }
    });
  }
  void _signUp(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/sign_up');
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    debugPrint(isDesktop.toString());
    final desktopMaxWidth = 400.0;

    return Column(
        children: [
          Expanded(
              child: Align(
                alignment: isDesktop ? Alignment.center : Alignment.topCenter,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      EmailField(
                        maxWidth: isDesktop ? desktopMaxWidth : null,
                        labelText: 'Email',
                        onSaved: (String value) {
                          member.email = value;
                        },
                        validator: _validateEmail,
                      ),
                      PasswordField(
                          maxWidth: isDesktop ? desktopMaxWidth : null,
                          labelText: 'Password',
                          validator: _validatePassword,
                          onSaved: (String value) {
                            member.password = value;
                          }
                      ),
                      ErrorMsg(
                        key: _errorMsgKey,
                      ),
                      _LoginButton(
                          maxWidth: isDesktop ? desktopMaxWidth : null,
                          onTap: () {
                            final form = _formKey.currentState;
                            if(form.validate()) {
                              form.save();
                              _signIn(context);
                            }
                          }
                      ),
                      RaisedButton(
                        child: Text('SIGN UP'),
                        onPressed: () {
                          _signUp(context);
                        },
                      ),
                    ],
                  ),
                ),
              )
          ),
        ]
    );
  }
}

class EmailField extends StatefulWidget {
  const EmailField({
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.maxWidth,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
  });

  final Key fieldKey;
  final String hintText;
  final String labelText;
  final String helperText;
  final double maxWidth;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> validator;
  final ValueChanged<String> onFieldSubmitted;

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: widget.maxWidth ?? double.infinity),
        child: TextFormField(
          key: widget.fieldKey,
          cursorColor: Theme.of(context).cursorColor,
          onSaved: widget.onSaved,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            helperText: widget.helperText,
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.maxWidth,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
  });

  final Key fieldKey;
  final String hintText;
  final String labelText;
  final String helperText;
  final double maxWidth;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> validator;
  final ValueChanged<String> onFieldSubmitted;

  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: widget.maxWidth ?? double.infinity),
        child: TextFormField(
          key: widget.fieldKey,
          obscureText: _obscureText,
          cursorColor: Theme.of(context).cursorColor,
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
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    Key key,
    @required this.onTap,
    this.maxWidth,
  }) : super(key: key);

  final double maxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            FlatButton(
              color: Theme.of(context).buttonColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: onTap,
              child: Row(
                children: [
                  Icon(Icons.lock),
                  const SizedBox(width: 6),
                  Text('SIGN IN'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ErrorMsg extends StatefulWidget {
  const ErrorMsg({
    this.key,
  });

  final Key key;

  @override
  State<ErrorMsg> createState() => _ErrorMsgState();
}

class _ErrorMsgState extends State<ErrorMsg> {
  String errorMsg = '';

  void setErrorMsg(String msg) {
    setState(() {
      errorMsg = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      errorMsg,
    );
  }
}