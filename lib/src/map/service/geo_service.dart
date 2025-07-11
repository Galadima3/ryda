// import 'dart:async';
// import 'dart:developer';
// import 'dart:io'; // Import for platform specific checks
// import 'package:geolocator_android/geolocator_android.dart';
// import 'package:geolocator_platform_interface/geolocator_platform_interface.dart' show AndroidNotificationConfig;
// import 'package:geolocator/geolocator.dart';
// import 'package:ryda/src/map/model/geo_model.dart';

// /// A repository for handling geolocation-related operations specifically tailored for a maps app.
// class GeolocationRepository {
//   /// Stream subscription to manage continuous location updates.
//   StreamSubscription<Position>? _positionStreamSubscription;

//   /// Checks if geolocation permission is currently granted.
//   ///
//   /// Returns `true` if permission is granted (either [LocationPermission.whileInUse]
//   /// or [LocationPermission.always]), `false` otherwise.
//   Future<bool> isPermissionGranted() async {
//     final permission = await Geolocator.checkPermission();
//     return permission == LocationPermission.whileInUse ||
//         permission == LocationPermission.always;
//   }

//   /// Requests geolocation permission from the user.
//   ///
//   /// For a maps app, you might consider requesting `LocationPermission.always`
//   /// if you need background location updates. However, it's generally better
//   /// to request `whileInUse` first and then `always` if the user needs
//   /// a feature that requires it (e.g., turn-by-turn navigation in the background).
//   ///
//   /// Returns the [LocationPermission] status after the request.
//   Future<LocationPermission> requestPermission() async {
//     return await Geolocator.requestPermission();
//   }

//   /// Checks if location services are enabled on the device.
//   /// This is crucial for any location-based app.
//   Future<bool> isLocationServiceEnabled() async {
//     return await Geolocator.isLocationServiceEnabled();
//   }

//   /// Retrieves the current device location coordinates (one-time fetch).
//   ///
//   /// This method first checks for permission and service enablement.
//   /// If not granted or enabled, it throws a [GeolocationException].
//   ///
//   /// Throws:
//   /// - [GeolocationException] if location services are disabled,
//   ///   permission is permanently denied, or if there's an error
//   ///   getting the location.
//   Future<GeoCoordinates> getCurrentLocationOnce() async {
//     bool serviceEnabled = await isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw const GeolocationException(
//         'Location services are disabled. Please enable them in your device settings.',
//       );
//     }

//     LocationPermission permission = await Geolocator.checkPermission();

//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw const GeolocationException(
//           'Location permissions are denied. Please grant permission in settings.',
//         );
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       throw const GeolocationException(
//         'Location permissions are permanently denied. We cannot request permissions. Please enable in app settings.',
//       );
//     }

//     try {
//       final position = await Geolocator.getCurrentPosition(
//         locationSettings: const LocationSettings(
//           accuracy:
//               LocationAccuracy.bestForNavigation, // High accuracy for maps
//           timeLimit: Duration(seconds: 10), // Set a reasonable timeout
//         ),
//       );
//       return GeoCoordinates(
//         latitude: position.latitude,
//         longitude: position.longitude,
//       );
//     } catch (e) {
//       log("Error getting one-time location: $e");
//       throw GeolocationException("Failed to get current location: $e");
//     }
//   }

//   /// Starts a stream of continuous location updates.
//   ///
//   /// The stream will emit [GeoCoordinates] whenever a new location
//   /// is available based on the specified [locationSettings].
//   ///
//   /// This method handles permissions and service enablement. If any issue
//   /// occurs, it will throw a [GeolocationException].
//   ///
//   /// [distanceFilter]: The minimum distance (in meters) a device must move
//   ///   before an update is generated. Crucial for maps to avoid excessive updates.
//   /// [intervalDuration]: The desired interval (in milliseconds) for active
//   ///   location updates (Android only).
//   /// [forceLocationManager]: On Android, forces the use of the older LocationManager
//   ///   API instead of FusedLocationProviderClient. Might be useful for specific
//   ///   accuracy needs, but generally FusedLocationProviderClient is preferred.
//   /// [androidForegroundNotificationConfig]: (Android only) Configuration for a foreground
//   ///   notification to keep the app alive when going to the background. Necessary
//   ///   for continuous background updates.
//   ///
//   Stream<GeoCoordinates> startLocationUpdates({
//   double distanceFilter = 5.0, // Update every 5 meters for smooth tracking
//   Duration? intervalDuration,
//   bool forceLocationManager = false,
//   AndroidNotificationConfig? androidForegroundNotificationConfig, // For Android background updates
// }) async* { // Marked as async* for yield statements
//   bool serviceEnabled = await Geolocator.isLocationServiceEnabled(); // Re-check service enabled
//   if (!serviceEnabled) {
//     throw const GeolocationException(
//         'Location services are disabled. Please enable them in your device settings.');
//   }

//   LocationPermission permission = await Geolocator.checkPermission(); // Re-check permission

//   // For continuous updates, `always` permission is often needed for true background tracking
//   // but `whileInUse` can work if the app remains in the foreground.
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied) {
//       throw const GeolocationException(
//           'Location permissions are denied for continuous updates. Please grant permission in settings.');
//     }
//   }

//   if (permission == LocationPermission.deniedForever) {
//     throw const GeolocationException(
//         'Location permissions are permanently denied. We cannot request permissions for continuous updates. Please enable in app settings.');
//   }

//   // If background location is desired on Android, ensure 'always' permission is granted
//   if (Platform.isAndroid &&
//       androidForegroundNotificationConfig != null &&
//       permission != LocationPermission.always) {
//     log('Warning: Android background location updates requested but "always" permission not granted. This may cause issues.');
//     // You might want to throw an exception here or prompt the user again.
//     // For a maps app, "always" permission is typically required for full background features.
//   }

//   try {
//     // Create platform-specific settings for LocationSettings
//     LocationSettings locationSettings;
//     if (Platform.isAndroid) {
//       locationSettings = AndroidSettings(
//         accuracy: LocationAccuracy.bestForNavigation,
//         distanceFilter: distanceFilter.toInt(), // distanceFilter in AndroidSettings expects int
//         forceLocationManager: forceLocationManager,
//         intervalDuration: intervalDuration,
//         foregroundNotificationConfig: androidForegroundNotificationConfig,
//       );
//     } else if (Platform.isIOS) {
//       locationSettings = AppleSettings( // Renamed from iOSSettings to AppleSettings
//         accuracy: LocationAccuracy.bestForNavigation,
//         distanceFilter: distanceFilter.toInt(), // distanceFilter in AppleSettings expects int
//         activityType: ActivityType.fitness, // Example: for fitness tracking
//         allowBackgroundLocationUpdates: true,
//         showBackgroundLocationIndicator: true, // Show the blue bar when in background
//       );
//     } else {
//       // Default settings for other platforms or if platform is unknown
//       locationSettings = LocationSettings(
//         accuracy: LocationAccuracy.bestForNavigation,
//         distanceFilter: distanceFilter.toInt(),
//       );
//     }

//     // Cancel any existing stream before starting a new one
//     // In a class, this would be `_positionStreamSubscription?.cancel();`
//     // Since this is just the function, you'd handle the subscription management
//     // in the calling class that uses this stream.

//     // Use yield* to re-emit events from the underlying Geolocator stream
//     yield* Geolocator.getPositionStream(locationSettings: locationSettings)
//         .map((position) => GeoCoordinates(
//             latitude: position.latitude, longitude: position.longitude))
//         .handleError((e) {
//       // Handle errors that occur within the stream itself
//       log("Error in location stream: $e");
//       // If `_positionStreamSubscription` was accessible here, you'd cancel it.
//       // For this isolated function, the `handleError` itself will propagate the error.
//       throw GeolocationException(
//           "Error receiving location updates: $e"); // Re-throw as custom exception
//     });
//   } catch (e) {
//     log("Error starting location updates: $e");
//     // Catch errors during the setup of the stream
//     throw GeolocationException("Failed to start location updates: $e");
//   }
// }

//   /// Stops continuous location updates.
//   void stopLocationUpdates() {
//     _positionStreamSubscription?.cancel();
//     _positionStreamSubscription = null;
//     log('Location updates stopped.');
//   }
// }

// /// Custom exception for geolocation-related errors.
// class GeolocationException implements Exception {
//   final String message;

//   const GeolocationException(this.message);

//   @override
//   String toString() => 'GeolocationException: $message';
// }
