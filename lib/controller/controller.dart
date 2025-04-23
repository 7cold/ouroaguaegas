import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ouroaguaegas/data/clientes_data.dart';
import 'package:ouroaguaegas/data/produtos_data.dart';
import 'package:ouroaguaegas/data/vendas_data.dart';
import 'package:ouroaguaegas/ui/login.dart';
import 'package:ouroaguaegas/ui/root.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

class Controller extends GetxController {
  @override
  onInit() async {
    loadData();
    super.onInit();
  }

  SupabaseClient supabase = Supabase.instance.client;
  RxList<ClienteData> clientes = <ClienteData>[].obs;
  RxList<ProdutosData> produtos = <ProdutosData>[].obs;
  RxList<VendasData> vendas = <VendasData>[].obs;
  RxBool loading = false.obs;

  DateFormat dateFormatterSimple = DateFormat('HH:mm - dd/MM/yyyy', 'pt_br');
  DateFormat diferenceHour = DateFormat('HHh mmm - dd/MM/yyyy', 'pt_br');
  DateFormat dateFormatterSimplex = DateFormat('dd/MM/yyyy - HH:mm', 'pt_br');
  DateFormat dateFormatterSimple2 = DateFormat('dd/MM/yyyy', 'pt_br');
  DateFormat dateFormatterMes = DateFormat('MMMM/yyyy', 'pt_br');
  NumberFormat real = NumberFormat("#,##0.00", "pt_BR");

  Future getProdutos() async {
    loading.value = true;
    produtos.clear();
    final data = await supabase.from('produtos').select();
    for (var x in data) {
      ProdutosData produtosData = ProdutosData.fromJson(x);
      produtos.add(produtosData);
    }
    produtos.sort((a, b) => a.nome!.compareTo(b.nome ?? ""));

    loading.value = false;
  }

  Future getVendas() async {
    loading.value = true;
    vendas.clear();
    final data =
        await supabase.from('vendas').select('*, produtos(*), clientes(*), pedido_venda(*)');
    for (var x in data) {
      VendasData vendasData = VendasData.fromJson(x);

      vendas.add(vendasData);
    }

    vendas.sort((a, b) => a.dataVenda!.compareTo(b.dataVenda ?? DateTime.now()));

    loading.value = false;
  }

  Future getClientes() async {
    loading.value = true;
    clientes.clear();
    final data = await supabase.from('clientes').select();
    for (var x in data) {
      ClienteData clienteData = ClienteData.fromJson(x);
      clientes.add(clienteData);
    }
    clientes.sort((a, b) => a.nome!.compareTo(b.nome ?? ""));

    loading.value = false;
  }

  Future createCliente(ClienteData clienteData) async {
    loading.value = true;
    var data = await supabase.from('clientes').insert({
      "nome": clienteData.nome,
      "telefone": clienteData.telefone,
      "endereco": clienteData.endereco,
      "numero": clienteData.numero,
      "bairro": clienteData.bairro,
      "ativo": true
    }).select();
    clienteData.id = data[0]['id'];
    clientes.add(clienteData);
    clientes.sort((a, b) => a.nome!.compareTo(b.nome ?? ""));
    clientes.refresh();
    loading.value = false;
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context,
      title: const Text("Cadastrado com sucesso!"),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  Future createProduto(ProdutosData produtosData) async {
    loading.value = true;
    var data = await supabase.from('produtos').insert({
      'nome': produtosData.nome,
      'valor': produtosData.valor,
      'ativo': true,
      'estoque': produtosData.estoque,
    }).select();

    produtos.sort((a, b) => a.nome!.compareTo(b.nome ?? ""));

    produtosData.id = data[0]['id'];
    produtos.add(produtosData);
    produtos.refresh();

    loading.value = false;
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context, // optional if you use ToastificationWrapper
      title: const Text("Cadastrado com sucesso!"),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  Future createVenda(VendasData vendasData) async {
    loading.value = true;

    var data = await supabase.from('vendas').insert({
      "id_cliente": vendasData.idCliente,
      "id_produto": vendasData.idProduto,
      "valor_venda": vendasData.valorVenda,
      "data_venda":
          vendasData.dataVenda?.toUtc().subtract(const Duration(hours: 3)).toIso8601String(),
      "tipo_entrega": vendasData.tipoEntrega,
      "pedido_venda": vendasData.pedido,
      "quantidade": vendasData.qtd,
    }).select();

    vendasData.id = data[0]['id'];
    vendas.add(vendasData);

    vendas.sort((a, b) => a.dataVenda!.compareTo(b.dataVenda ?? DateTime.now()));

    loading.value = false;
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context,
      title: const Text("Venda realizada com sucesso!"),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  Future deleteProduto(ProdutosData produtosData) async {
    loading.value = true;
    await supabase.from('produtos').update({
      "ativo": false,
    }).eq('id', produtosData.id ?? 0);
    produtos.where((p0) => p0.id == produtosData.id).forEach((e) => e = produtosData);
    Get.back();
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context, // optional if you use ToastificationWrapper
      title: const Text("Excluido com sucesso!"),
      autoCloseDuration: const Duration(seconds: 5),
    );
    loading.value = false;
  }

  Future deleteCliente(ClienteData clienteData) async {
    loading.value = true;
    await supabase.from('clientes').update({
      "ativo": false,
    }).eq('id', clienteData.id ?? 0);
    clientes.where((p0) => p0.id == clienteData.id).forEach((e) => e = clienteData);
    clientes.refresh();
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context, // optional if you use ToastificationWrapper
      title: const Text("Excluido com sucesso!"),
    );
    loading.value = false;
  }

  Future updateEstoque(ProdutosData produtosData, bool exibirToast) async {
    loading.value = true;
    await supabase.from('produtos').update({
      "estoque": produtosData.estoque,
    }).eq('id', produtosData.id ?? 0);
    produtos.where((p0) => p0.id == produtosData.id).forEach((e) => e = produtosData);
    produtos.refresh();

    if (exibirToast == true) {
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        context: Get.context, // optional if you use ToastificationWrapper
        title: const Text("Alterado com sucesso!"),
        autoCloseDuration: const Duration(seconds: 5),
      );
    }

    loading.value = false;
  }

  Future updateEntrega(VendasData vendaData, entrega) async {
    loading.value = true;
    await supabase.from('pedido_venda').update({
      "entrega": entrega,
    }).eq('pedido_venda', vendaData.pedido ?? 0);

    vendas.where((p0) => p0.id == vendaData.id).forEach((e) => e = vendaData);
    vendas.refresh();
    Get.forceAppUpdate();
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context, // optional if you use ToastificationWrapper
      title: const Text("Alterado com sucesso!"),
      autoCloseDuration: const Duration(seconds: 5),
    );
    loading.value = false;
  }

  Future updateValorPagamento(VendasData vendaData) async {
    loading.value = true;
    await supabase.from('pedido_venda').update({
      "valor_pago": vendaData.valorPago,
    }).eq('pedido_venda', vendaData.pedido ?? 0);

    vendas.where((p0) => p0.id == vendaData.id).forEach((e) => e = vendaData);
    vendas.refresh();
    Get.forceAppUpdate();

    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context, // optional if you use ToastificationWrapper
      title: const Text("Alterado com sucesso!"),
      autoCloseDuration: const Duration(seconds: 5),
    );
    loading.value = false;
  }

  Future updateStatusPedido(VendasData vendasData, String status) async {
    loading.value = true;
    await supabase.from('vendas').update({
      "status": status,
    }).eq('id', vendasData.id ?? 0);
    vendas.where((p0) => p0.id == vendasData.id).forEach((e) => e = vendasData);
    vendas.refresh();

    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context, // optional if you use ToastificationWrapper
      title: const Text("Alterado com sucesso!"),
      autoCloseDuration: const Duration(seconds: 5),
    );

    loading.value = false;
  }

  Future updateProduto(ProdutosData produtosData) async {
    loading.value = true;
    await supabase.from('produtos').update({
      "nome": produtosData.nome,
      "valor": produtosData.valor,
    }).eq('id', produtosData.id ?? 0);
    produtos.where((p0) => p0.id == produtosData.id).forEach((e) => e = produtosData);
    produtos.refresh();
    Get.back();
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context, // optional if you use ToastificationWrapper
      title: const Text("Alterado com sucesso!"),
      autoCloseDuration: const Duration(seconds: 5),
    );
    loading.value = false;
  }

  Future updateCliente(ClienteData clienteData) async {
    loading.value = true;
    await supabase.from('clientes').update({
      "nome": clienteData.nome,
      "telefone": clienteData.telefone,
      "endereco": clienteData.endereco,
      "numero": clienteData.numero,
      "bairro": clienteData.bairro,
    }).eq('id', clienteData.id ?? 0);
    clientes.where((p0) => p0.id == clienteData.id).forEach((e) => e = clienteData);
    produtos.refresh();
    Get.back();
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context, // optional if you use ToastificationWrapper
      title: const Text("Alterado com sucesso!"),
      autoCloseDuration: const Duration(seconds: 5),
    );
    loading.value = false;
  }

  Future deletePedido(VendasData vendaData) async {
    loading.value = true;
    await supabase.from('vendas').delete().eq('pedido_venda', vendaData.pedido ?? 0);
    await supabase.from('pedido_venda').delete().eq('pedido_venda', vendaData.pedido ?? 0);
    vendas.removeWhere((element) => element.pedido == vendaData.pedido);
    vendas.refresh();
    loading.value = false;
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context, // optional if you use ToastificationWrapper
      title: const Text("Deletado com sucesso!"),
      autoCloseDuration: const Duration(seconds: 5),
    );
    Get.back();
  }

  login(String userx, String pass) async {
    try {
      await supabase.auth.signInWithPassword(
        email: userx,
        password: pass,
      );
      await loadData();

      Get.offAll(const Root());
    } on AuthException catch (e) {
      if (e.statusCode == "400") {
        Get.snackbar("Error", "E-mail ou Senhas Icorretos!", backgroundColor: Colors.amber);
      }
    }
  }

  logout() async {
    loading.value = true;
    await supabase.auth.signOut();
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      context: Get.context, // optional if you use ToastificationWrapper
      title: const Text("Logout efetuado com sucesso!"),
      autoCloseDuration: const Duration(seconds: 5),
    );
    Get.offAll(const Login());
    loading.value = false;
  }

  loadData() async {
    await getProdutos();
    await getClientes();
    await getVendas();
  }
}
