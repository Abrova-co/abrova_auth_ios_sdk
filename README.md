<p align="center">
  <a href="https://abrova.ir">
    <img src="https://abrova.ir/icon.svg" alt="Abrova" width="120" />
  </a>
</p>

<h3 align="center">Abrova Auth iOS SDK</h3>

<p align="center">
  Sign-in for your iOS and macOS app's users: anonymous, Apple, Google, e-mail and password, magic link and Telegram, with a user token every Abrova SDK accepts.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.7+-F05138?logo=swift&logoColor=white" alt="Swift 5.7+" />
  <img src="https://img.shields.io/badge/iOS-13.0+-000000?logo=apple&logoColor=white" alt="iOS 13+" />
  <img src="https://img.shields.io/badge/macOS-12.0+-000000?logo=apple&logoColor=white" alt="macOS 12+" />
  <img src="https://img.shields.io/badge/SPM-compatible-orange" alt="SPM Compatible" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="MIT License" />
</p>

---

## Installation

### Swift Package Manager (SPM)

The SDK is published on [Abrova Center](https://center.abrova.ir). Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://center.abrova.ir/abrova/abrova-auth-ios-sdk.git", from: "0.1.1"),
]
```

Then add `"AbrovaAuth"` to your target's dependencies. Or in Xcode: **File > Add Package Dependencies** and enter:

```
https://center.abrova.ir/abrova/abrova-auth-ios-sdk.git
```

### CocoaPods

```ruby
pod 'AbrovaAuth', :git => 'https://center.abrova.ir/abrova/abrova-auth-ios-sdk.git', :tag => '0.1.1'
```

## Quick start

Turn Abrova Auth on for your project in the Abrova Console and enable the
sign-in methods you want. Then, at app start:

```swift
import AbrovaAuth

AbrovaAuth.shared.configure(apiKey: "ab_live_YOUR_PUBLIC_KEY")
```

A session from an earlier launch is restored automatically.

```swift
try await AbrovaAuth.shared.signInAnonymously()
print(AbrovaAuth.shared.currentUserId ?? "signed out")
```

## Sign in

```swift
let auth = AbrovaAuth.shared

try await auth.signInAnonymously()
try await auth.signIn(email: "ana@example.com", password: "a-long-password")
let result = try await auth.signUp(email: "ana@example.com", password: "a-long-password",
                                   redirectURL: "https://example.com/verify")

// Magic link: send it, then sign in with the link the app is opened with.
try await auth.sendMagicLink(email: "ana@example.com", redirectURL: "https://example.com/magic")
try await auth.signInWithMagicLink(url: openedURL)

// Telegram: the code arrives in the project's bot.
let code = try await auth.requestTelegramCode(phone: "+37491234567")
if !code.sent, let url = code.botURL { await UIApplication.shared.open(url) }
try await auth.verifyTelegramCode(phone: "+37491234567", code: "123456")
```

Show only the methods the project offers:

```swift
let methods = try await auth.getMethods()
if methods.isEnabled("apple") { /* show the Apple button */ }
```

### Sign in with Apple

Add the **Sign in with Apple** capability to your app and your bundle id to
the project's Apple settings in the Console. Then:

```swift
try await AbrovaAuth.shared.signInWithAppleNative()
```

If you run the Apple request yourself, use a nonce:

```swift
let rawNonce = AbrovaNonce.generate()
request.nonce = AbrovaNonce.sha256(rawNonce)   // to Apple
// ... when Apple answers:
try await auth.signInWithApple(idToken: idToken, rawNonce: rawNonce,
                               authorizationCode: code, fullName: name)
```

Pass the authorization code: it lets the Apple sign-in be revoked when the
user deletes the account.

### Sign in with Google

Request the Google ID token with `AbrovaNonce.sha256(rawNonce)` as its nonce,
then pass the raw nonce to Abrova. The nonce is required (16-256 characters;
`AbrovaNonce.generate()` makes one) and works once:

```swift
let rawNonce = AbrovaNonce.generate()
// Google Sign-In: nonce = AbrovaNonce.sha256(rawNonce)
try await auth.signInWithGoogle(idToken: idToken, rawNonce: rawNonce)
```

## Upgrade an anonymous user

Linking keeps the user's id, so everything they created stays theirs:

```swift
do {
    try await auth.linkGoogle(idToken: idToken, rawNonce: rawNonce)
    // or linkApple(...), linkPassword(email:password:)
} catch let error as AbrovaAuthError where error.code == .providerAlreadyLinked {
    // This Google account already belongs to another user.
}
```

## Use with other Abrova SDKs

Abrova Sync, Chat and Push trust the signed-in user through a token provider:

```swift
let auth = AbrovaAuth.shared

// Sync
sync.userTokens.provider = auth.tokenProvider

// Push
AbrovaPushConfig(apiKey: key, tokenProvider: auth.tokenProvider)

// Chat
AbrovaChatConfig(apiKey: key, userId: auth.currentUserId!, tokenProvider: auth.strictTokenProvider)
```

`tokenProvider` returns nil when nobody is signed in; `strictTokenProvider`
throws instead. Both return a token that is refreshed before it expires.

## Session

```swift
auth.currentUserId                  // nil when signed out
let user = try await auth.me()      // profile: anonymous, providers, ...

let listener = auth.addAuthStateListener { userId in
    // called on sign-in, sign-out and when a session ends
}
listener.remove()

await auth.signOut()                // this device
try await auth.signOutEverywhere()  // every device
try await auth.deleteAccount()      // required by the App Store for apps with sign-in
```

The refresh token is stored in the Keychain on this device only; the access
token stays in memory. A session revoked elsewhere signs the user out here; a
network error does not.

## Errors

Every error is a `AbrovaAuthError`. Branch on `code` (for example
`.invalidCredentials`, `.emailTaken`, `.weakPassword`, `.rateLimited` with
`retryAfterSec`, `.providerAlreadyLinked`); `message` is an English hint for
developers.

## Example app

[`Example/`](Example) is a SwiftUI app with anonymous sign-in, e-mail sign-up
and sign-in, sign-out and account deletion. Open
`Example/AbrovaAuthExample.xcodeproj`, run it on a simulator and paste your
public key (`ab_live_...`) into its API key field. The project is generated
from `Example/project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen).

## Documentation

- [Abrova Auth Docs](https://abrova.ir/cloud/abrova-auth/docs)
- [iOS SDK guide](https://abrova.ir/cloud/abrova-auth/docs/sdks-ios)

## Support

- **Documentation**: [Abrova Auth Docs](https://abrova.ir/cloud/abrova-auth/docs)
- **Issues**: [GitHub Issues](https://github.com/Abrova-co/abrova_auth_ios_sdk/issues)
- **Email**: support@abrova.ir

## License

MIT License — see [LICENSE](LICENSE) for details.
