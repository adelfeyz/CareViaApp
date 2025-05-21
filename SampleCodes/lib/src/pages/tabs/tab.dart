import 'package:flutter/material.dart';
import 'bluepage.dart';
import 'healthpage.dart';
import 'otapage.dart';
import 'package:get/get.dart';

class Tabs extends StatelessWidget {
  Tabs({super.key});
  final RxInt currentIndex = 0.obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Smartring"),
          centerTitle: true,
        ),
        body: Obx(() => IndexedStack(index: currentIndex.value, children: [
              BluePage(
                tabIndex: currentIndex,
              ),
              HealthPage(tabIndex: currentIndex),
              const OtaPage()
            ])),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
              currentIndex: currentIndex.value,
              onTap: (value) {
                // setState(() {
                //   currentIndex = value;
                // });
                currentIndex.value = value;
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.bluetooth), label: "Blue"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.health_and_safety_outlined),
                    label: "Health"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.system_update_alt_sharp), label: "Ota"),
              ]),
        ));
  }
}
// class Tabs extends StatefulWidget {
//   const Tabs({super.key});

//   @override
//   State<Tabs> createState() => _TabsState();
// }

// class _TabsState extends State<Tabs> {
//   var currentIndex = 0.obs;
//   final List<Widget> list = [BluePage(), HealthPage(), OtaPage()];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Smartring"),
//         centerTitle: true,
//       ),
//       body: Obx(()=>list[currentIndex.value]),
//       bottomNavigationBar: Obx(() => BottomNavigationBar(
//           currentIndex: currentIndex.value,
//           onTap: (value) {
//             // setState(() {
//             //   currentIndex = value;
//             // });
//             currentIndex.value=value;
//           },
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.bluetooth), label: "Blue"),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.health_and_safety_outlined), label: "Health"),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.system_update_alt_sharp), label: "Ota"),
//           ]),) 
//     );
//   }
// }