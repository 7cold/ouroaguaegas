import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ouroaguaegas/const/createVendas.dart';
import 'package:ouroaguaegas/const/editarPedidoPagEntrega.dart';
import 'package:ouroaguaegas/data/clientes_data.dart';
import 'package:responsive_ui/responsive_ui.dart';
import '../controller/controller.dart';

class VendasUiClientes extends StatelessWidget {
  final Controller c = Get.put(Controller());
  ClienteData clienteData = Get.arguments;

  @override
  Widget build(BuildContext context) {
    Rxn<DateTime> data = Rxn(DateTime(DateTime.now().year, DateTime.now().month, 1));
    return Obx(() {
      var agrupado = groupBy(
          c.vendas.where((p0) => p0.cliente!.id == clienteData.id), (venda) => venda.pedido);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Vendas por Cliente'),
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
            : Flex(
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
                          child: Column(
                            children: agrupado.entries.map((entry) {
                              // var pedidoId = entry.key;
                              var vendasPorPedido = entry.value;
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    editarPedidoPagEntrega(context, vendasPorPedido.first);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  context.width > 450
                                                      ? Text(
                                                          vendasPorPedido.first.cliente!.nome
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: Get.theme.colorScheme.primary,
                                                              fontWeight: FontWeight.bold),
                                                        )
                                                      : Text(
                                                          vendasPorPedido.first.cliente!.nome
                                                                      .toString()
                                                                      .length <=
                                                                  16
                                                              ? vendasPorPedido.first.cliente!.nome
                                                                  .toString()
                                                              : "${vendasPorPedido.first.cliente!.nome.toString().substring(0, 16)}...",
                                                          overflow: TextOverflow.fade,
                                                          style: TextStyle(
                                                              color: Get.theme.colorScheme.primary,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                  Text(
                                                    c.dateFormatterSimple.format(
                                                        vendasPorPedido.first.dataVenda ??
                                                            DateTime.now()),
                                                    style: TextStyle(
                                                        color: Get.theme.colorScheme.primary),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Tooltip(
                                                    message: vendasPorPedido.first.tipoEntrega ==
                                                            "Entrega"
                                                        ? "Entrega"
                                                        : "Retirada",
                                                    child: Icon(
                                                      vendasPorPedido.first.tipoEntrega == "Entrega"
                                                          ? Icons.local_shipping_outlined
                                                          : Icons.transfer_within_a_station_rounded,
                                                      size: 18,
                                                      color: Get.theme.colorScheme.primary,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Tooltip(
                                                    message: vendasPorPedido.first.valorPago ==
                                                            vendasPorPedido.first.valorTotal
                                                        ? "Pago"
                                                        : "Pendente",
                                                    child: Icon(
                                                      vendasPorPedido.first.valorPago ==
                                                              vendasPorPedido.first.valorTotal
                                                          ? Icons.attach_money_rounded
                                                          : Icons.money_off,
                                                      size: 18,
                                                      color: vendasPorPedido.first.valorPago ==
                                                              vendasPorPedido.first.valorTotal
                                                          ? Colors.green
                                                          : Colors.deepOrange,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Chip(
                                                    color: MaterialStateProperty.all(
                                                      vendasPorPedido.first.status == "Entregue"
                                                          ? Colors.green.shade100
                                                          : Colors.orange.shade100,
                                                    ),
                                                    label: Text(
                                                      vendasPorPedido.first.status ?? "",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: vendasPorPedido.first.status ==
                                                                  "Entregue"
                                                              ? Colors.green.shade800
                                                              : Colors.deepOrange),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(),
                                        Column(
                                          children: vendasPorPedido.map((venda) {
                                            return ListTile(
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
                                                c.real
                                                    .format(venda.produto!.valor! * venda.qtd!)
                                                    .toString(),
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        Divider(),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    size: 18,
                                                    Icons.monetization_on,
                                                    color: Colors.black54,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                      c.real
                                                          .format(vendasPorPedido.first.valorTotal),
                                                      style: TextStyle(
                                                          color: Get.theme.primaryColor,
                                                          fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                              SizedBox(width: 10),
                                              Row(
                                                children: [
                                                  Icon(
                                                    size: 18,
                                                    Icons.attach_money_outlined,
                                                    color: Colors.green,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                      c.real
                                                          .format(vendasPorPedido.first.valorPago),
                                                      style: TextStyle(
                                                          color: Get.theme.primaryColor,
                                                          fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                              SizedBox(width: 10),
                                              Row(
                                                children: [
                                                  Tooltip(
                                                    message: vendasPorPedido.first.valorPago ==
                                                            vendasPorPedido.first.valorTotal
                                                        ? "Pago"
                                                        : "Pendente",
                                                    child: Icon(
                                                      size: 18,
                                                      vendasPorPedido.first.valorPago ==
                                                              vendasPorPedido.first.valorTotal
                                                          ? Icons.attach_money_rounded
                                                          : Icons.money_off,
                                                      color: vendasPorPedido.first.valorPago ==
                                                              vendasPorPedido.first.valorTotal
                                                          ? Colors.black54
                                                          : Colors.deepOrange,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    c.real.format(
                                                        (vendasPorPedido.first.valorTotal ?? 0) -
                                                            (vendasPorPedido.first.valorPago ?? 0)),
                                                    style: TextStyle(
                                                        color: Get.theme.primaryColor,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
