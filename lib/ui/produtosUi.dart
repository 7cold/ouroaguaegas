import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ouroaguaegas/data/produtos_data.dart';
import 'package:responsive_ui/responsive_ui.dart';
import '../const/upperCase.dart';
import '../controller/controller.dart';
import 'package:extended_masked_text/extended_masked_text.dart';

final Controller c = Get.put(Controller());

class Produtosui extends StatelessWidget {
  Future<void> _showMyDialog(context) async {
    TextEditingController nome = TextEditingController();
    MoneyMaskedTextController valor = MoneyMaskedTextController();
    TextEditingController estoque = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cadastrar Produto'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      inputFormatters: [FirstLetterTextFormatter()],
                      controller: nome,
                      decoration: InputDecoration(labelText: 'Nome', filled: true),
                      validator: (value) => value!.isEmpty ? 'Campo Obrigatório' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: valor,
                      decoration: InputDecoration(labelText: 'Valor', filled: true),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Campo Obrigatório' : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: estoque,
                      decoration: InputDecoration(labelText: 'Qtd. em Estoque', filled: true),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Campo Obrigatório' : null,
                    ),
                  ),
                ],
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
                if (!formKey.currentState!.validate()) return;
                await c.createProduto(
                  ProdutosData(
                    ativo: true,
                    nome: nome.text,
                    valor: num.parse(valor.numberValue.toString()),
                    estoque: int.parse(estoque.text),
                  ),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _estoque(context, ProdutosData produto) async {
    Rx<TextEditingController> estoque = TextEditingController(text: produto.estoque.toString()).obs;
    Rx<TextEditingController> addestoque = TextEditingController().obs;
    RxInt estoquefinal = (int.parse(estoque.value.text) + 0).obs;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Estoque'),
          content: SingleChildScrollView(
            child: Obx(
              () => ListBody(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      enabled: false,
                      controller: estoque.value,
                      decoration: InputDecoration(labelText: 'Qtd. em Estoque', filled: true),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      controller: addestoque.value,
                      onChanged: (value) {
                        estoquefinal.value = int.parse(estoque.value.text) +
                            int.parse(addestoque.value.text == '' ? '0' : addestoque.value.text);
                      },
                      decoration: InputDecoration(labelText: 'Add. ao Estoque', filled: true),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      enabled: false,
                      controller: TextEditingController(text: estoquefinal.value.toString()),
                      decoration: InputDecoration(
                        labelText: "Total",
                        filled: true,
                        hintText: estoquefinal.value.toString(),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
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
                produto.estoque = estoquefinal.value;
                await c.updateEstoque(produto, true);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editar(context, ProdutosData produto) async {
    TextEditingController nome = TextEditingController(text: produto.nome);
    MoneyMaskedTextController valor =
        MoneyMaskedTextController(initialValue: produto.valor?.toDouble() ?? 0.0);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Produto'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    inputFormatters: [FirstLetterTextFormatter()],
                    controller: nome,
                    decoration: InputDecoration(labelText: 'Nome', filled: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    controller: valor,
                    decoration: InputDecoration(labelText: 'Valor', filled: true),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
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
              child: const Text('Salvar'),
              onPressed: () async {
                produto.nome = nome.text;
                produto.valor = num.parse(valor.numberValue.toString());
                await c.updateProduto(produto);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Produtos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
                onPressed: () {
                  _showMyDialog(context);
                },
                icon: Icon(Icons.add)),
          ),
        ],
      ),
      body: Obx(
        () => c.loading.value
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Div(
                divison: Division(colXL: 5),
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                          right: 20,
                          left: 20,
                          bottom: 20,
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: c.produtos
                                .where((p0) => p0.ativo == true)
                                .map((produto) => Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: ListTile(
                                        onTap: () {
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (context) => Wrap(
                                                    children: [
                                                      Center(
                                                          child: Padding(
                                                        padding: const EdgeInsets.only(top: 40),
                                                        child: Text(
                                                          "Opções",
                                                          style: context.textTheme.titleLarge,
                                                        ),
                                                      )),
                                                      Container(
                                                        width: double.infinity,
                                                        padding: const EdgeInsets.all(15),
                                                        height: 160,
                                                        child: Flex(
                                                          spacing: 20,
                                                          direction: Axis.horizontal,
                                                          children: [
                                                            Expanded(
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(4.0),
                                                                child: FilledButton(
                                                                    onPressed: () async {
                                                                      produto.ativo = false;
                                                                      await c
                                                                          .deleteProduto(produto);
                                                                    },
                                                                    child: Text('Excluir')),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(4.0),
                                                                child: FilledButton(
                                                                    onPressed: () {
                                                                      _estoque(context, produto);
                                                                    },
                                                                    child: Text('Estoque')),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(4.0),
                                                                child: FilledButton(
                                                                    onPressed: () {
                                                                      _editar(context, produto);
                                                                    },
                                                                    child: Text('Editar')),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ));
                                        },
                                        title: Text(produto.nome!),
                                        subtitle: Text('R\$ ${produto.valor!.toStringAsFixed(2)}'),
                                        trailing: Text('Estoque: ${produto.estoque}'),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
      ),
    );
  }
}
