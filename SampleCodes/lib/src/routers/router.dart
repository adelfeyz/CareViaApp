import '../pages/ota_detailpage.dart';
import '../pages/tabs/tab.dart';
import 'package:get/get.dart';
import 'middleware/otamiddleware.dart';

// Map routes = {
//   "/": (context) => const Tabs(),
//   "/otadetail": (context, {arguments}) => OtaDetailPage(
//         arguments: arguments,
//       ),
// };

var Pages = [
  GetPage(name: "/", page: () => Tabs()),
  GetPage(name: "/otadetail", page: () => const OtaDetailPage(),middlewares: [OtaMiddleWare()]),
];

// var onGenerateRoute = (RouteSettings settings) {
//   final String? name = settings.name;
//   final Function? pageContentBuild = routes[name];
//   if (pageContentBuild != null) {
//     if (settings.arguments != null) {
//       return MaterialPageRoute(
//         builder: (context) {
//           return pageContentBuild(context, arguments: settings.arguments);
//         },
//       );
//     } else {
//       return MaterialPageRoute(
//         builder: (context) {
//           return pageContentBuild(context);
//         },
//       );
//     }
//   }
//   return null;
// };
