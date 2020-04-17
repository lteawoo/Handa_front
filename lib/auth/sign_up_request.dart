class SignUpRequest {
  String email;
  String name;
  String password;

  SignUpRequest({
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