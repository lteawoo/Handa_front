class SignInRequest {
  String email;
  String password;

  SignInRequest({
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