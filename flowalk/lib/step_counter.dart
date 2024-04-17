import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'src/widgets.dart';
import 'package:pedometer/pedometer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';



class StepCounter extends StatefulWidget {
  @override
  _StepCounterState createState() => _StepCounterState();
}

class _StepCounterState extends State<StepCounter> {
  int _stepCount = 7; // Initialize _stepCount as an integer
  StreamSubscription<StepCount>? _subscription; // Ensure correct type
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    super.dispose();
    _stopListening();
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



  void _stopListening() {
    _subscription?.cancel();
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
    print(steps);
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
        // Document exists, retrieve the value of the "steps_start" field
        int stepsStart = querySnapshot.docs.first['steps_start'];
        print('okk');
        return stepsStart;
      } else {
        // Document does not exist
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
  } catch (error) {
    print('Error creating document: $error');
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
      await subscription?.cancel(); // Cancel the subscription immediately after getting the count
      await Pedometer.stepCountStream.first.then((event) {
        stepCount = event.steps;
      });

      return stepCount;
    } catch (e) {
      print('Error retrieving step count: $e');
      return null;
    }
  }

  Future<int> addOrUpdateSteps(String userId, String dateString, int stepsPedo) async {
    CollectionReference stepsCollection = FirebaseFirestore.instance.collection("steps");

    try {
      QuerySnapshot querySnapshot = await stepsCollection
          .where("user", isEqualTo: userId)
          .where("date", isEqualTo: dateString)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Document exists, update it
        String docId = querySnapshot.docs.first.id;
        int stepsDb = querySnapshot.docs.first['steps'];

        // Update document
        await stepsCollection.doc(docId).update({"steps": stepsPedo});

        print("Document updated successfully");
      } else {
        // Document does not exist, add new document
        await stepsCollection.add({
          "user": userId,
          "steps": stepsPedo,
          "date": dateString,
        });

        print('Document added successfully');
      }

      return stepsPedo;
    } catch (error) {
      print("Error retrieving or updating document: $error");
      return -1; // Return an error code or handle the error accordingly
    }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Step Count:',
          style: TextStyle(fontSize: 24),
        ),
        SizedBox(height: 10),
        Text(
          '$_stepCount',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}


class StepFunc extends StatelessWidget {
  const StepFunc({
    super.key,
    required this.loggedIn,
  });

  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /*Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 8),
          child: StyledButton(
              onPressed: () {
                !loggedIn ? context.push('/sign-in') : const Text('Logout');
              },
              child: !loggedIn ? const Text('pls login') : const Text('Logout')),
        ),*/
        Visibility(
          visible: loggedIn,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: StepCounter(),
          ),
        )
      ],
    );
  }
}


