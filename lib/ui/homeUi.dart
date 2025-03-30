import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ouroaguaegas/const/createVendas.dart';
import 'package:ouroaguaegas/const/relatorioCliente.dart';
import 'package:ouroaguaegas/ui/clientesUi.dart';
import 'package:ouroaguaegas/ui/produtosUi.dart';
import 'package:ouroaguaegas/ui/vendasUi.dart';
import 'package:ouroaguaegas/ui/vendasUiEntregas.dart';
import 'package:responsive_ui/responsive_ui.dart';

import 'relatoriosUi.dart';

class HomeUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text('Início'),
        ),
        drawer: NavigationDrawer(
            tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            onDestinationSelected: (int index) {
              if (index == 0) {
                Get.back();
              }
              if (index == 1) {
                Get.to(() => ClientesUi());
              }
              if (index == 2) {
                Get.to(() => Produtosui());
              }
              if (index == 3) {
                Get.to(() => VendasUi());
              }
              if (index == 4) {
                Get.to(() => RelatoriosUi());
              }
              if (index == 5) {
                c.logout();
              }
            },
            selectedIndex: 0,
            children: [
              DrawerHeader(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Ouro Água e Gás",
                  style: Get.theme.textTheme.titleLarge,
                ),
              )),
              NavigationDrawerDestination(
                icon: Icon(Icons.home_outlined),
                label: Text('Inicio'),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.people_outline),
                label: Text('Clientes'),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.water_drop_outlined),
                label: Text('Produtos'),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                label: Text('Vendas'),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.analytics_outlined),
                label: Text('Relatórios'),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.logout_outlined),
                label: Text('Sair'),
              ),
            ]),
        body: c.loading.value
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Responsive(children: [
                  Div(
                    divison: Division(colXL: 2, colL: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Get.theme.primaryColor.withOpacity(0.2),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Get.to(() => VendasUiEntregas());
                          },
                          child: Container(
                            height: 90,
                            margin: const EdgeInsets.all(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Aguardando Entrega',
                                    style: TextStyle(fontSize: 20, color: Colors.white)),
                                Center(
                                  child: Text(
                                    groupBy(
                                        c.vendas.where((p0) => p0.status == "Aguardando").toList(),
                                        (venda) => venda.pedido).length.toString(),
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Div(
                    divison: Division(colXL: 2, colL: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Get.to(() => Produtosui());
                          },
                          child: Container(
                            height: 90,
                            margin: const EdgeInsets.all(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Produtos',
                                    style: TextStyle(fontSize: 20, color: Get.theme.primaryColor)),
                                Center(
                                  child: Text(
                                    c.produtos.where((p0) => p0.ativo == true).length.toString(),
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Get.theme.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Div(
                    divison: Division(colXL: 2, colL: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Get.to(() => ClientesUi());
                          },
                          child: Container(
                            height: 90,
                            margin: const EdgeInsets.all(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Clientes',
                                    style: TextStyle(fontSize: 20, color: Get.theme.primaryColor)),
                                Center(
                                  child: Text(
                                    c.clientes.where((p0) => p0.ativo == true).length.toString(),
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Get.theme.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Div(
                    divison: Division(colXL: 2, colL: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Get.to(() => VendasUi());
                          },
                          child: Container(
                            height: 90,
                            margin: const EdgeInsets.all(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vendas',
                                    style: TextStyle(fontSize: 20, color: Get.theme.primaryColor)),
                                Center(
                                  child: Text(
                                    groupBy(c.vendas, (venda) => venda.pedido).length.toString(),
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Get.theme.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Div(
                    divison: Division(colXL: 2, colL: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            createVendasDialog(context);
                          },
                          child: Container(
                            height: 90,
                            margin: const EdgeInsets.all(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nova Venda',
                                    style: TextStyle(fontSize: 20, color: Get.theme.primaryColor)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Div(
                    divison: Division(colXL: 2, colL: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            selectCliente(context);
                          },
                          child: Container(
                            height: 90,
                            margin: const EdgeInsets.all(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Consultar Cliente',
                                    style: TextStyle(fontSize: 20, color: Get.theme.primaryColor)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
      ),
    );
  }
}
