class Cliente {
  final String name;
  final String email;
  final String cpf;
  final String rg;
  final String password;

  const Cliente({
    required this.name,
    required this.email,
    required this.cpf,
    required this.rg,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'cpf': cpf,
      'rg': rg,
      'password': password,
    };
  }
}
