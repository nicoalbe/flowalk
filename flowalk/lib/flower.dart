import 'package:flutter/material.dart';           
import 'package:provider/provider.dart';          
import 'app_state.dart';
import 'step_counter.dart';

class FlowerPage extends StatefulWidget {
  const FlowerPage({super.key});

  @override
  State<FlowerPage> createState() => _FlowerPageState();
}

class _FlowerPageState extends State<FlowerPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Consumer<ApplicationState>(
            builder: (context,appState,_) => StepFunc(loggedIn:appState.loggedIn)
            ),
        ],
      ),
    );
  }
}