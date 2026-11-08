import XCTest
@testable import AbrovaAuth

/// The ready-made sign-in screen against a real Abrova Auth server. Skipped unless these are set:
/// ABROVA_AUTH_LIVE_KEY (a project with anonymous, password without a required confirmation and magic link on),
/// ABROVA_AUTH_LIVE_URL, ABROVA_AUTH_LIVE_EMAIL (a new address), ABROVA_AUTH_LIVE_PASSWORD and
/// ABROVA_AUTH_LIVE_MAGIC_URL (one of the project's allowed redirect URLs).
@MainActor
final class LiveSignInTests: XCTestCase {
    func testSignInScreenAgainstARealServer() async throws {
        let env = ProcessInfo.processInfo.environment
        guard let key = env["ABROVA_AUTH_LIVE_KEY"], !key.isEmpty,
              let url = env["ABROVA_AUTH_LIVE_URL"].flatMap(URL.init(string:)),
              let email = env["ABROVA_AUTH_LIVE_EMAIL"], let password = env["ABROVA_AUTH_LIVE_PASSWORD"],
              let magic = env["ABROVA_AUTH_LIVE_MAGIC_URL"] else {
            throw XCTSkip("ABROVA_AUTH_LIVE_* not set")
        }
        let auth = AbrovaAuth()
        auth.configure(apiKey: key, baseURL: url, urlSession: .shared, storage: MemorySessionStorage(nil))
        let options = AbrovaSignInOptions(languageCode: "fa", allowGuest: true, magicLinkRedirectURL: magic)
        var signedIn: [AuthResult] = []

        // Sign up.
        let first = AbrovaSignInController(auth: auth, options: options) { signedIn.append($0) }
        await first.load().value
        XCTAssertEqual(first.screen, .home, first.errorText ?? "")
        XCTAssertTrue(first.showPassword && first.showMagicLink && first.showGuest)
        XCTAssertEqual(auth.languageCode, "fa")
        first.go(.signUp)
        first.email = email
        first.password = password
        await first.signUp()?.value
        XCTAssertNil(first.error, first.errorText ?? "")
        let user = try XCTUnwrap(signedIn.last?.userId)
        print("signed up \(user)")
        first.close()
        XCTAssertNil(auth.languageCode, "given back on close")

        // A wrong password, in Persian; then the right one: the same user.
        let screen = AbrovaSignInController(auth: auth, options: options) { signedIn.append($0) }
        await screen.load().value
        screen.email = email
        screen.password = password + "-wrong"
        await screen.signIn()?.value
        XCTAssertEqual(screen.error, "INVALID_CREDENTIALS")
        XCTAssertEqual(screen.errorText, "ایمیل یا رمز اشتباه است.")
        print("wrong password: \(screen.errorText ?? "")")
        screen.password = password
        await screen.signIn()?.value
        XCTAssertNil(screen.error, screen.errorText ?? "")
        XCTAssertEqual(signedIn.last?.userId, user)
        XCTAssertEqual(signedIn.count, 2)
        print("signed in again \(signedIn.last?.userId ?? "")")

        // Reset (Abrova's own page) and magic link, both in Persian.
        screen.go(.forgot)
        await screen.sendReset()?.value
        XCTAssertNil(screen.error, screen.errorText ?? "")
        XCTAssertEqual(screen.sent, .reset)
        print("reset sent")
        screen.go(.magicLink)
        await screen.sendMagicLink()?.value
        XCTAssertNil(screen.error, screen.errorText ?? "")
        XCTAssertEqual(screen.sent, .magicLink)
        print("magic link sent")

        // Continue as guest: a new user.
        screen.back()
        await screen.continueAsGuest()?.value
        XCTAssertNil(screen.error, screen.errorText ?? "")
        let guest = try XCTUnwrap(signedIn.last?.userId)
        XCTAssertEqual(signedIn.count, 3)
        XCTAssertNotEqual(guest, user)
        print("guest \(guest)")
        screen.close()
        XCTAssertNil(auth.languageCode)
    }
}
