class CpagarData {
  int? id;
  String? nome;
  String? descricao;
  num? valor;
  DateTime? data;
  bool? pago;
  bool? fixo;

  CpagarData({
    this.id,
    this.nome,
    this.descricao,
    this.valor,
    this.data,
    this.pago,
    this.fixo,
  });

  CpagarData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    nome = json['nome'];
    valor = json['valor'];
    descricao = json['descricao'];
    pago = json['pago'];
    fixo = json['fixo'];
    data = DateTime.parse(json['data']);
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['id'] = id;
  //   data['nome'] = nome;
  //   data['telefone'] = telefone;
  //   data['dt_nascimento'] = dtNasc;
  //   return data;
  // }
}
