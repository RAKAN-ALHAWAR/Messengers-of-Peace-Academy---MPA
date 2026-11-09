import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let packageChannel = FlutterMethodChannel(
      name: "mopa/package_info",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    packageChannel.setMethodCallHandler { call, result in
      guard call.method == "getVersion" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
        result(FlutterError(code: "package_info_unavailable", message: nil, details: nil))
        return
      }
      result(["version": version, "buildNumber": build])
    }
  }
}
