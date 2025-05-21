import 'package:flutter/material.dart';
import 'package:smartring_flutter/src/util/getxManager.dart';
import 'src/routers/router.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'src/hive/hive_manager.dart';

void main() {
  HiveManager().init();
  GetXManager.instance.lazyPutController();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smartring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        // useMaterial3: true,
        // primarySwatch: Colors.yellow
      ),
      // home: const Tabs(),
      initialRoute: "/",
      // onGenerateRoute: onGenerateRoute,
      getPages: Pages,
      builder: EasyLoading.init(),
    );
  }
}
