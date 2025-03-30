import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ouroaguaegas/data/clientes_data.dart';

import 'package:ouroaguaegas/ui/relatoriosUi.dart';
import '../controller/controller.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';

Future<void> selectCliente(context) async {
  final Controller c = Get.put(Controller());
  Rxn<ClienteData> clienteSelect = Rxn(null);
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Obx(
        () => AlertDialog(
          title: Text('Selecione o Cliente'),
          content: SingleChildScrollView(
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
                      return c.clientes.where((e) => e.ativo == true).where((ClienteData option) {
                        return option.nome.toString().toLowerCase().contains(pattern.toLowerCase());
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
                onPressed: clienteSelect.value == null
                    ? null
                    : () {
                        Get.to(() => DetalhesRelatorio(), arguments: clienteSelect.value);
                      },
                child: Text('Gerar')),
          ],
        ),
      );
    },
  );
}
