import 'package:ouroaguaegas/data/clientes_data.dart';
import 'package:ouroaguaegas/data/produtos_data.dart';

class VendasData {
  int? id;
  int? idCliente;
  int? idProduto;
  ProdutosData? produto;
  ClienteData? cliente;
  String? tipoEntrega;
  num? valorVenda;
  DateTime? dataVenda;
  num? pedido;
  num? qtd;
  num? valorTotal;
  num? valorPago;
  String? status;

  VendasData({
    this.id,
    this.idCliente,
    this.idProduto,
    this.produto,
    this.cliente,
    this.tipoEntrega,
    this.valorVenda,
    this.dataVenda,
    this.pedido,
    this.qtd,
    this.valorTotal,
    this.valorPago,
    this.status,
  });

  VendasData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    idCliente = json['id_cliente'] ?? 0;
    idProduto = json['id_produto'] ?? 0;
    produto = json['produtos'] != null ? ProdutosData.fromJson(json['produtos']) : null;
    cliente = json['clientes'] != null ? ClienteData.fromJson(json['clientes']) : null;
    tipoEntrega = json['tipo_entrega'] ?? '';
    valorVenda = json['valor_venda'] ?? 0;
    pedido = json['pedido_venda']['pedido_venda'] ?? 0;
    qtd = json['quantidade'] ?? 0;
    status = json['pedido_venda']['entrega'] ?? '';
    valorTotal = json['pedido_venda']['valor_total'] ?? '';
    valorPago = json['pedido_venda']['valor_pago'] ?? '';
    dataVenda = json['data_venda'] != null ? DateTime.parse(json['data_venda']) : null;
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
