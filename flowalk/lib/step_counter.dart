import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:firebase_auth/firebase_auth.dart';



class StepCounter extends StatefulWidget {
  @override
  _StepCounterState createState() => _StepCounterState();
}

class _StepCounterState extends State<StepCounter> {
  int _stepCount = -1;
  int _stepGoal = 10000;
  StreamSubscription<StepCount>? _subscription;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startListening();
    _fetchStepGoal();
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      _handleRefresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _stopListening();
    _timer.cancel();
  }
  void _startListening() {
    _subscription = Pedometer.stepCountStream.listen(
      (StepCount stepCount) async {
        int todaySteps = await getTodaySteps(stepCount.steps);
        setState(() {
          _stepCount = todaySteps;
        });
      },
      onError: (error) {
        print('Pedometer error: $error');
      },
    );
  }

  Future<void> _handleRefresh() async {
    _startListening();
    await _fetchStepGoal();
  }

  void _stopListening() {
    _subscription?.cancel();
  }
  
  Future<void> _fetchStepGoal() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('User not logged in');
    return;
  }

  String userId = user.uid;

  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('goals').doc(userId).get();
    if (documentSnapshot.exists) {
      // Document already exists, retrieve the goal
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _stepGoal = data['goal'] ?? 0;
      });
    } else {
      // Document does not exist, create a new one with goal set to 10000
      await FirebaseFirestore.instance.collection('goals').doc(userId).set({
        'goal': 10000,
        'user': userId,
      });
      setState(() {
        _stepGoal = 10000;
      });
      print('Step goal document created successfully');
    }
  } catch (error) {
    print('Error fetching/creating step goal: $error');
  }
}
  
  Future<int> getTodaySteps(int stepCount) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    DateTime today=DateTime.now();
    String dateString = '${today.day}-${today.month}-${today.year}';
    
    updateStepsStart();

    int steps=stepCount;
    int stepStart= await readStepsStart(userId ?? '', dateString)??0;
    steps=stepCount-stepStart;
    return steps;
  }

  Future<int?> readStepsStart(String userId, String dateString) async {
    CollectionReference stepsCollection = FirebaseFirestore.instance.collection("steps");

    try {
      QuerySnapshot querySnapshot = await stepsCollection
          .where("user", isEqualTo: userId)
          .where("date", isEqualTo: dateString)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        int stepsStart = querySnapshot.docs.first['steps_start'];
        return stepsStart;
      } else {
        print("Document not found");
        return null;
      }
    } catch (error) {
      print("Error retrieving document: $error");
      return null;
    }
  }

  void updateStepsStart() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    // Get the current step count
    int? currentStepCount = await getCurrentStepCount();
    if (currentStepCount == null) {
      print('Error retrieving current step count');
      return;
    }

    // Get the current date
    DateTime now = DateTime.now();
    String dateString = '${now.day}-${now.month}-${now.year}';

    // Check if a document with the same user and date exists
    CollectionReference stepsCollection =
        FirebaseFirestore.instance.collection('steps');
    QuerySnapshot querySnapshot = await stepsCollection
        .where('user', isEqualTo: user.uid)
        .where('date', isEqualTo: dateString)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Document already exists, do not add a new one
      print('Document already exists for user $user and date $dateString');
      return;
    }

    // Document does not exist, add a new one
    try {
      await stepsCollection.add({
        'user': user.uid,
        'date': dateString,
        'steps_start': currentStepCount,
      });
      print('Document created successfully');

      updateStepsForYesterday();
    } catch (error) {
      print('Error creating document: $error');
    }
  }

  Future<void> updateStepsForYesterday() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User not logged in');
      return;
    }

    // Get yesterday's date
    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    String yesterdayDateString = '${yesterday.day}-${yesterday.month}-${yesterday.year}';

    // Query Firestore to get steps_start for yesterday
    CollectionReference stepsCollection = FirebaseFirestore.instance.collection('steps');
    QuerySnapshot querySnapshot = await stepsCollection
      .where('user', isEqualTo: user.uid)
      .where('date', isEqualTo: yesterdayDateString)
      .get();

    int yesterdaySteps = 0;
    if (querySnapshot.docs.isNotEmpty) {
      // Document exists, retrieve the value of the "steps_start" field
      yesterdaySteps = querySnapshot.docs.first['steps_start'];
    } else {
      print('Document not found for user $user and date $yesterdayDateString');
    }

    // Get the current step count
    int? currentStepCount = await getCurrentStepCount();
    if (currentStepCount == null) {
      print('Error retrieving current step count');
      return;
    }

    CollectionReference gardenCollection = FirebaseFirestore.instance.collection('garden');
    // Update steps count for yesterday
    try {
      await gardenCollection.add({
        'user': user.uid,
        'date': yesterdayDateString,
        'steps': currentStepCount - yesterdaySteps,
      });
      print('Steps updated successfully for yesterday');
    } catch (error) {
      print('Error updating steps for yesterday: $error');
    }
  }

  Future<int?> getCurrentStepCount() async {
    try {
      // Create a temporary stream subscription to get the current step count
      StreamSubscription<StepCount>? subscription =
          Pedometer.stepCountStream.listen(null);

      // Wait for a short duration to allow the pedometer to provide an initial reading
      await Future.delayed(Duration(seconds: 1));

      // Get the current step count
      int? stepCount;
      await subscription.cancel(); // Cancel the subscription immediately after getting the count
      await Pedometer.stepCountStream.first.then((event) {
        stepCount = event.steps;
      });

      return stepCount;
    } catch (e) {
      print('Error retrieving step count: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/';
    if (_stepCount == -1) {
      // Display a loading indicator while step count is being fetched
      return CircularProgressIndicator();
    } else {
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
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
            'Step Count',
            style: TextStyle(
              fontSize: 30,
              shadows: [
                Shadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 2,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          ),
          SizedBox(height: 10),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$_stepCount',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Image.asset(
            imagePath,
            width: 300,
            height: 300,
            fit: BoxFit.contain,
          ),
        ],
      );
    }
  }
}

class StepFunc extends StatefulWidget {
  const StepFunc({
    super.key,
    required this.loggedIn,
  });

  final bool loggedIn;

  @override
  State<StepFunc> createState() => _StepFuncState();
}

class _StepFuncState extends State<StepFunc> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: widget.loggedIn,
            child: StepCounter(),
          ),
          Visibility(
            visible: !widget.loggedIn,
            child: Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  "Welcome to Flowalk! \nTo start using the application go to the Settings page and login or register.",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
