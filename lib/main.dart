import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/constants.dart';
import 'di/dependency_injection.dart';
import 'messaging/firebase_messaging_service.dart';
import 'providers/provider_setup.dart';
import 'utils/easy_loading_configure_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Stripe.publishableKey = publishablekey;
  await FirebaseMessagingService.initialize();
  setupLocator();
  configEasyLoading();
  runApp(const ProviderSetup());
}

// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//         debugShowCheckedModeBanner: false, home: HomePage());
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   bool _isLoading = true;
//   @override
//   void initState() {
//     super.initState();
//     isLoading();
//   }

//   Future<void> isLoading() async {
//     await Future.delayed(Duration(seconds: 1));
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   final _listImage = [
//     "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg",
//     "https://s3.envato.com/files/484884714/64f9a8d77faf0e7d5113b6eb_withmeta.jpg",
//     "https://www.wikihow.com/images/9/90/What_type_of_person_are_you_quiz_pic.png",
//     "https://media.istockphoto.com/id/1428534943/photo/man-with-open-mouth-and-satisfied-expression-pointing-with-finger-ar-smartwatch-and-laughing.jpg?s=612x612&w=0&k=20&c=BlmIsJyl4XOnXhtQzthg9Mux6WM2WbBPeOmemU_pBGg=",
//     "https://st.depositphotos.com/1269204/1219/i/450/depositphotos_12196477-stock-photo-smiling-men-isolated-on-the.jpg"
//   ];

//   final _names = ["John", "Emma", "Michael", "Sophia", "James"];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("FLutter Shimmer"),
//       ),
//       body: Center(
//         child: _isLoading
//             ? _buildShimmer()
//             : ListView.builder(
//                 itemCount: _listImage.length,
//                 itemBuilder: (ctx, index) {
//                   return ListTile(
//                     leading: CircleAvatar(
//                         child: ClipOval(
//                             child: Image.network(
//                                 width: 50,
//                                 height: 50,
//                                 fit: BoxFit.cover,
//                                 _listImage[index]))),
//                     title: Text(_names[index]),
//                   );
//                 }),
//       ),
//     );
//   }

//   Widget _buildShimmer() {
//     return Shimmer.fromColors(
//         baseColor: Colors.grey.shade300,
//         highlightColor: Colors.grey.shade200,
//         child: ListView.builder(itemBuilder: (ctx, index) {
//           return ListTile(
//             leading: Container(
//               width: 50,
//               height: 50,
//               decoration:  BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(50)),
//             ),
//             title: Container(
//               width: double.infinity,
//               height: 20,
//               decoration: const BoxDecoration(color: Colors.grey),
//             ),
//           );
//         }));
//   }
// }
