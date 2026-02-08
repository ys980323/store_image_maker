import Flutter
import Photos
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let imageExporterChannelName = "store_image_maker/image_exporter"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: imageExporterChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        self?.handleImageExport(call: call, result: result)
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleImageExport(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "saveImageToPhotos" else {
      complete(result, with: FlutterMethodNotImplemented)
      return
    }

    guard
      let args = call.arguments as? [String: Any],
      let typedData = args["bytes"] as? FlutterStandardTypedData
    else {
      complete(
        result,
        with:
        FlutterError(
          code: "invalid_arguments",
          message: "PNGバイト列が渡されていません。",
          details: nil
        )
      )
      return
    }

    saveImageToPhotos(bytes: typedData.data, result: result)
  }

  private func saveImageToPhotos(bytes: Data, result: @escaping FlutterResult) {
    let requestAndSave: () -> Void = { [weak self] in
      self?.performPhotoSave(bytes: bytes, result: result)
    }

    if #available(iOS 14, *) {
      let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
      handleAuthorizationStatus(status, requestAndSave: requestAndSave, result: result)
      return
    }

    let status = PHPhotoLibrary.authorizationStatus()
    handleAuthorizationStatus(status, requestAndSave: requestAndSave, result: result)
  }

  private func handleAuthorizationStatus(
    _ status: PHAuthorizationStatus,
    requestAndSave: @escaping () -> Void,
    result: @escaping FlutterResult
  ) {
    switch status {
    case .authorized, .limited:
      requestAndSave()
    case .notDetermined:
      requestPhotoAuthorization { authorized in
        if authorized {
          requestAndSave()
        } else {
          complete(
            result,
            with:
            FlutterError(
              code: "permission_denied",
              message: "写真への保存権限が許可されていません。",
              details: nil
            )
          )
        }
      }
    case .denied, .restricted:
      complete(
        result,
        with:
        FlutterError(
          code: "permission_denied",
          message: "写真への保存権限が許可されていません。",
          details: nil
        )
      )
    @unknown default:
      complete(
        result,
        with:
        FlutterError(
          code: "permission_unknown",
          message: "写真保存の権限状態を判定できませんでした。",
          details: nil
        )
      )
    }
  }

  private func requestPhotoAuthorization(completion: @escaping (Bool) -> Void) {
    if #available(iOS 14, *) {
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        completion(status == .authorized || status == .limited)
      }
      return
    }

    PHPhotoLibrary.requestAuthorization { status in
      completion(status == .authorized)
    }
  }

  private func performPhotoSave(bytes: Data, result: @escaping FlutterResult) {
    var localIdentifier: String?
    PHPhotoLibrary.shared().performChanges({
      let request = PHAssetCreationRequest.forAsset()
      let options = PHAssetResourceCreationOptions()
      options.uniformTypeIdentifier = "public.png"
      request.addResource(with: .photo, data: bytes, options: options)
      localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
    }) { success, error in
      if let error {
        complete(
          result,
          with:
          FlutterError(
            code: "save_failed",
            message: error.localizedDescription,
            details: nil
          )
        )
        return
      }

      if success, let localIdentifier {
        complete(result, with: localIdentifier)
        return
      }

      complete(
        result,
        with:
        FlutterError(
          code: "save_failed",
          message: "写真の保存に失敗しました。",
          details: nil
        )
      )
    }
  }

  private func complete(_ result: @escaping FlutterResult, with payload: Any?) {
    DispatchQueue.main.async {
      result(payload)
    }
  }
}
