import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ryda/src/onboarding/onboarding_screen.dart';
import 'package:ryda/src/onboarding/onboarding_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final seen = await LocalStorageService.hasSeenOnboarding();
  runApp(ProviderScope(child: MyApp(hasSeenOnboarding: seen)));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: false,
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            textTheme: GoogleFonts.montserratTextTheme()
          ),
          debugShowCheckedModeBanner: false,
          home:
              hasSeenOnboarding
                  ? const HomeScreen(title: "Home")
                  : OnboardingScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

//TODO: Find a better loc.
extension SpacingExtension on SizedBox {
  static SizedBox height(double height) => SizedBox(height: height);
  static SizedBox width(double width) => SizedBox(width: width);
  
  // Common spacing values
  static const SizedBox small = SizedBox(height: 8.0);
  static const SizedBox medium = SizedBox(height: 16.0);
  static const SizedBox large = SizedBox(height: 24.0);
  static const SizedBox extraLarge = SizedBox(height: 32.0);
  
  // Horizontal spacing
  static const SizedBox smallHorizontal = SizedBox(width: 8.0);
  static const SizedBox mediumHorizontal = SizedBox(width: 16.0);
  static const SizedBox largeHorizontal = SizedBox(width: 24.0);
}