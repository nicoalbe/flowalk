// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flowalk/setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pedometer/pedometer.dart';

import 'app_state.dart';
import 'src/authentication.dart';
import 'src/widgets.dart';
import 'step_counter.dart';
import 'flower.dart';
import 'setting.dart';
//import 'guest_book.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<StepCount> _stepCountStream;
  String _steps = '?';

  int _selectedIndex = 1;

  static List<Widget> _pages = <Widget>[
    Container(color: Color.fromARGB(255, 17, 117, 41), child: Center(child: Text('Page 1'))),
    FlowerPage(),
    SettingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Page 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Page 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Page 3',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
