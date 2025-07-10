import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ryda/main.dart';
import 'package:ryda/src/auth/views/screens/login_view.dart';
import 'package:ryda/src/onboarding/views/onboarding_screen.dart';

class App extends StatefulWidget {
  final bool hasSeenOnboarding;
  const App({super.key, required this.hasSeenOnboarding});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: false,
      builder: (context, child) {
        return MaterialApp(
          title: 'Ryda App',
          theme: ThemeData(
            fontFamily: 'Montserrat',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home:
              widget.hasSeenOnboarding
                  ? StreamBuilder<User?>(
                    stream: _authStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasData) {
                        return const HomeScreen(title: "Home");
                      } else {
                        return LoginView();
                      }
                    },
                  )
                  : OnboardingScreen(),
        );
      },
    );
  }
}
