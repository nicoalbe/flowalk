import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider, PhoneAuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'src/authentication.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController _stepGoalController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Consumer<ApplicationState>(
                builder: (context, appState, _) => AuthFunc(
                  loggedIn: appState.loggedIn,
                  signOut: () {
                    FirebaseAuth.instance.signOut();
                  },
                ),
              ),
              TextFormField(
                controller: _stepGoalController,
                decoration: const InputDecoration(labelText: 'Step Goal'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a step goal';
                  }
                  final int goal = int.tryParse(value)!;
                  if (goal <= 0) {
                    return 'Step goal must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final int goal = int.parse(_stepGoalController.text);
                    final String? userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId != null) {
                      await FirebaseFirestore.instance.collection('goals').doc(userId).set(
                        {
                          'user': userId,
                          'goal': goal,
                        },
                        SetOptions(merge: true),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Step goal updated successfully')),
                      );
                      // Trigger a rebuild of the FutureBuilder to update the displayed goal
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error: User not logged in')),
                      );
                      
                    }
                  }
                },
                child: const Text('Set Goal'),
              ),
              const SizedBox(height: 16),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('goals').doc(FirebaseAuth.instance.currentUser?.uid).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text('No step goal set');
                    
                  } else {
                    final goal = snapshot.data!.get('goal');
                    return Text('Current step goal: $goal');
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "As part of a healty life, we suggest a daily step goal of 8000-10000 steps.",
                  style: TextStyle(fontStyle: FontStyle.italic),),
              ),
              const Divider(height: 40,),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stepGoalController.dispose();
    super.dispose();
  }
}
