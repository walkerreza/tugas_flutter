// import 'package:flutter/material.dart';

// class DashboardMenu extends StatefulWidget {
//   final String id;
//   final String name;
//   final String email;
//   final String? type;

//   const DashboardMenu({
//     super.key,
//     required this.id,
//     required this.name,
//     required this.email,
//     this.type,
//   });

//   @override
//   State<DashboardMenu> createState() => _DashboardMenuState();
// }

// class _DashboardMenuState extends State<DashboardMenu> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor,
//               borderRadius: const BorderRadius.only(
//                 bottomRight: Radius.circular(50),
//               ),
//             ),
//             child: Column(
//               children: [
//                 const SizedBox(height: 50),
//                 ListTile(
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 30),
//                   title: Text(
//                     'Hallo ${widget.name}',
//                     style: Theme.of(
//                       context,
//                     ).textTheme.headlineSmall?.copyWith(color: Colors.white),
//                   ),
//                   subtitle: Text(
//                     '${widget.email} (${widget.type ?? 'User'})',
//                     style: Theme.of(
//                       context,
//                     ).textTheme.titleMedium?.copyWith(color: Colors.white54),
//                   ),
//                   trailing: const CircleAvatar(
//                     radius: 30,
//                     backgroundImage: AssetImage('img/akb.png'),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//           Container(
//             color: Theme.of(context).primaryColor,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 30),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(topLeft: Radius.circular(200)),
//               ),
//               child: GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 40,
//                 mainAxisSpacing: 30,
//                 children: [
//                   itemDashboard('Video', Icons.video_call, Colors.deepOrange),
//                   itemDashboard(
//                     'Analytics',
//                     Icons.analytics_outlined,
//                     Colors.green,
//                   ),
//                   itemDashboard(
//                     'Program',
//                     Icons.air_outlined,
//                     Colors.cyanAccent,
//                   ),
//                   itemDashboard(
//                     'Audience',
//                     Icons.man_2_outlined,
//                     Colors.purple,
//                   ),
//                   itemDashboard('Comments', Icons.comment, Colors.brown),
//                   itemDashboard('Revenue', Icons.money, Colors.indigo),
//                   itemDashboard('Upload', Icons.add_box_outlined, Colors.teal),
//                   itemDashboard('About', Icons.question_answer, Colors.blue),
//                   itemDashboard(
//                     'Contact',
//                     Icons.contact_mail,
//                     Colors.pinkAccent,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   itemDashboard(String title, IconData iconData, Color background) => Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(10),
//       boxShadow: [
//         BoxShadow(
//           offset: const Offset(0, 5),
//           color: Theme.of(
//             context,
//           ).primaryColor.withAlpha(51), // Perbaikan opacity
//           spreadRadius: 2,
//           blurRadius: 5,
//         ),
//       ],
//     ),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(color: background, shape: BoxShape.circle),
//           child: Icon(iconData, color: Colors.white),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           title.toUpperCase(),
//           style: Theme.of(context).textTheme.titleMedium,
//         ),
//       ],
//     ),
//   );
// }
