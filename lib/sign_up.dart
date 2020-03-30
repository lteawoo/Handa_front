
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
          child: MainView(),
        )
    );
  }
}

class MainView extends StatefulWidget {
  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final Member member = Member();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _passwordFieldKey = GlobalKey<FormFieldState>();

  void _signUp(BuildContext context) async {
    if(!_formKey.currentState.validate()) {
      return;
    }

    String uri = "http://localhost:8080/member/signup";
    String body = json.encode(member);
    debugPrint(body);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': "application/json;charset=UTF-8",
        'Accept': "application/json;charset=UTF-8",
      },
      body: body,
    ).catchError((error) {
      debugPrint(error.toString());
      throw error;
    }).then((response) {
      Map responseMap = jsonDecode(response.body);

      debugPrint(response.statusCode.toString());

      if(response.statusCode == 200) {
        Navigator.of(context).pop();
      } else {
        //_errorMsgKey.currentState.setErrorMsg(response.statusCode.toString() + ', ' + responseMap['error'] + ': ' + responseMap['error_description']);
        debugPrint(responseMap.toString());
      }
    });
  }

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
    final passwordField = _passwordFieldKey.currentState;
    if(passwordField.value == null || passwordField.value.toString().isEmpty) {
      return 'Password is required.';
    }
    if(passwordField.value.toString() != value) {
      return 'Password don`t match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    debugPrint(isDesktop.toString());
    final desktopMaxWidth = 400.0;

    return Scrollbar(
      child: SingleChildScrollView(
        dragStartBehavior: DragStartBehavior.down,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: isDesktop ? Alignment.center : Alignment.topCenter,
          child: Form(
            key: _formKey,
            child: Container(
              constraints: BoxConstraints(maxWidth: isDesktop ? desktopMaxWidth : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      icon: Icon(Icons.email),
                      labelText: 'Email *',
                    ),
                    onSaved: (value) {
                      member.email = value;
                    },
                    validator: _validateEmail,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      icon: Icon(Icons.people),
                      labelText: 'Name *',
                    ),
                    onSaved: (value) {
                      member.name = value;
                    },
                    validator: _validateName,
                  ),
                  PasswordField(
                    fieldKey: _passwordFieldKey,
                    labelText: 'Password *',
                    helperText: '8자리 이상 12자리 이하',
                    onSaved: (value) {
                      member.password = value;
                    },
/*                    onFieldSubmitted: (value) {
                      setState(() {
                        member.password = value;
                      });
                    },*/
                  ),
                  TextFormField(
                    obscureText: true,
                    maxLength: 12,
                    decoration: InputDecoration(
                      filled: true,
                      icon: Icon(null),
                      labelText: 'Re-type password *',
                    ),
                    validator: _validatePassword,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child:SizedBox.shrink()),
                      RaisedButton(
                        child: Text('SIGN UP'),
                        onPressed: () {
                          if(_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            _signUp(context);
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
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
            filled: true,
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
          maxLength: 12,
          cursorColor: Theme.of(context).cursorColor,
          onSaved: widget.onSaved,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            filled: true,
            icon: Icon(Icons.lock),
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