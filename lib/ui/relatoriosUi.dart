import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final ClienteData cliente = Get.arguments ?? ClienteData();

    print(cx.vendas
        .distinctBy((v) => v.pedido)
        .where((v) => v.cliente?.id == cliente.id)
        .map((venda) => venda.valorTotal));

    return Scaffold(
        appBar: AppBar(
          title: Text(cliente.nome ?? ""),
          actions: [
            Tooltip(
                message: "Imprimir",
                child: IconButton(
                    onPressed: () {
                      Get.to(() => RelatorioVendasPdf(), arguments: cliente);
                    },
                    icon: Icon(Icons.print_outlined)))
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
                  "Pagos: ${cx.real.format(cx.vendas.distinctBy((v) => v.pedido).where((v) => v.cliente?.id == cliente.id).fold(0.0, (acc, mapa) => acc + ((mapa.valorPago) ?? 0)))}",
                  style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Em Aberto: ${cx.real.format(cx.vendas.where((v) => v.cliente?.id == cliente.id).fold(0.0, (acc, mapa) => acc + ((mapa.produto?.valor ?? 0) * (mapa.qtd ?? 0))) - cx.vendas.distinctBy((v) => v.pedido).where((v) => v.cliente?.id == cliente.id).fold(0.0, (acc, mapa) => acc + ((mapa.valorPago) ?? 0)))}",
                  style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.w600),
                ),
                Divider(),
                Text(
                  "Total em Compras: ${cx.real.format(cx.vendas.where((v) => v.cliente?.id == cliente.id).fold(0.0, (acc, mapa) => acc + ((mapa.produto?.valor ?? 0) * (mapa.qtd ?? 0))))}",
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
