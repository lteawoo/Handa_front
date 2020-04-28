import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:handa/auth/auth.dart';
import 'package:handa/layout/adaptive.dart';

import 'auth/sign_in_request.dart';

class SignIn extends StatefulWidget {
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  String _validatePassword(String value) {
    if(value.isEmpty) {
      return 'Password is required.';
    }
    return null;
  }

  void _signUp(BuildContext context) {
    Navigator.of(context).pushNamed('/sign_up');
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final desktopMaxWidth = 400.0;
    final SignInRequest req = new SignInRequest();

    return Column(
        children: [
          if (isDesktop) _TopBar(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              //color: const Color(0xffff0000),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: isDesktop ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: <Widget>[
                    if (!isDesktop)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ExcludeSemantics(
                              child: SizedBox(
                                  height: 80
                              )
                          ),
                          Text(
                              'Handa',
                              style: Theme.of(context).textTheme.bodyText1.copyWith(
                                fontSize: 35,
                                fontWeight: FontWeight.w600,
                              )
                          ),
                        ],
                      ),
                    EmailField(
                      maxWidth: isDesktop ? desktopMaxWidth : null,
                      labelText: 'Email',
                      onSaved: (String value) {
                        req.email = value;
                      },
                      validator: _validateEmail,
                    ),
                    PasswordField(
                        maxWidth: isDesktop ? desktopMaxWidth : null,
                        labelText: 'Password',
                        validator: _validatePassword,
                        onSaved: (String value) {
                          req.password = value;
                        }
                    ),
                    _LoginButton(
                        maxWidth: isDesktop ? desktopMaxWidth : null,
                        onTap: () {
                          final form = _formKey.currentState;
                          if(form.validate()) {
                            form.save();
                            _onLoading();

                            final auth = AuthProvider.of(context).auth;
                            auth.signIn(req)
                                .then((response) {
                                  if(response.statusCode == 200) {
                                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                                  } else {
                                    Map<String, dynamic> data = jsonDecode(response.body);
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(data['error_description']),
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
                        }
                    ),
                    OutlineButton(
                      child: Text('Create an Account'),
                      borderSide: BorderSide.none,
                      onPressed: () {
                        _signUp(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ]
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
                semanticLabel: _obscureText ? 'on' : 'off',
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
            Expanded(child: SizedBox.shrink()),
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