
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:handa/auth/sign_up_request.dart';
import 'package:handa/layout/adaptive.dart';

import 'auth/auth.dart';

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
      ),
    );
  }
}

class MainView extends StatefulWidget {
  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _passwordFieldKey = GlobalKey<FormFieldState>();

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: new CircularProgressIndicator(),
        );
      }
    );
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
    final desktopMaxWidth = 400.0;
    SignUpRequest req = new SignUpRequest();

    return Column(
      children: [
        _TopBar(),
        Expanded(
          child: Container(
           //color: const Color(0xffff0000),
            child: Scrollbar(
              child: SingleChildScrollView(
                dragStartBehavior: DragStartBehavior.down,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: isDesktop ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        maxWidth: isDesktop ? desktopMaxWidth : null,
                        labelText: 'Email *',
                        icon: Icons.email,
                        onSaved: (value) {
                          req.email = value;
                        },
                        validator: _validateEmail,
                      ),
                      TextField(
                        maxWidth: isDesktop ? desktopMaxWidth : null,
                        labelText: 'Name *',
                        icon: Icons.people,
                        onSaved: (value) {
                          req.name = value;
                        },
                        validator: _validateName,
                      ),
                      PasswordField(
                        maxWidth: isDesktop ? desktopMaxWidth : null,
                        fieldKey: _passwordFieldKey,
                        labelText: 'Password *',
                        helperText: '8자리 이상 12자리 이하',
                        onSaved: (value) {
                          req.password = value;
                        },
                      ),
                      TextField(
                        maxWidth: isDesktop ? desktopMaxWidth : null,
                        labelText: 'Re-type password *',
                        validator: _validatePassword,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: isDesktop ? desktopMaxWidth : double.infinity),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: <Widget>[
                              RaisedButton(
                                child: Text('Back'),
                                onPressed: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil('/sign_in', (Route<dynamic> route) => false);
                                },
                              ),
                              Expanded(child:SizedBox.shrink()),
                              RaisedButton(
                                child: Text('SIGN UP'),
                                onPressed: () {
                                  if(_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    _onLoading();

                                    final auth = AuthProvider.of(context).auth;
                                    auth.signUp(req)
                                        .then((response) {
                                          if(response.statusCode == 200) {
                                            Navigator.of(context).pushNamedAndRemoveUntil('/sign_in', (Route<dynamic> route) => false);
                                          } else {
                                            Map<String, dynamic> data = jsonDecode(response.body);
                                            Scaffold.of(context).showSnackBar(SnackBar(
                                              content: Text(data['message']),
                                            ));
                                            Navigator.of(context).pop();
                                          }
                                        })
                                        .catchError((error) {
                                          Scaffold.of(context).showSnackBar(SnackBar(
                                            content: Text('잠시 후 다시 시도해 주세요.'),
                                          ));
                                          Navigator.of(context).pop();
                                        });
                                  }
                                },
                              ),
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(width: 30);
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                      child: SizedBox(
                          height: 80
                      )
                  ),
                  spacing,
                  Text(
                      'Handa',
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                ],
              ),
            ]
        )
    );
  }
}

class TextField extends StatefulWidget {
  const TextField({
    this.fieldKey,
    this.obscureText,
    this.icon,
    this.hintText,
    this.labelText,
    this.helperText,
    this.maxWidth,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
  });

  final Key fieldKey;
  final bool obscureText;
  final IconData icon;
  final String hintText;
  final String labelText;
  final String helperText;
  final double maxWidth;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> validator;
  final ValueChanged<String> onFieldSubmitted;

  @override
  State<TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<TextField> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: widget.maxWidth ?? double.infinity),
        child: TextFormField(
          key: widget.fieldKey,
          obscureText: widget.obscureText == null ? false : widget.obscureText,
          cursorColor: Theme.of(context).cursorColor,
          onSaved: widget.onSaved,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            filled: true,
            icon: Icon(widget.icon),
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
                semanticLabel: _obscureText ? 'on' : 'off',
              ),
            ),
          ),
        ),
      ),
    );
  }
}