// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';           
import 'package:provider/provider.dart';          


import 'app_state.dart';
import 'step_counter.dart';
//import 'guest_book.dart';

class FlowerPage extends StatefulWidget {
  const FlowerPage({super.key});

  @override
  State<FlowerPage> createState() => _FlowerPageState();
}

class _FlowerPageState extends State<FlowerPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flowalk'),
      ),
      body: ListView(
        children: <Widget>[
          Consumer<ApplicationState>(
            builder: (context,appState,_) => StepFunc(loggedIn:appState.loggedIn)
            ),
          const Divider(
            height: 8,
            thickness: 1,
            indent: 8,
            endIndent: 8,
            color: Colors.grey,
          ),
        ],
      ),
      /*body: IndexedStack(
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
      ),*/
    );
  }
}