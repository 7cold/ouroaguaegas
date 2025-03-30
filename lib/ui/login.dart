// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/controller.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

final Controller c = Get.put(Controller());
TextEditingController user = TextEditingController();
TextEditingController pass = TextEditingController();

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        resizeToAvoidBottomInset: true,
        body: c.loading.value == true
            ? CircularProgressIndicator()
            : Center(
                child: SizedBox(
                  width: !context.isPhone ? 600 : context.width,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Theme.of(context).highlightColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: SingleChildScrollView(
                      child: Form(
                        child: Column(children: [
                          const Text(
                            "Login",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            "Ouro Agua e Gás  ",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: user,
                            decoration: const InputDecoration(
                                filled: true,
                                hintText: "E-mail",
                                icon: Icon(Icons.people_alt_outlined)),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: pass,
                            obscureText: true,
                            decoration: const InputDecoration(
                                filled: true,
                                hintText: "Senha",
                                icon: Icon(Icons.lock_open_outlined)),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: FilledButton(
                              onPressed: () {
                                c.login(user.text, pass.text);
                              },
                              child: const Text("Login"),
                            ),
                          )
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
