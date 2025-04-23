import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ouroaguaegas/data/clientes_data.dart';
import 'package:ouroaguaegas/data/pedido_data.dart';
import 'package:ouroaguaegas/data/produtos_data.dart';
import 'package:ouroaguaegas/data/vendas_data.dart';
import '../controller/controller.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';

Future<void> createVendasDialog(context) async {
  final Controller c = Get.put(Controller());
  Rx<ClienteData?> clienteSelect = Rx(null);
  RxList<ProdutosData?> produtosSelect = <ProdutosData>[].obs;
  RxList<PedidoData?> listapedido = <PedidoData>[].obs;
  RxString tipoEntrega = "Entrega".obs;
  RxDouble soma = 0.0.obs;

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return Obx(
        () => AlertDialog(
          title: Text('Nova Venda'),
          content: c.loading.value == true
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: ListBody(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: DropDownSearchField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: TextEditingController(text: clienteSelect.value?.nome),
                            decoration: const InputDecoration(hintText: "Cliente", filled: true),
                          ),
                          suggestionsCallback: (pattern) async {
                            return c.clientes
                                .where((p0) => p0.ativo == true)
                                .where((ClienteData option) {
                              return option.nome
                                  .toString()
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase());
                            });
                          },
                          itemBuilder: (context, data) {
                            return ListTile(
                              title: Text(data.nome ?? ""),
                              subtitle: Text("${data.endereco} - ${data.numero} - ${data.bairro}"),
                            );
                          },
                          onSuggestionSelected: (data) {
                            clienteSelect.value = data;
                          },
                          displayAllSuggestionWhenTap: true,
                          isMultiSelectDropdown: false,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: MultiSelectDropdownSearchFormField(
                          dropdownBoxConfiguration: DropdownBoxConfiguration(
                            decoration: const InputDecoration(
                              filled: true,
                              hintText: "Produtos",
                            ),
                          ),
                          textFieldConfiguration: TextFieldConfiguration(
                            decoration: const InputDecoration(
                              hintText: "Pesquisar",
                              filled: true,
                            ),
                          ),
                          suggestionsCallback: (pattern) async {
                            return c.produtos
                                .where((p0) => p0.ativo == true)
                                .where((ProdutosData option) {
                              return option.nome
                                  .toString()
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase());
                            });
                          },
                          itemBuilder: (context, data) {
                            if ((data!.estoque ?? 0) <= 0) {
                              return ListTile(
                                title: Text(data.nome ?? ""),
                                subtitle: Text(
                                  "Sem estoque",
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            return ListTile(
                              title: Text(data.nome ?? ""),
                              subtitle: Text(c.real.format(data.valor)),
                            );
                          },
                          displayAllSuggestionWhenTap: false,
                          initiallySelectedItems: produtosSelect,
                          onMultiSuggestionSelected: (suggestion, bool isSelected) {
                            if ((suggestion?.estoque ?? 0) <= 0) {
                              return;
                            } else {
                              if (isSelected) {
                                listapedido.add(PedidoData(produto: suggestion, qtd: 1));
                                produtosSelect.add(suggestion);
                              } else {
                                listapedido.removeWhere(
                                    (element) => element?.produto?.id == suggestion?.id);
                                produtosSelect.remove(suggestion);
                              }
                              soma.value = listapedido.fold(
                                  0.0,
                                  (acc, mapa) =>
                                      acc + ((mapa?.produto?.valor ?? 0) * (mapa!.qtd ?? 0)));
                            }
                          },
                          chipBuilder: (BuildContext context, itemData) {
                            return Chip(
                              label: Text(itemData?.nome ?? ""),
                            );
                          },
                        ),
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: RadioListTile(
                                dense: true,
                                title: Tooltip(
                                    message: 'Entrega',
                                    child: Column(
                                      children: [
                                        Icon(Icons.motorcycle_outlined),
                                        Text("Entrega", style: TextStyle(fontSize: 11)),
                                      ],
                                    )),
                                value: tipoEntrega.value == "Entrega" ? 1 : 0,
                                selected: tipoEntrega.value == "Entrega" ? true : false,
                                groupValue: 1,
                                onChanged: (_) {
                                  tipoEntrega.value = "Entrega";
                                }),
                          ),
                          Expanded(
                            child: RadioListTile(
                                dense: true,
                                title: Tooltip(
                                    message: 'Retirada',
                                    child: Column(
                                      children: [
                                        Icon(Icons.transfer_within_a_station_outlined),
                                        Text("Retirada", style: TextStyle(fontSize: 11)),
                                      ],
                                    )),
                                value: tipoEntrega.value != "Entrega" ? 1 : 0,
                                selected: tipoEntrega.value != "Entrega" ? true : false,
                                groupValue: 1,
                                onChanged: (_) {
                                  tipoEntrega.value = "Retirada";
                                }),
                          ),
                        ],
                      ),
                      Column(
                        children: listapedido.map((p) {
                          return ListTile(
                            title: Text(p?.produto?.nome ?? "", style: TextStyle(fontSize: 14.5)),
                            subtitle: Text("R\$${c.real.format(p?.produto?.valor)}"),
                            trailing: Wrap(
                              alignment: WrapAlignment.end,
                              crossAxisAlignment: WrapCrossAlignment.end,
                              runAlignment: WrapAlignment.end,
                              direction: Axis.horizontal,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      if (p?.qtd == 1) {
                                      } else {
                                        p?.qtd = p.qtd! - 1;
                                        listapedido.refresh();
                                      }
                                      soma.value = listapedido.fold(
                                          0.0,
                                          (acc, mapa) =>
                                              acc +
                                              ((mapa?.produto?.valor ?? 0) * (mapa!.qtd ?? 0)));
                                    },
                                    icon: Icon(Icons.remove)),
                                Chip(label: Text(p?.qtd.toString() ?? "")),
                                IconButton(
                                    onPressed: p?.qtd == p?.produto?.estoque
                                        ? null
                                        : () {
                                            p?.qtd = p.qtd! + 1;
                                            listapedido.refresh();
                                            soma.value = listapedido.fold(
                                                0.0,
                                                (acc, mapa) =>
                                                    acc +
                                                    ((mapa?.produto?.valor ?? 0) *
                                                        (mapa!.qtd ?? 0)));
                                          },
                                    icon: Icon(Icons.add)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Valor Total: R\$${c.real.format(soma.value)}",
                          style: Get.theme.textTheme.titleMedium,
                        ),
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
              onPressed: produtosSelect.isEmpty || clienteSelect.value == null
                  ? null
                  : () async {
                      pagamento(String modo) async {
                        num numpedido = DateTime.now().millisecondsSinceEpoch;

                        await c.supabase.from('pedido_venda').insert({
                          "pedido_venda": numpedido,
                          "entrega": modo == "entregue e pago"
                              ? "Entregue"
                              : modo == "entregue"
                                  ? "Entregue"
                                  : "Aguardando",
                          "valor_total": soma.value,
                          "valor_pago": modo == "entregue e pago" ? soma.value : 0,
                        }).select();

                        for (var produto in produtosSelect) {
                          await c.createVenda(VendasData(
                            cliente: clienteSelect.value,
                            tipoEntrega: tipoEntrega.value,
                            valorVenda: soma.value,
                            dataVenda: DateTime.now().toUtc(),
                            pedido: numpedido,
                            idCliente: clienteSelect.value?.id,
                            idProduto: produto?.id,
                            produto: produto,
                            status: modo == "entregue e pago"
                                ? "Entregue"
                                : modo == "entregue"
                                    ? "Entregue"
                                    : "Aguardando",
                            valorTotal: soma.value,
                            valorPago: modo == "entregue e pago" ? soma.value : 0,
                            qtd: listapedido
                                .firstWhere((element) => element?.produto?.id == produto?.id)
                                ?.qtd,
                          ));

                          produto?.estoque = produto.estoque! -
                              int.parse(listapedido
                                  .firstWhere((element) => element?.produto?.id == produto.id)!
                                  .qtd
                                  .toString());

                          await c.updateEstoque(produto!, false);
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }

                      return showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Modo de Salvamento'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [
                                  FilledButton.tonal(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.green),
                                    ),
                                    child: const Text('Entregue e Pago',
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      pagamento("entregue e pago");
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  FilledButton.tonal(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                                    ),
                                    child: const Text(
                                      'Entregue',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      pagamento("entregue");
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  FilledButton.tonal(
                                    child: const Text('Modo Normal'),
                                    onPressed: () async {
                                      pagamento("normal");
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
                            ],
                          );
                        },
                      );
                    },
              child: const Text('Salvar'),
            ),
          ],
        ),
      );
    },
  );
}
