import CryptoKit
import Foundation
import Security

/// Nonces for Sign in with Apple and Google.
///
/// Give the provider `AbrovaNonce.sha256(raw)` and give Abrova Auth the raw
/// value. Abrova Auth checks that they match and accepts each nonce once, so
/// a captured ID token cannot be replayed.
///
/// ```swift
/// let raw = AbrovaNonce.generate()
/// request.nonce = AbrovaNonce.sha256(raw)          // to Apple / Google
/// try await AbrovaAuth.shared.signInWithApple(idToken: idToken, rawNonce: raw)
/// ```
public enum AbrovaNonce {
    private static let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")

    /// A random nonce from the system's secure random generator.
    /// Abrova Auth accepts 16 to 256 characters.
    public static func generate(length: Int = 32) -> String {
        precondition(length >= 16 && length <= 256, "Nonce length must be 16-256")
        var result = ""
        result.reserveCapacity(length)
        while result.count < length {
            var bytes = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            precondition(status == errSecSuccess, "SecRandomCopyBytes failed")
            for byte in bytes where result.count < length {
                // Reject bytes past the last multiple of the charset size: no modulo bias.
                let limit = 256 - (256 % charset.count)
                if Int(byte) < limit { result.append(charset[Int(byte) % charset.count]) }
            }
        }
        return result
    }

    /// Lowercase hex SHA-256 of `input`: what the provider must receive as its nonce.
    public static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
