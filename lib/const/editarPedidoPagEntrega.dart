import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ouroaguaegas/data/vendas_data.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controller/controller.dart';

Future<void> editarValorPagamento(context, VendasData vendaData) async {
  final Controller c = Get.put(Controller());

  Rx<MoneyMaskedTextController> valorTotal =
      MoneyMaskedTextController(initialValue: double.parse(vendaData.valorTotal.toString())).obs;
  Rx<MoneyMaskedTextController> valorPago =
      MoneyMaskedTextController(initialValue: double.parse(vendaData.valorPago.toString())).obs;

  Rx<num> valorRestante = ((vendaData.valorTotal ?? 0) - (vendaData.valorPago ?? 0)).obs;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Editar Pagamento'),
        content: Obx(
          () => SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      controller: valorTotal.value,
                      enabled: false,
                      decoration: InputDecoration(labelText: 'Valor Total', filled: true),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: valorPago.value,
                      onChanged: (value) {
                        valorRestante.value = (vendaData.valorTotal ?? 0) -
                            num.parse(value.toString().replaceAll(",", "."));
                      },
                      decoration: InputDecoration(labelText: 'Valor Pago', filled: true),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      validator: (value) => num.parse(value.toString().replaceAll(",", ".")) >
                              (valorTotal.value.numberValue)
                          ? 'Não pode ser maior que total'
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("Valor Restante: ${c.real.format(valorRestante.value)}"),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Voltar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FilledButton(
            child: const Text('Salvar'),
            onPressed: () async {
              final FormState? form = formKey.currentState;
              if (form!.validate()) {
                vendaData.valorPago = valorPago.value.numberValue;

                c.updateValorPagamento(vendaData);
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> editarPedidoPagEntrega(context, VendasData vendaData) async {
  final Controller c = Get.put(Controller());
  Rx<String?> entrega = vendaData.status.obs;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Obx(
        () => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Opções'),
              Row(
                children: [
                  Tooltip(
                    message: "WhatsApp",
                    child: IconButton(
                      onPressed: () async {
                        var tel = vendaData.cliente!.telefone
                            ?.replaceAll("(", "")
                            .replaceAll(")", "")
                            .replaceAll("-", "")
                            .replaceAll(" ", "")
                            .toString();

                        var text = "";
                        await launchUrl(Uri.parse("https://wa.me/+55$tel?text=$text"));
                      },
                      icon: FaIcon(
                        size: 17,
                        FontAwesomeIcons.whatsapp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: "Deletar",
                    child: IconButton(
                      onPressed: () async {
                        await c.deletePedido(vendaData);
                      },
                      icon: Icon(Icons.delete_outline_rounded),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                ],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4),
                  child: Text("${vendaData.cliente!.nome} - ${vendaData.cliente!.telefone}"),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
                  child: Text(
                      "${vendaData.cliente!.endereco}, ${vendaData.cliente!.numero} - ${vendaData.cliente!.bairro}"),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: Text("Valor Total: ${c.real.format(vendaData.valorTotal)}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: Text(
                            "Valor Pago: ${c.real.format(vendaData.valorPago)}",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, right: 4),
                          child: Text(
                            "Valor Restante: ${c.real.format(((vendaData.valorTotal ?? 0) - (vendaData.valorPago ?? 0)))}",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        editarValorPagamento(context, vendaData);
                      },
                      icon: Icon(Icons.attach_money_rounded),
                      color: Theme.of(context).colorScheme.primary,
                    )
                  ],
                ),
                Divider(),
                SwitchListTile(
                  dense: true,
                  title: const Text('Entregue?'),
                  value: entrega.value == "Entregue" ? true : false,
                  onChanged: (bool? value) {
                    entrega.value = value == true ? "Entregue" : "Aguardando";
                  },
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
            FilledButton(
              child: const Text('Salvar'),
              onPressed: () async {
                vendaData.status = entrega.value;

                c.updateEntrega(vendaData, entrega.value!);
              },
            ),
          ],
        ),
      );
    },
  );
}
