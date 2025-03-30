class ProdutosData {
  int? id;
  String? nome;
  bool? ativo;
  num? valor;
  int? estoque;

  ProdutosData({
    this.id,
    this.nome,
    this.valor,
    this.ativo,
    this.estoque,
  });

  ProdutosData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    nome = json['nome'];
    valor = json['valor'];
    ativo = json['ativo'];
    estoque = json['estoque'];
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['id'] = id;
  //   data['ser_nome'] = nome;
  //   data['ser_valor'] = valor;
  //   data['ser_tempo'] = tempo;
  //   return data;
  // }
}
