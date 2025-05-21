import 'package:flutter/material.dart';

class OtaDetailPage extends StatefulWidget {
  const OtaDetailPage({super.key});

  @override
  State<OtaDetailPage> createState() => _OtaDetailPageState();
}

class _OtaDetailPageState extends State<OtaDetailPage> {
  // ignore: prefer_function_declarations_over_variables
  void _initDialog() async {
    var result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("dialog"),
            content: const Text("content"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop("ok");
                  },
                  child: const Text("OK")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop("cancel");
                  },
                  child: const Text("cancel"))
            ],
          );
        });
    debugPrint(result);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // debugPrint(Get.arguments["title"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("OtaUpdate"),
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: () {
                // Navigator.of(context).pushReplacementNamed("/");
                _initDialog();
              },
              child: const Text("back")),
        ));
  }
}
