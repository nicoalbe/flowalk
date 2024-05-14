// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; 
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Garden extends StatefulWidget {
//   @override
//   _GardenState createState() => _GardenState();
// }

// class _GardenState extends State<Garden> {
//   late PageController _pageController;
//   late DateTime _currentMonth;

//   @override
//   void initState() {
//     super.initState();
//     _currentMonth = DateTime.now();
//     _pageController = PageController(
//       initialPage: 11, // Set initial page to the current month
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height,
//       child: Scaffold(
//         body: Column(
//           children: [
//             Text(
//               'Garden:',
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 10),
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: 12,
//                 itemBuilder: (context, index) {
//                   final month = DateTime(_currentMonth.year, _currentMonth.month - 11 + index, 1);
//                   return MonthItem(month: month);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
// }

// class MonthItem extends StatelessWidget {
//   final DateTime month;

//   const MonthItem({required this.month});

//   @override
//   Widget build(BuildContext context) {
//     String imagePath = 'assets/';
//       int _stepCount = 8000;
//        int _stepGoal = 10000;
//       double percentage = _stepCount / _stepGoal;
//       if (percentage < 0.5) {
//         imagePath += '00pot.png';
//       } else if (percentage < 0.75) {
//         imagePath += '01bud.png';
//       } else if (percentage < 1) {
//         imagePath += '02small.png';
//       } else {
//         imagePath += '03flower.png';
//       }
//     return FutureBuilder(
//       future: getStepsForMonth(month),
//       builder: (context, AsyncSnapshot<List<String>> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Column(
//             children: [
//               Text(
//                 DateFormat('MMMM yyyy').format(month),
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               Text('No steps data available for this month.'),
//             ],
//           );
//         } else {
//           return Column(
//             children: [
//               Text(
//                 DateFormat('MMMM yyyy').format(month),
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text('Steps: ${snapshot.data![index]}'),
//                     );
//                   },
//                 ),
//               ),
//             Image.asset(
//             imagePath,
//             width: 500,
//             height: 500,
//             fit: BoxFit.contain,
//           ),
//             ],
//           );
//         }
//       },
//     );
//   }

//   Future<List<String>> getStepsForMonth(DateTime month) async {
//     // Calculate the start and end date for the month
//     DateTime startDate = DateTime(month.year, month.month, 1);
//     DateTime endDate = DateTime(month.year, month.month + 1, 0);

//     // Get the current user
//     String? userId = FirebaseAuth.instance.currentUser?.uid;

//     // Query Firestore for steps data within the month for the current user
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('garden')
//         .where('user', isEqualTo: userId)
//         .get();

//     // Extract steps data from documents
//     List<String> stepsData = [];
//     querySnapshot.docs.forEach((doc) {
//       DateTime docDate = DateFormat('dd-MM-yyyy').parse(doc['date']);
//       if (docDate.isAfter(startDate.subtract(Duration(days: 1))) && docDate.isBefore(endDate.add(Duration(days: 1)))) {
//       // Convert the 'steps' field from Firestore to a string
//       stepsData.add(doc['steps'].toString());
//       }
//     });

//     return stepsData;
//   }
// }



// class GardenFunc extends StatelessWidget {
//   const GardenFunc({
//     Key? key,
//     required this.loggedIn,
//   }) : super(key: key);

//   final bool loggedIn;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Visibility(
//             visible: loggedIn,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: Garden(),
//             ),
//           ),
//           Visibility(
//             visible: !loggedIn,
//             child: const Text("Please login"),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class Garden extends StatefulWidget {
  @override
  _GardenState createState() => _GardenState();
}

class _GardenState extends State<Garden> {
  late PageController _pageController;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _pageController = PageController(
      initialPage: 11, // Set initial page to the current month
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Scaffold(
        body: Column(
          children: [
            Text(
              'Garden:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = DateTime(_currentMonth.year, _currentMonth.month - 11 + index, 1);
                  return MonthItem(month: month);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class MonthItem extends StatelessWidget {
  final DateTime month;

  const MonthItem({required this.month});

  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/';
    int _stepCount = 8000;
    int _stepGoal = 10000;
    double percentage = _stepCount / _stepGoal;
    if (percentage < 0.5) {
      imagePath += '00pot.png';
    } else if (percentage < 0.75) {
      imagePath += '01bud.png';
    } else if (percentage < 1) {
      imagePath += '02small.png';
    } else {
      imagePath += '03flower.png';
    }
    return FutureBuilder(
      future: getStepsForMonth(month),
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            children: [
              Text(
                DateFormat('MMMM yyyy').format(month),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text('No steps data available for this month.'),
            ],
          );
        } else {
          return Column(
            children: [
              Text(
                DateFormat('MMMM yyyy').format(month),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Row(
                        children: [
                          Image.asset(
                            imagePath,
                            width:70 , 
                            height: 70, 
                          ),
                          SizedBox(width: 10),
                          Text('Steps: ${snapshot.data![index]}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<List<String>> getStepsForMonth(DateTime month) async {
    // Calculate the start and end date for the month
    DateTime startDate = DateTime(month.year, month.month, 1);
    DateTime endDate = DateTime(month.year, month.month + 1, 0);

    // Get the current user
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // Query Firestore for steps data within the month for the current user
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('garden')
        .where('user', isEqualTo: userId)
        .get();

    // Extract steps data from documents
    List<String> stepsData = [];
    querySnapshot.docs.forEach((doc) {
      DateTime docDate = DateFormat('dd-MM-yyyy').parse(doc['date']);
      if (docDate.isAfter(startDate.subtract(Duration(days: 1))) && docDate.isBefore(endDate.add(Duration(days: 1)))) {
      // Convert the 'steps' field from Firestore to a string
      stepsData.add(doc['steps'].toString());
      }
    });

    return stepsData;
  }
}

class GardenFunc extends StatelessWidget {
  const GardenFunc({
    Key? key,
    required this.loggedIn,
  }) : super(key: key);

  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: loggedIn,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Garden(),
            ),
          ),
          Visibility(
            visible: !loggedIn,
            child: const Text("Please login"),
          ),
        ],
      ),
    );
  }
}

