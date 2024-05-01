import 'package:flutter/material.dart';

import 'package:intl/intl.dart'; 



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
      initialPage: _currentMonth.month - 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Garden'),
      ),
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
                final month = DateTime(_currentMonth.year, _currentMonth.month - index, 1);
                return MonthItem(month: month);
              },
            ),
          ),
        ],
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
    return Container(
      alignment: Alignment.center,
      child: Text(
        DateFormat('MMMM yyyy').format(month),
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class GardenFunc extends StatefulWidget {
  const GardenFunc({
    super.key,
    required this.loggedIn,
  });

  final bool loggedIn;

  @override
  State<GardenFunc> createState() => _GardenFunc();
}

class _GardenFunc extends State<GardenFunc> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Visibility(
          visible: widget.loggedIn,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Garden(),
            //child: const Text("garden"),
          ),
        ),
        Visibility(
          visible: !widget.loggedIn,
          child: const Text("pls login"),
        ),
      ],
    );
  }
}
