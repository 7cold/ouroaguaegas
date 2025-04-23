import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:ouroaguaegas/const/createVendas.dart';
import 'package:ouroaguaegas/data/vendas_data.dart';
import 'package:responsive_ui/responsive_ui.dart';
import '../controller/controller.dart';
import 'dart:async';

class VendasUiEntregas extends StatelessWidget {
  final Controller c = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var agrupado = groupBy(
          c.vendas.where((p0) => p0.status == "Aguardando").toList(), (venda) => venda.pedido);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Aguardando Entrega'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                  onPressed: () {
                    createVendasDialog(context);
                  },
                  icon: Icon(Icons.add)),
            ),
          ],
        ),
        body: c.loading.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      child: Div(
                        divison: Division(colXL: 5),
                        child: Container(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          margin: const EdgeInsets.only(
                            right: 20,
                            left: 20,
                            bottom: 20,
                            top: 10,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SingleChildScrollView(
                            child: agrupado.entries.isEmpty
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height / 1.2,
                                    child: Center(
                                      child: Text("Nenhum pedido aguardando entrega"),
                                    ),
                                  )
                                : Column(
                                    children: agrupado.entries.map((entry) {
                                      // var pedidoId = entry.key;
                                      List<VendasData> vendasPorPedido = entry.value;
                                      return CardAguardandoEntrega(
                                          vendasPorPedido: vendasPorPedido.first,
                                          vendasPorPedidos: vendasPorPedido);

                                      // Card(
                                      //   clipBehavior: Clip.antiAlias,
                                      //   child: InkWell(
                                      //     onTap: () {
                                      //       editarPedidoPagEntrega(context, vendasPorPedido.first);
                                      //     },
                                      //     child: Padding(
                                      //       padding: const EdgeInsets.all(8.0),
                                      //       child: Column(
                                      //         mainAxisAlignment: MainAxisAlignment.start,
                                      //         crossAxisAlignment: CrossAxisAlignment.start,
                                      //         children: [
                                      //           Container(
                                      //             padding: EdgeInsets.symmetric(horizontal: 10),
                                      //             child: Row(
                                      //               crossAxisAlignment: CrossAxisAlignment.center,
                                      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //               children: [
                                      //                 Column(
                                      //                   mainAxisAlignment: MainAxisAlignment.start,
                                      //                   crossAxisAlignment: CrossAxisAlignment.start,
                                      //                   children: [
                                      //                     Text(
                                      //                       vendasPorPedido.first.cliente!.nome
                                      //                           .toString(),
                                      //                       style: TextStyle(
                                      //                           color: Get.theme.colorScheme.primary,
                                      //                           fontWeight: FontWeight.bold),
                                      //                     ),
                                      //                     Text(
                                      //                       c.dateFormatterSimple.format(
                                      //                           vendasPorPedido.first.dataVenda ??
                                      //                               DateTime.now()),
                                      //                       style: TextStyle(
                                      //                           color: Get.theme.colorScheme.primary),
                                      //                     ),
                                      //                   ],
                                      //                 ),
                                      //                 Row(
                                      //                   children: [
                                      //                     Tooltip(
                                      //                       message: vendasPorPedido.first.tipoEntrega ==
                                      //                               "Entrega"
                                      //                           ? "Entrega"
                                      //                           : "Retirada",
                                      //                       child: Icon(
                                      //                         vendasPorPedido.first.tipoEntrega ==
                                      //                                 "Entrega"
                                      //                             ? Icons.local_shipping_outlined
                                      //                             : Icons
                                      //                                 .transfer_within_a_station_rounded,
                                      //                         size: 18,
                                      //                         color: Get.theme.colorScheme.primary,
                                      //                       ),
                                      //                     ),
                                      //                     SizedBox(width: 5),
                                      //                     Tooltip(
                                      //                       message: vendasPorPedido.first.valorPago ==
                                      //                               vendasPorPedido.first.valorTotal
                                      //                           ? "Pago"
                                      //                           : "Pendente",
                                      //                       child: Icon(
                                      //                         vendasPorPedido.first.valorPago ==
                                      //                                 vendasPorPedido.first.valorTotal
                                      //                             ? Icons.attach_money_rounded
                                      //                             : Icons.money_off,
                                      //                         size: 18,
                                      //                         color: vendasPorPedido.first.valorPago ==
                                      //                                 vendasPorPedido.first.valorTotal
                                      //                             ? Colors.green
                                      //                             : Colors.deepOrange,
                                      //                       ),
                                      //                     ),
                                      //                     SizedBox(width: 5),
                                      //                     Chip(
                                      //                       color: MaterialStateProperty.all(
                                      //                         vendasPorPedido.first.status == "Entregue"
                                      //                             ? Colors.green.shade100
                                      //                             : Colors.orange.shade100,
                                      //                       ),
                                      //                       label: Text(
                                      //                         vendasPorPedido.first.status ?? "",
                                      //                         style: TextStyle(
                                      //                             fontSize: 12,
                                      //                             color: vendasPorPedido.first.status ==
                                      //                                     "Entregue"
                                      //                                 ? Colors.green.shade800
                                      //                                 : Colors.deepOrange),
                                      //                       ),
                                      //                     ),
                                      //                   ],
                                      //                 ),
                                      //               ],
                                      //             ),
                                      //           ),
                                      //           Divider(),
                                      //           Column(
                                      //             children: vendasPorPedido.map((venda) {
                                      //               return ListTile(
                                      //                 dense: true,
                                      //                 enableFeedback: true,
                                      //                 title: Text(
                                      //                   venda.produto!.nome.toString(),
                                      //                   style: TextStyle(fontSize: 13),
                                      //                 ),
                                      //                 subtitle: Text(
                                      //                   "${venda.qtd} x ${c.real.format(venda.produto!.valor)}",
                                      //                   style: TextStyle(fontSize: 13),
                                      //                 ),
                                      //                 trailing: Text(
                                      //                   c.real
                                      //                       .format(venda.produto!.valor! * venda.qtd!)
                                      //                       .toString(),
                                      //                   style: TextStyle(fontSize: 12),
                                      //                 ),
                                      //               );
                                      //             }).toList(),
                                      //           ),
                                      //           Divider(),
                                      //           Container(
                                      //             padding: EdgeInsets.symmetric(horizontal: 10),
                                      //             width: double.infinity,
                                      //             child: Row(
                                      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //               children: [
                                      //                 Row(
                                      //                   children: [
                                      //                     Icon(
                                      //                       size: 18,
                                      //                       Icons.monetization_on,
                                      //                       color: Colors.black54,
                                      //                     ),
                                      //                     SizedBox(width: 5),
                                      //                     Text(
                                      //                         c.real.format(
                                      //                             vendasPorPedido.first.valorTotal),
                                      //                         style: TextStyle(
                                      //                             color: Get.theme.primaryColor,
                                      //                             fontWeight: FontWeight.bold)),
                                      //                   ],
                                      //                 ),
                                      //                 SizedBox(width: 10),
                                      //                 Row(
                                      //                   children: [
                                      //                     Icon(
                                      //                       size: 18,
                                      //                       Icons.attach_money_outlined,
                                      //                       color: Colors.green,
                                      //                     ),
                                      //                     SizedBox(width: 5),
                                      //                     Text(
                                      //                         c.real.format(
                                      //                             vendasPorPedido.first.valorPago),
                                      //                         style: TextStyle(
                                      //                             color: Get.theme.primaryColor,
                                      //                             fontWeight: FontWeight.bold)),
                                      //                   ],
                                      //                 ),
                                      //                 SizedBox(width: 10),
                                      //                 Row(
                                      //                   children: [
                                      //                     Tooltip(
                                      //                       message: vendasPorPedido.first.valorPago ==
                                      //                               vendasPorPedido.first.valorTotal
                                      //                           ? "Pago"
                                      //                           : "Pendente",
                                      //                       child: Icon(
                                      //                         size: 18,
                                      //                         vendasPorPedido.first.valorPago ==
                                      //                                 vendasPorPedido.first.valorTotal
                                      //                             ? Icons.attach_money_rounded
                                      //                             : Icons.money_off,
                                      //                         color: vendasPorPedido.first.valorPago ==
                                      //                                 vendasPorPedido.first.valorTotal
                                      //                             ? Colors.black54
                                      //                             : Colors.deepOrange,
                                      //                       ),
                                      //                     ),
                                      //                     SizedBox(width: 5),
                                      //                     Text(
                                      //                       c.real.format(
                                      //                           (vendasPorPedido.first.valorTotal ?? 0) -
                                      //                               (vendasPorPedido.first.valorPago ??
                                      //                                   0)),
                                      //                       style: TextStyle(
                                      //                           color: Get.theme.primaryColor,
                                      //                           fontWeight: FontWeight.bold),
                                      //                     ),
                                      //                   ],
                                      //                 ),
                                      //               ],
                                      //             ),
                                      //           )
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ),
                                      // );
                                    }).toList(),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}

class CardAguardandoEntrega extends StatefulWidget {
  final VendasData vendasPorPedido;
  final List<VendasData> vendasPorPedidos;

  CardAguardandoEntrega({required this.vendasPorPedido, required this.vendasPorPedidos});

  @override
  State<CardAguardandoEntrega> createState() => _CardAguardandoEntregaState();
}

class _CardAguardandoEntregaState extends State<CardAguardandoEntrega> {
  Rx<Timer>? timer;
  final Controller c = Get.put(Controller());
  Rx<Duration>? diferanca = Rx<Duration>(Duration(seconds: 0));

  void _iniciarTimer() {
    timer = Rx<Timer>(
      Timer.periodic(
        Duration(seconds: 1),
        (timer) {
          setState(() {
            diferanca!.value = DateTime.now().difference(widget.vendasPorPedido.dataVenda!);
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    timer?.value.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _iniciarTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  widget.vendasPorPedido.status = "Entregue";
                  await c.updateEntrega(widget.vendasPorPedido, "Entregue");
                },
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                icon: Icons.check,
                label: 'Entregue',
              ),
            ],
          ),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  widget.vendasPorPedido.valorPago = widget.vendasPorPedido.valorTotal;
                  widget.vendasPorPedido.status = "Entregue";

                  c.updateValorPagamento(widget.vendasPorPedido);
                },
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.check,
                label: 'Entregue e Pago',
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              detalhes(context, widget.vendasPorPedido, c, widget.vendasPorPedidos);
            },
            child: ListTile(
              leading: diferanca!.value.inHours == 0 && diferanca!.value.inMinutes == 0
                  ? SizedBox(
                      height: 10,
                      width: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ))
                  : Badge(
                      label: Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                            diferanca!.value.inHours < 1
                                ? "${diferanca!.value.inMinutes} m"
                                : "${diferanca!.value.inHours} h",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                      ),
                    ),
              title: Text(widget.vendasPorPedido.cliente!.nome.toString()),
              subtitle: Text(
                  "${widget.vendasPorPedido.cliente!.endereco} , ${widget.vendasPorPedido.cliente!.numero} - ${widget.vendasPorPedido.cliente!.bairro}"),
              trailing: Text(c.real.format(widget.vendasPorPedido.valorVenda)),
            ),
          )),
    );
  }
}

Future<void> detalhes(
    context, VendasData vendaData, Controller c, List<VendasData> vendasPorPedidos) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Detalhes do Pedido'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Column(
                children: vendasPorPedidos.map((venda) {
                  return Card(
                    child: ListTile(
                      dense: true,
                      enableFeedback: true,
                      title: Text(
                        venda.produto!.nome.toString(),
                        style: TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        "${venda.qtd} x ${c.real.format(venda.produto!.valor)}",
                        style: TextStyle(fontSize: 13),
                      ),
                      trailing: Text(
                        c.real.format(venda.produto!.valor! * venda.qtd!).toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Voltar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
