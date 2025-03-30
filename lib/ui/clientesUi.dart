import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ouroaguaegas/data/clientes_data.dart';
import 'package:responsive_ui/responsive_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../const/upperCase.dart';
import '../controller/controller.dart';
import 'package:extended_masked_text/extended_masked_text.dart';

class ClientesUi extends StatelessWidget {
  final Controller c = Get.put(Controller());

  Future<void> _showMyDialog(context) async {
    TextEditingController nome = TextEditingController();
    MaskedTextController telefone = MaskedTextController(mask: '(00) 00000-0000');
    TextEditingController endereco = TextEditingController();
    TextEditingController numero = TextEditingController();
    TextEditingController bairro = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cadastro de Cliente'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: DropDownSearchField(
                      textFieldConfiguration: TextFieldConfiguration(
                        inputFormatters: [FirstLetterTextFormatter()],
                        controller: nome,
                        decoration: const InputDecoration(hintText: "Nome", filled: true),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor insira um nome';
                        }
                        return null;
                      },
                      noItemsFoundBuilder: (context) => const Text("Nenhum Cliente Cadastrado"),
                      suggestionsCallback: (pattern) async {
                        return c.clientes.where((e) => e.ativo == true).where((ClienteData option) {
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
                      onSuggestionSelected: (data) {},
                      displayAllSuggestionWhenTap: true,
                      isMultiSelectDropdown: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      controller: telefone,
                      decoration: InputDecoration(labelText: 'Tel.', filled: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor insira um telefone';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      inputFormatters: [FirstLetterTextFormatter()],
                      controller: endereco,
                      decoration: InputDecoration(labelText: 'Endereço', filled: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor insira um endereço';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      inputFormatters: [FirstLetterTextFormatter()],
                      controller: numero,
                      decoration: InputDecoration(labelText: 'Nº', filled: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor insira um nº';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextFormField(
                      inputFormatters: [FirstLetterTextFormatter()],
                      controller: bairro,
                      decoration: InputDecoration(labelText: 'Bairro', filled: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor insira um bairro';
                        }
                        return null;
                      },
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

                await c.createCliente(ClienteData(
                  nome: nome.text,
                  ativo: true,
                  telefone: telefone.text,
                  endereco: endereco.text,
                  numero: numero.text,
                  bairro: bairro.text,
                ));

                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editar(context, ClienteData cliente) async {
    TextEditingController nome = TextEditingController(text: cliente.nome);
    TextEditingController endereco = TextEditingController(text: cliente.endereco);
    TextEditingController numero = TextEditingController(text: cliente.numero);
    TextEditingController bairro = TextEditingController(text: cliente.bairro);
    MaskedTextController telefone =
        MaskedTextController(mask: '(00) 00000-0000', text: cliente.telefone!);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Cliente'),
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
                    controller: telefone,
                    decoration: InputDecoration(labelText: 'Tel.', filled: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    inputFormatters: [FirstLetterTextFormatter()],
                    controller: endereco,
                    decoration: InputDecoration(labelText: 'Endereço', filled: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    inputFormatters: [FirstLetterTextFormatter()],
                    controller: numero,
                    decoration: InputDecoration(labelText: 'Nº', filled: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    inputFormatters: [FirstLetterTextFormatter()],
                    controller: bairro,
                    decoration: InputDecoration(labelText: 'Bairro', filled: true),
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
                cliente.nome = nome.text;
                cliente.endereco = endereco.text;
                cliente.telefone = telefone.text;
                cliente.bairro = bairro.text;
                cliente.numero = numero.text;
                await c.updateCliente(cliente);
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
    late RxBool pesquisar = false.obs;
    TextEditingController textEditingController = TextEditingController();
    RxString searchController = "".obs;
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: pesquisar.value == true
              ? TextField(
                  onChanged: (_) {
                    searchController.value = _;
                  },
                  controller: textEditingController,
                )
              : Text('Clientes'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                  onPressed: () {
                    pesquisar.value = !pesquisar.value;
                    textEditingController.clear();
                    searchController.value = "";
                  },
                  icon: pesquisar.value == true
                      ? const Icon(Icons.clear_rounded)
                      : const Icon(Icons.search)),
            ),
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
        body: c.loading.value
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
                          height: double.maxFinite,
                          width: double.maxFinite,
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
                              children: c.clientes
                                  .where((p0) =>
                                      p0.nome!.isCaseInsensitiveContainsAny(searchController.value))
                                  .where((cliente) => cliente.ativo == true)
                                  .map((cliente) => Card(
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
                                                                  padding:
                                                                      const EdgeInsets.all(8.0),
                                                                  child: FilledButton(
                                                                      onPressed: () async {
                                                                        cliente.ativo = false;
                                                                        await c
                                                                            .deleteCliente(cliente);
                                                                      },
                                                                      child: Text('Excluir')),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.all(8.0),
                                                                  child: FilledButton(
                                                                      onPressed: () {
                                                                        _editar(context, cliente);
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
                                          title: Text(cliente.nome!),
                                          subtitle: Text(
                                              '${cliente.endereco!} , ${cliente.numero!} - ${cliente.bairro!}'),
                                          trailing: Wrap(children: [
                                            IconButton.filled(
                                              onPressed: () async {
                                                var tel = cliente.telefone
                                                    ?.replaceAll("(", "")
                                                    .replaceAll(")", "")
                                                    .replaceAll("-", "")
                                                    .replaceAll(" ", "")
                                                    .toString();

                                                var text = "Olá, tudo bem?";
                                                await launchUrl(
                                                    Uri.parse("https://wa.me/+55$tel?text=$text"));
                                              },
                                              icon: FaIcon(
                                                size: 17,
                                                FontAwesomeIcons.whatsapp,
                                                color: Theme.of(context).colorScheme.inversePrimary,
                                              ),
                                            )
                                          ]),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
