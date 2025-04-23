import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ouroaguaegas/const/relatorioCliente.dart';
import 'package:ouroaguaegas/data/clientes_data.dart';
import 'package:ouroaguaegas/data/vendas_data.dart';
import 'package:ouroaguaegas/print/relatorioVendas.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../controller/controller.dart';
import 'package:dartx/dartx.dart';

class RelatoriosUi extends StatelessWidget {
  final Controller c = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Relatórios'),
        ),
        body: c.loading.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      title: Text('Relatório de Vendas por Cliente'),
                      onTap: () {
                        selectCliente(context);
                      },
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      title: Text('Relatório de Vendas por Produto'),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      title: Text('Relatório de Vendas Mensal'),
                      onTap: () {},
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      title: Text('Relatório de Vendas Anual'),
                      onTap: () {},
                    ),
                  ),
                ],
              ));
  }
}

final Controller cx = Get.put(Controller());

class DetalhesRelatorio extends StatelessWidget {
  asc(DataSource d) {
    DataSource customSortingDataGridSource;
    customSortingDataGridSource = DataSource();

    customSortingDataGridSource.addColumnGroup(ColumnGroup(name: 'ID', sortGroupRows: true));
    return customSortingDataGridSource;
  }

  Future<void> pagamento(context, ClienteData cliente) async {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    Rx<MoneyMaskedTextController> valorAbertoC = MoneyMaskedTextController().obs;
    Rx<MoneyMaskedTextController> valorPagamentoC = MoneyMaskedTextController().obs;

    Rx<num> valorPago = cx.vendas
        .distinctBy((v) => v.pedido)
        .where((v) => v.cliente?.id == cliente.id)
        .fold(0.0, (acc, mapa) => acc + ((mapa.valorPago) ?? 0))
        .obs;

    Rx<num?> totalCliente =
        cx.vendas.distinctBy((v) => v.pedido).where((v) => v.cliente?.id == cliente.id).isEmpty
            ? 0.obs
            : cx.vendas
                .distinctBy((v) => v.pedido)
                .where((v) => v.cliente?.id == cliente.id)
                .map((venda) => venda.valorTotal)
                .toList()
                .reduce((a, b) => (a ?? 0) + (b ?? 0))
                .obs;

    Rx<num> valorAberto = ((totalCliente.value ?? 0) -
            cx.vendas
                .distinctBy((v) => v.pedido)
                .where((v) => v.cliente?.id == cliente.id)
                .fold(0.0, (acc, mapa) => acc + ((mapa.valorPago) ?? 0)))
        .obs;

    valorAbertoC.value.updateValue(valorAberto.value.toDouble());

    Rx<num> valorRestante = ((valorAberto.value) - (valorPagamentoC.value.numberValue)).obs;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Obx(
          () => AlertDialog(
            title: Text('Pagamento'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Form(
                    key: formKey,
                    child: ListBody(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextField(
                            controller: valorAbertoC.value,
                            enabled: false,
                            decoration: InputDecoration(labelText: 'Valor em Aberto', filled: true),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextFormField(
                            controller: valorPagamentoC.value,
                            onChanged: (value) {
                              valorRestante.value = (valorAbertoC.value.numberValue) -
                                  valorPagamentoC.value.numberValue;
                            },
                            decoration: InputDecoration(labelText: 'Valor Pago', filled: true),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              valorPagamentoC.refresh();
                              return valorPagamentoC.value.numberValue > (valorAberto.value)
                                  ? 'Não pode ser maior que total aberto'
                                  : null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("Valor Restante: ${cx.real.format(valorRestante.value)}"),
                        ),
                      ],
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
                onPressed: () async {
                  final FormState? form = formKey.currentState;
                  if (form!.validate()) {
                    num vlrpago = valorPagamentoC.value.numberValue;

                    for (var venda in cx.vendas
                        .distinctBy((v) => v.pedido)
                        .where((p0) => p0.cliente?.id == cliente.id)
                        .where((p0) => p0.valorTotal != p0.valorPago)) {
                      num valorAberto = (venda.valorTotal ?? 0) - (venda.valorPago ?? 0);

                      // Saldo de pagamento foi totalmente utilizado
                      if (vlrpago <= 0) {
                        break;
                      }
                      //  Pedido pago integralmente. Saldo restante
                      if (vlrpago >= valorAberto) {
                        venda.valorPago = (venda.valorPago ?? 0) + valorAberto;
                        vlrpago -= valorAberto;
                        await cx.updateValorPagamento(venda);
                        Get.back();
                      } else {
                        //Pagamento parcial de valor aplicado ao pedido. Valor em aberto restante
                        venda.valorPago = (venda.valorPago ?? 0) + vlrpago;
                        await cx.updateValorPagamento(venda);
                        Get.back();
                        vlrpago = 0;
                        break;
                      }
                    }
                    //Ainda restam para serem usados em próximos pedidos
                    if (vlrpago > 0) {}
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ClienteData cliente = Get.arguments ?? ClienteData();

    Rx<num> valorPago = cx.vendas
        .distinctBy((v) => v.pedido)
        .where((v) => v.cliente?.id == cliente.id)
        .fold(0.0, (acc, mapa) => acc + ((mapa.valorPago) ?? 0))
        .obs;

    Rx<num?> totalCliente =
        cx.vendas.distinctBy((v) => v.pedido).where((v) => v.cliente?.id == cliente.id).isEmpty
            ? 0.obs
            : cx.vendas
                .distinctBy((v) => v.pedido)
                .where((v) => v.cliente?.id == cliente.id)
                .map((venda) => venda.valorTotal)
                .toList()
                .reduce((a, b) => (a ?? 0) + (b ?? 0))
                .obs;

    Rx<num> valorAberto = ((totalCliente.value ?? 0) -
            cx.vendas
                .distinctBy((v) => v.pedido)
                .where((v) => v.cliente?.id == cliente.id)
                .fold(0.0, (acc, mapa) => acc + ((mapa.valorPago) ?? 0)))
        .obs;

    return Scaffold(
        appBar: AppBar(
          title: Text(cliente.nome ?? ""),
          actions: [
            Tooltip(
                message: "Pagamento",
                child: IconButton(
                    onPressed: valorAberto.value <= 0
                        ? null
                        : () {
                            pagamento(context, cliente);
                          },
                    icon: Icon(Icons.attach_money_rounded))),
            Tooltip(
                message: "Imprimir",
                child: IconButton(
                    onPressed: cx.vendas
                            .distinctBy((v) => v.pedido)
                            .where((v) => v.cliente?.id == cliente.id)
                            .isEmpty
                        ? null
                        : () {
                            Get.to(() => RelatorioVendasPdf(), arguments: cliente);
                          },
                    icon: Icon(Icons.print_outlined))),
          ],
        ),
        bottomNavigationBar: Container(
          height: 120,
          color: Colors.black12.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Pagos: ${cx.real.format(valorPago.value)}",
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Em Aberto: ${cx.real.format(valorAberto.value)}",
                  style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.w600),
                ),
                Divider(),
                Text(
                  "Total em Compras: ${cx.real.format(totalCliente.value)}",
                  style: Get.theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        body: SfDataGrid(
          columnWidthMode: ColumnWidthMode.fill,
          footerHeight: 90,
          rowHeight: 50,
          autoExpandGroups: false,
          columns: [
            GridColumn(
              visible: false,
              columnName: 'ID',
              label: Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text('ID'),
              ),
            ),
            GridColumn(
              columnName: 'nome',
              label: Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text('Produto'),
              ),
            ),
            GridColumn(
              columnName: 'unit',
              label: Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text('Unit.'),
              ),
            ),
            GridColumn(
              columnName: 'qtd',
              label: Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text('Qtd'),
              ),
            ),
            GridColumn(
              columnName: 'total',
              label: Container(
                padding: EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Text('Total'),
              ),
            ),
          ],
          source: asc(DataSource()),
          selectionMode: SelectionMode.none,
          navigationMode: GridNavigationMode.cell,
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          allowExpandCollapseGroup: true,
          groupCaptionTitleFormat: '{Key}',
        ));
  }
}

class DataSource extends DataGridSource {
  DataSource() {
    final ClienteData cliente = Get.arguments ?? ClienteData();
    _employees = cx.vendas
        .where((p0) => p0.cliente?.id == cliente.id)
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell(columnName: 'ID', value: e.pedido),
              DataGridCell(columnName: 'nome', value: e.produto?.nome),
              DataGridCell(columnName: 'unit.', value: cx.real.format(e.produto?.valor)),
              DataGridCell(columnName: 'qtd', value: e.qtd),
              DataGridCell(
                  columnName: 'total',
                  value: cx.real.format((e.produto?.valor ?? 0) * (e.qtd ?? 0))),
            ]))
        .toList();
  }

  late List<DataGridRow> _employees;

  @override
  List<DataGridRow> get rows => _employees;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        child: Text(e.value.toString()),
      );
    }).toList());
  }

  @override
  Widget? buildGroupCaptionCellWidget(RowColumnIndex rowColumnIndex, String summaryValue) {
    VendasData vendasData = cx.vendas.where((p0) => p0.pedido == num.parse(summaryValue)).first;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(cx.dateFormatterSimplex.format(vendasData.dataVenda ?? DateTime.now())),
          Row(
            children: [
              Row(
                children: [
                  Icon(
                    size: 18,
                    Icons.monetization_on,
                    color: Colors.black54,
                  ),
                  SizedBox(width: 5),
                  Text(cx.real.format(vendasData.valorTotal)),
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
                  Text(cx.real.format(vendasData.valorPago)),
                ],
              ),
              SizedBox(width: 10),
              Row(
                children: [
                  Tooltip(
                    message: vendasData.valorPago == vendasData.valorTotal ? "Pago" : "Pendente",
                    child: Icon(
                      size: 18,
                      vendasData.valorPago == vendasData.valorTotal
                          ? Icons.attach_money_rounded
                          : Icons.money_off,
                      color: vendasData.valorPago == vendasData.valorTotal
                          ? Colors.black54
                          : Colors.deepOrange,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    cx.real.format((vendasData.valorTotal ?? 0) - (vendasData.valorPago ?? 0)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
