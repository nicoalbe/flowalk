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
        body: Padding(
          padding: const EdgeInsets.only(bottom: 60.0),
          child: Column(
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

  Future<int> _fetchStepGoal() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 10000; // Default goal if not logged in
    }
    
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('goals').doc(user.uid).get();
      if (documentSnapshot.exists) {
        return documentSnapshot['goal'] ?? 10000; // Default goal if not set
      }
    } catch (error) {
      print('Error fetching step goal: $error');
    }
    return 10000; // Default goal in case of error
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_fetchStepGoal(), getStepsForMonth(month)]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty || snapshot.data![1].isEmpty) {
          return Center(
            child: Column(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(month),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('No steps data available for this month.'),
              ],
            ),
          );
        } else {
          int stepGoal = snapshot.data![0];
          List<Map<String, dynamic>> stepsData = snapshot.data![1];
          final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
          stepsData.sort((a, b) {
            DateTime dateA = dateFormat.parse(a['date']);
            DateTime dateB = dateFormat.parse(b['date']);
            return dateA.compareTo(dateB);
          });

          // Adding a fake element at the end of the list
          return Column(
            children: [
              Text(
                DateFormat('MMMM yyyy').format(month),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: stepsData.length + 1, // One extra item for the fake element
                  itemBuilder: (context, index) {
                    if (index == stepsData.length) {
                      // Fake element
                      return ListTile(
                        title: Container(
                          height: 70, // Height of the empty box
                          color: Colors.transparent, // Make it transparent or any color you prefer
                        ),
                      );
                    } else {
                      int steps = stepsData[index]['steps'];
                      String date = stepsData[index]['date'];
                      int day = DateFormat('dd-MM-yyyy').parse(date).day;
                      double percentage = steps / stepGoal;
                      String imagePath = 'assets/';
                      if (percentage < 0.5) {
                        imagePath += '00pot.png';
                      } else if (percentage < 0.75) {
                        imagePath += '01bud.png';
                      } else if (percentage < 1) {
                        imagePath += '02small.png';
                      } else {
                        imagePath += '03flower.png';
                      }
                      return ListTile(
                        title: Row(
                          children: [
                            Image.asset(
                              imagePath,
                              width: 70,
                              height: 70,
                            ),
                            SizedBox(width: 10),
                            Text('Day $day, steps: $steps'),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getStepsForMonth(DateTime month) async {
    DateTime startDate = DateTime(month.year, month.month, 1);
    DateTime endDate = DateTime(month.year, month.month + 1, 0);
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('garden')
        .where('user', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> stepsData = [];
    for (var doc in querySnapshot.docs) {
      DateTime docDate = DateFormat('dd-MM-yyyy').parse(doc['date']);
      if (docDate.isAfter(startDate.subtract(Duration(days: 1))) && docDate.isBefore(endDate.add(Duration(days: 1)))) {
        stepsData.add({
          'date': doc['date'],
          'steps': doc['steps'],
        });
      }
    }
    return stepsData;
  }
}

class GardenFunc extends StatelessWidget {
  const GardenFunc({Key? key, required this.loggedIn}) : super(key: key);

  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: loggedIn,
            child: Garden(),
          ),
          Visibility(
            visible: !loggedIn,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust padding as needed
              child: const Text(
                "Welcome to Flowalk! \nTo start using the application go to the Settings page and login or register.",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

