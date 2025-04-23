import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ouroaguaegas/data/clientes_data.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../controller/controller.dart';

class RelatorioVendasPdf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Controller c = Get.put(Controller());
    RxString fechamento = "Total".obs;
    RxBool emAberto = false.obs;
    Rxn<DateTime> data = Rxn(DateTime(DateTime.now().year, DateTime.now().month, 1));
    ClienteData cliente = Get.arguments;
    Future<Uint8List> generatePdfTotal(PdfPageFormat format) async {
      final pdf = pw.Document();

      var agrupado = groupBy(c.vendas.where((p0) {
        if (fechamento.value == "Total" && emAberto.value == false) {
          return p0.cliente!.id == cliente.id;
        } else if (fechamento.value == "Total" && emAberto.value == true) {
          return p0.cliente!.id == cliente.id && p0.valorPago != p0.valorTotal;
        } else if (fechamento.value == "Mês" && emAberto.value == false) {
          return p0.cliente!.id == cliente.id &&
              p0.dataVenda!.month == data.value!.month &&
              p0.dataVenda!.year == data.value!.year;
        } else {
          return p0.cliente!.id == cliente.id &&
              p0.dataVenda!.month == data.value!.month &&
              p0.dataVenda!.year == data.value!.year &&
              p0.valorPago != p0.valorTotal;
        }

        // if (emAberto.value == true) {
        //   return p0.cliente!.id == cliente.id && p0.valorPago != p0.valorTotal;
        // } else {
        //   return p0.cliente!.id == cliente.id;
        // }
      }), (venda) => venda.pedido);

      var col = {
        0: pw.FixedColumnWidth(100),
        1: pw.FixedColumnWidth(50),
        2: pw.FixedColumnWidth(50),
        3: pw.FixedColumnWidth(50),
        4: pw.FixedColumnWidth(50),
      };

      var t = c.vendas
          .distinctBy((v) => v.pedido)
          .where((v) => v.cliente?.id == cliente.id)
          .map((venda) => venda.valorTotal)
          .toList()
          .reduce((a, b) => (a ?? 0) + (b ?? 0));

      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text('Relatório de Vendas - Ouro Agua e Gás',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Cliente: ${cliente.nome!}'),
                pw.Text(
                    'Endereço:  ${"${cliente.endereco!}, ${cliente.numero!} - ${cliente.bairro!}"}'),
                pw.Text('Telefone: ${cliente.telefone!}'),
                pw.SizedBox(height: 20),
                pw.Table(
                    columnWidths: col,
                    border: pw.TableBorder.all(color: PdfColors.black),
                    children: [
                      pw.TableRow(children: [
                        pw.Center(
                            child: pw.Text("Pedido",
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Center(
                            child: pw.Text("Data",
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Center(
                            child: pw.Text("Vlr Total",
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Center(
                            child: pw.Text("Vlr Pago",
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Center(
                            child: pw.Text("Vlr Restante",
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ])
                    ]),
                pw.Table(
                  columnWidths: col,
                  border: pw.TableBorder.all(color: PdfColors.black),
                  children: agrupado.entries.map((entry) {
                    var vendasPorPedido = entry.value;

                    return pw.TableRow(children: [
                      pw.Table(
                          columnWidths: col,
                          border: pw.TableBorder.all(color: PdfColors.black),
                          children: [
                            pw.TableRow(
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey300,
                                ),
                                children: [
                                  pw.Center(
                                      child: pw.Text(vendasPorPedido.first.pedido.toString(),
                                          style: pw.TextStyle(
                                            fontSize: 10.5,
                                          ))),
                                  pw.Center(
                                      child: pw.Text(
                                          c.dateFormatterSimple2.format(
                                              vendasPorPedido.first.dataVenda ?? DateTime.now()),
                                          style: pw.TextStyle(
                                            fontSize: 10.5,
                                          ))),
                                  pw.Padding(
                                      padding: pw.EdgeInsets.only(right: 5),
                                      child: pw.Align(
                                          alignment: pw.Alignment.centerRight,
                                          child: pw.Text(
                                              c.real.format(vendasPorPedido.first.valorTotal),
                                              style: pw.TextStyle(
                                                fontSize: 10.5,
                                              )))),
                                  pw.Padding(
                                      padding: pw.EdgeInsets.only(right: 5),
                                      child: pw.Align(
                                          alignment: pw.Alignment.centerRight,
                                          child: pw.Text(
                                              c.real.format(vendasPorPedido.first.valorPago),
                                              style: pw.TextStyle(
                                                fontSize: 10.5,
                                              )))),
                                  pw.Padding(
                                      padding: pw.EdgeInsets.only(right: 5),
                                      child: pw.Align(
                                          alignment: pw.Alignment.centerRight,
                                          child: pw.Text(
                                              c.real.format(
                                                  (vendasPorPedido.first.valorTotal ?? 0) -
                                                      (vendasPorPedido.first.valorPago ?? 0)),
                                              style: pw.TextStyle(
                                                fontSize: 10.5,
                                              )))),
                                ]),
                            for (var venda in vendasPorPedido)
                              pw.TableRow(
                                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                                  children: [
                                    pw.Padding(
                                        padding: pw.EdgeInsets.only(left: 5),
                                        child: pw.Text(venda.produto!.nome!,
                                            style: pw.TextStyle(
                                                fontSize: 9.5, color: PdfColors.grey900))),
                                    pw.Center(
                                        child: pw.Text("${venda.qtd!}x",
                                            style: pw.TextStyle(
                                                fontSize: 9.5, color: PdfColors.grey900))),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.only(left: 5),
                                        child: pw.Text(
                                            "Total: ${c.real.format(venda.produto!.valor! * venda.qtd!)}",
                                            style: pw.TextStyle(
                                                fontSize: 9.5, color: PdfColors.grey900))),
                                    pw.Padding(
                                        padding: pw.EdgeInsets.only(left: 5),
                                        child: pw.Text(
                                            "Unit: ${c.real.format(venda.produto!.valor!)}",
                                            style: pw.TextStyle(
                                                fontSize: 9.5, color: PdfColors.grey900))),
                                    pw.Center(child: pw.Text("-")),
                                  ])
                          ]),
                    ]);
                  }).toList(),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                    height: 50,
                    width: double.infinity,
                    color: PdfColors.grey300,
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          emAberto.value == true
                              ? pw.SizedBox()
                              : pw.Text(
                                  "Pagos: ${c.real.format(c.vendas.distinctBy((v) => v.pedido).where((v) => v.cliente?.id == cliente.id).fold(0.0, (acc, mapa) => acc + ((mapa.valorPago) ?? 0)))}",
                                ),
                          pw.Text(
                            "Em Aberto: ${c.real.format((t ?? 0) - c.vendas.distinctBy((v) => v.pedido).where((v) => v.cliente?.id == cliente.id).fold(0.0, (acc, mapa) => acc + ((mapa.valorPago) ?? 0)))}",
                          ),
                          emAberto.value == true
                              ? pw.SizedBox()
                              : pw.Text(
                                  "Total em Compras: ${c.real.format(t)}",
                                ),
                        ])),
              ],
            );
          },
        ),
      );

      return pdf.save();
    }

    Future<void> selecioneMes(context) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Selecione'),
            content: SizedBox(
              height: 250,
              width: 200,
              child: SfDateRangePicker(
                view: DateRangePickerView.year,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  data.value = args.value;
                  print(data.value);
                  Get.back();
                },
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
                onPressed: () async {},
              ),
            ],
          );
        },
      );
    }

    return Obx(
      () => Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            title: Text('Relatório de Vendas'),
            actions: [
              CheckboxMenuButton(
                value: emAberto.value,
                onChanged: (_) {
                  emAberto.value = !emAberto.value;
                },
                child: const Text("Em Aberto"),
              ),
              DropdownMenu<String>(
                initialSelection: fechamento.value,
                requestFocusOnTap: true,
                label: const Text('Fechamento'),
                onSelected: (value) async {
                  fechamento.value = value.toString();
                  if (value == "Mês") {
                    await selecioneMes(context);
                  }
                  fechamento.value = "Total";
                  fechamento.value = "Mês";
                },
                dropdownMenuEntries:
                    ["Total", "Mês"].map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
              ),
            ],
          ),
          body: PdfPreview(build: (format) => generatePdfTotal(format))),
    );
  }
}
