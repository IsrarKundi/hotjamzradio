import Flutter
import UIKit
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
    
    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // Allow app to continue even if some services fail
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle background audio
  override func applicationWillResignActive(_ application: UIApplication) {
    // Handle app going to background while audio is playing
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
    // Handle app returning to foreground
  }
}
