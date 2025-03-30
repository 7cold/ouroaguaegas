class ClienteData {
  int? id;
  String? nome;
  String? telefone;
  String? endereco;
  String? numero;
  String? bairro;
  bool? ativo;

  ClienteData({
    this.id,
    this.nome,
    this.telefone,
    this.endereco,
    this.numero,
    this.bairro,
    this.ativo,
  });

  ClienteData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    nome = json['nome'];
    telefone = json['telefone'];
    endereco = json['endereco'];
    numero = json['numero'];
    bairro = json['bairro'];
    ativo = json['ativo'] ?? true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nome'] = nome;
    data['telefone'] = telefone;
    data['endereco'] = endereco;
    data['numero'] = numero;
    data['bairro'] = bairro;
    data['ativo'] = ativo;
    return data;
  }
}
