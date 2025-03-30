import 'package:ouroaguaegas/data/produtos_data.dart';

class PedidoData {
  ProdutosData? produto;
  num? qtd;

  PedidoData({
    this.produto,
    this.qtd,
  });

  PedidoData.fromJson(Map<String, dynamic> json) {
    produto = json['produto'] != null ? ProdutosData.fromJson(json['produto']) : null;
    qtd = json['quantidade'] ?? 0;
  }
}
