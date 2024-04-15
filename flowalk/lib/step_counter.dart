import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'src/widgets.dart';
import 'package:pedometer/pedometer.dart';



class StepCounter extends StatefulWidget {
  @override
  _StepCounterState createState() => _StepCounterState();
}

class _StepCounterState extends State<StepCounter> {
  int _stepCount = 0; // Initialize _stepCount as an integer
  StreamSubscription<StepCount>? _subscription; // Ensure correct type

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
      (StepCount stepCount) {
        setState(() {
          _stepCount = stepCount.steps; // Convert to int
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


