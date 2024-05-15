 import 'package:flutter/material.dart';           
import 'package:provider/provider.dart';          


import 'app_state.dart';
import 'get_garden.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Consumer<ApplicationState>(
            builder: (context,appState,_) => GardenFunc(loggedIn:appState.loggedIn)
            ),
        ],
      ),
    );
  }
}