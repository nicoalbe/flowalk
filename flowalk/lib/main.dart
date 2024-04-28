import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';     
import 'package:google_fonts/google_fonts.dart';
import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedometer/pedometer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app_state.dart';
import 'homepage.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}
/*
void callbackDispatcher() async {
  // Get the current user
  await Future.delayed(Duration(seconds: 1));
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
*/
int calculateInitialDelay() {
  DateTime now = DateTime.now();
  DateTime midnight = DateTime(now.year, now.month, now.day + 1); // Next midnight
  Duration delay = midnight.difference(now); // Time until midnight
  return delay.inSeconds;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
 /* try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Handle the error or return to prevent further execution
    return;
  }

  Workmanager().initialize(callbackDispatcher);

  // Schedule the task to run every 30 minutes
  Workmanager().registerPeriodicTask(
    'thirtyMinutesTask', // Unique name for the task
    'thirtyMinutesTask', // Task identifier
    frequency: Duration(minutes: 30), // Repeat every 30 minutes
  );
  */

  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const App()),
  ));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return SignInScreen(
              actions: [
                ForgotPasswordAction(((context, email) {
                  final uri = Uri(
                    path: '/sign-in/forgot-password',
                    queryParameters: <String, String?>{
                      'email': email,
                    },
                  );
                  context.push(uri.toString());
                })),
                AuthStateChangeAction(((context, state) {
                  final user = switch (state) {
                    SignedIn state => state.user,
                    UserCreated state => state.credential.user,
                    _ => null
                  };
                  if (user == null) {
                    return;
                  }
                  if (state is UserCreated) {
                    user.updateDisplayName(user.email!.split('@')[0]);
                  }
                  if (!user.emailVerified) {
                    user.sendEmailVerification();
                    const snackBar = SnackBar(
                        content: Text(
                            'Please check your email to verify your email address'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  context.pushReplacement('/');
                })),
              ],
            );
          },
          routes: [
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) {
                final arguments = state.uri.queryParameters;
                return ForgotPasswordScreen(
                  email: arguments['email'],
                  headerMaxExtent: 200,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            return ProfileScreen(
              providers: const [],
              actions: [
                SignedOutAction((context) {
                  context.pushReplacement('/');
                }),
              ],
            );
          },
        ),
      ],
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flowalk',
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
              highlightColor: Colors.deepPurple,
            ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}