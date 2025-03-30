import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ouroaguaegas/ui/login.dart';

import '../controller/controller.dart';
import 'homeUi.dart';

final Controller c = Get.put(Controller());

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return c.supabase.auth.currentSession != null ? HomeUi() : const Login();
  }
}
