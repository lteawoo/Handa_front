class SignUpRequest {
  String email;
  String password;

  SignUpRequest({
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