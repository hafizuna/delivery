import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Load Google Maps API key from environment or use fallback
    let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"] ?? "AIzaSyA_lmuxAbk7zGaWw1DVP9H_vRUQifAOP-I"
    GMSServices.provideAPIKey(apiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
