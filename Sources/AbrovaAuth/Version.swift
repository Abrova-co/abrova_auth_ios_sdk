import Foundation

/// The SDK version. Keep it equal to `s.version` in AbrovaAuth.podspec — a test checks it.
let abrovaAuthSDKVersion = "0.1.1"

/// Sent as `X-Abrova-SDK` with every request, so Abrova can show which SDK versions are in use.
let abrovaAuthSDKHeader = "auth-ios/\(abrovaAuthSDKVersion)"
