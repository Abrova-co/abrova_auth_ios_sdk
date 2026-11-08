# Changelog

## 0.4.0

- Ready-made sign-in screens, like FirebaseUI: `if let result = await AbrovaSignIn.present(from: self) { ... }`. It
  opens full screen on iPhone and as a sheet on iPad, and answers the signed-in user (nil when closed). It cannot be
  closed while a sign-in runs. `AbrovaSignInView(onSignedIn:)` puts the same form in any SwiftUI screen, and
  `AbrovaSignInController` holds its state. iOS 15 and later.
  - Shows only the methods turned on in the Console: e-mail and password (sign in, create account, forgot password),
    magic link, Telegram, Google, Apple and guest.
  - English and Persian (right to left), from the app's language or `languageCode`. The e-mails Abrova sends follow
    the screen's language, unless you set `languageCode` yourself.
  - Follows your app's tint colour and dark mode; `appName` and `logo` for the title.
  - Google and Apple: pass a function that gets an ID token for the given hashed nonce (for example with Google
    Sign-In); `AbrovaSignInOptions.nativeApple` runs Sign in with Apple for you. Magic link: pass
    `magicLinkRedirectURL` (a link that opens your app).
  - "Continue as guest" shows only with `allowGuest: true`: every guest is a new user and counts toward your plan.
  - No new dependencies.
- `sendPasswordReset(email:redirectURL:)`: `redirectURL` is optional; without it the link opens Abrova's own reset
  page.
- `baseURL`: the Abrova Auth server the client talks to.

## 0.3.0

- `languageCode` and `useAppLanguage()`, like Firebase: the language of the e-mails Abrova sends this user (confirm
  e-mail, password reset, magic link), for example `AbrovaAuth.shared.languageCode = "fa"`. Unset, the project's
  template language from the Console applies.

## 0.2.0

- `getTokenResult(forceRefresh:)`: the access token with its decoded fields, like Firebase's `AuthTokenResult`.
  `claims` holds the custom claims your server set with `setCustomUserClaims` (for example `plan`, `role`), plus
  `sub`, `iat`, `exp`, `auth_time` and `amr`; also `expirationDate`, `issuedAtDate`, `authDate` and `signInProvider`.
  For showing things in the app; access is still decided on the server. Pass `forceRefresh: true` right after your
  server changed the claims.

## 0.1.1

- Sends `X-Abrova-SDK: auth-ios/0.1.1` with every request so Abrova can show
  which SDK versions are in use. No behaviour change.

## 0.1.0

- First release.
- Sign-in methods: anonymous, Apple, Google, e-mail and password, magic link
  and Telegram code.
- Upgrade an anonymous user with `linkApple`, `linkGoogle` and
  `linkPassword`; the user keeps its id.
- `signInWithAppleNative()` runs Sign in with Apple, nonce included.
- `rawNonce` is required for Apple and Google sign-in and linking.
- The refresh token is kept in the Keychain (this device only); the access
  token stays in memory and is refreshed before it expires, one refresh at a
  time.
- `tokenProvider` and `strictTokenProvider` plug straight into the other
  Abrova SDKs.
- `signOut()`, `signOutEverywhere()`, `deleteAccount()` and an auth state
  listener.
