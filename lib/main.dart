import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ryda/firebase_options.dart';
import 'package:ryda/src/auth/views/login_view.dart';
import 'package:ryda/src/onboarding/views/onboarding_screen.dart';
import 'package:ryda/src/onboarding/service/onboarding_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

// Initializes app resources, including Firebase and checking onboarding status.
Future<bool> initializeAppResources() async {
  // Ensure Firebase is initialized for the current platform.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Load Google Fonts (Montserrat in this case) to ensure they are ready.
  await GoogleFonts.pendingFonts([GoogleFonts.montserrat()]);
  // Check if the user has already seen the onboarding screen.
  final seen = await LocalStorageService.hasSeenOnboarding();
  return seen;
}

void main() async {
  // Ensure Flutter widgets binding is initialized before any Flutter-specific calls.
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Preserve the native splash screen until app resources are loaded.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  // Initialize app resources and get the onboarding status.
  final seen = await initializeAppResources();
  // Remove the native splash screen once resources are loaded.
  FlutterNativeSplash.remove();
  // Run the Flutter application, wrapping it with ProviderScope for Riverpod.
  runApp(ProviderScope(child: MyApp(hasSeenOnboarding: seen)));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive UI design.
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Standard design size for scaling.
      minTextAdapt: false, // Prevents text from adapting below a certain size.
      builder: (context, child) {
        return MaterialApp(
          title: 'Ryda App', // Application title.
          theme: ThemeData(
            // Apply Montserrat font theme to the entire app.
            textTheme: GoogleFonts.montserratTextTheme(),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // Basic color scheme.
            useMaterial3: true, // Enable Material 3 design.
          ),
          debugShowCheckedModeBanner: false, // Hide debug banner.
          home: hasSeenOnboarding
              ? StreamBuilder<User?>(
                  // Listen to Firebase authentication state changes.
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    // Show a loading indicator while checking auth state.
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      // If user is logged in, show the HomeScreen.
                      return const HomeScreen(title: "Home");
                    } else {
                      // If no user is logged in, show the LoginScreen.
                      return const LoginView();
                    }
                  },
                )
              : OnboardingScreen(), // If onboarding not seen, show OnboardingScreen.
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
    final user = FirebaseAuth.instance.currentUser; // Get current user info
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error logging out: $e')),
                );
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You are logged in as:',
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              user?.email ?? user?.uid ?? 'Guest User', // Display user email or UID
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.h),
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
