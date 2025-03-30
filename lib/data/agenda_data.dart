class AgendaData {
  int? id;
  int? idCliente;
  String? nomeCliente;
  int? idServico;
  String? nomeServico;
  int? corServico;
  num? valorServico;
  num? valorPago;
  int? tempoServico;
  DateTime? dtAgenda;
  DateTime? hrInicio;
  DateTime? hrFim;
  String? status;
  String? obsPacote;
  String? obs;

  AgendaData({
    this.id,
    this.idCliente,
    this.nomeCliente,
    this.corServico,
    this.idServico,
    this.valorServico,
    this.valorPago,
    this.tempoServico,
    this.nomeServico,
    this.dtAgenda,
    this.hrFim,
    this.hrInicio,
    this.status,
    this.obsPacote,
    this.obs,
  });

  AgendaData.fromJson(Map<String, dynamic> json) {
    id = json['id_agenda'] ?? 0;
    idCliente = json['id_cliente'];
    nomeCliente = json['clientes']['nome'];
    idServico = json['id_servico'];
    corServico = int.parse(json['servicos']['ser_cor']);
    nomeServico = json['servicos']['ser_nome'];
    tempoServico = json['servicos']['ser_tempo'];
    valorServico = json['valor_servico'];
    valorPago = json['valor_pago'];
    status = json['status'];
    obsPacote = json['obs_pacote'];
    obs = json['obs'];
    dtAgenda = DateTime.parse(json['dt_agenda']);
    hrInicio = DateTime.parse(json['dt_agenda']);
    hrFim = DateTime.parse(json['dt_agenda']).add(Duration(minutes: json['servicos']['ser_tempo']));
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['id_agenda'] = id;
  //   data['id_cliente'] = idCliente;
  //   data['nome'] = nomeCliente;
  //   data['id_servico'] = idServico;
  //   data['dt_agenda'] = dtAgenda;
  //   data['dt_agenda'] = hrInicio;
  //   data['dt_agenda'] = hrFim;
  //   return data;
  // }
}
