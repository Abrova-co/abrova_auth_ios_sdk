import SwiftUI
import AbrovaAuth

// Abrova Auth — iOS example (SDK 0.1.1)
//
// Paste your public project key (Abrova Console → your project → API keys) into the field,
// or replace the placeholder below. Never put a server secret in an app.
// In a real app call AbrovaAuth.shared.configure(apiKey:) once, at app start.

private let apiKeyPlaceholder = "ab_live_YOUR_PUBLIC_KEY"

@MainActor
final class AuthModel: ObservableObject {
    // Optional launch values (Xcode scheme → Arguments → Environment): ABROVA_AUTH_API_KEY and ABROVA_AUTH_URL.
    @Published var apiKey = ProcessInfo.processInfo.environment["ABROVA_AUTH_API_KEY"] ?? apiKeyPlaceholder
    // Optional: another Auth server, for example one you run yourself. Empty = the default server.
    @Published var serverURL = ProcessInfo.processInfo.environment["ABROVA_AUTH_URL"] ?? ""
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var userId: String?
    @Published private(set) var status = ""
    @Published private(set) var isConfigured = false
    @Published private(set) var isBusy = false

    private let auth = AbrovaAuth.shared
    private var listener: AbrovaAuthListener?

    func configure() {
        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, key != apiKeyPlaceholder else {
            status = "Paste your public API key, then tap Configure."
            return
        }
        listener?.remove()
        let server = serverURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if server.isEmpty {
            auth.configure(apiKey: key)
        } else if let url = URL(string: server) {
            auth.configure(apiKey: key, baseURL: url)
        } else {
            status = "The server URL is not valid."
            return
        }
        // Called on sign-in, sign-out and when a session ends.
        listener = auth.addAuthStateListener { [weak self] userId in
            Task { @MainActor in self?.userId = userId }
        }
        userId = auth.currentUserId
        isConfigured = true
        status = "Configured."
    }

    func signInAnonymously() {
        run { _ = try await $0.signInAnonymously(); return "Signed in anonymously." }
    }

    func signUp() {
        let email = email.trimmingCharacters(in: .whitespaces), password = password
        run {
            let result = try await $0.signUp(email: email, password: password)
            return result.signedIn ? "Signed up." : "Check your inbox: confirm the e-mail, then sign in."
        }
    }

    func signIn() {
        let email = email.trimmingCharacters(in: .whitespaces), password = password
        run { _ = try await $0.signIn(email: email, password: password); return "Signed in with e-mail." }
    }

    func signOut() {
        run { await $0.signOut(); return "Signed out." }
    }

    func deleteAccount() {
        run { try await $0.deleteAccount(); return "Account deleted." }
    }

    /// Runs one SDK call and shows its result or its error code.
    private func run(_ action: @escaping (AbrovaAuth) async throws -> String) {
        isBusy = true
        status = "Working…"
        Task {
            defer { isBusy = false }
            do {
                status = try await action(auth)
            } catch let error as AbrovaAuthError {
                status = "\(error.code): \(error.message)"
            } catch {
                status = error.localizedDescription
            }
            userId = auth.currentUserId
        }
    }
}

struct AuthTestView: View {
    @StateObject private var model = AuthModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Project") {
                    TextField("Public API key (ab_live_...)", text: $model.apiKey)
                        .plainInput()
                    TextField("Server URL (optional)", text: $model.serverURL)
                        .plainInput()
                    Button("Configure", action: model.configure)
                }

                Section("Current user") {
                    Text(model.userId ?? "signed out")
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                    if !model.status.isEmpty {
                        Text(model.status).foregroundStyle(.secondary)
                    }
                }

                Section("Anonymous") {
                    Button("Sign in anonymously", action: model.signInAnonymously)
                }

                Section("E-mail and password") {
                    TextField("E-mail", text: $model.email)
                        .plainInput(email: true)
                    SecureField("Password", text: $model.password)
                    Button("Sign up", action: model.signUp)
                    Button("Sign in", action: model.signIn)
                }

                Section("Account") {
                    Button("Sign out", action: model.signOut)
                    Button("Delete account", role: .destructive, action: model.deleteAccount)
                }
            }
            .disabled(model.isBusy)
            .navigationTitle("Abrova Auth")
            .onAppear { model.configure() }
        }
    }
}

private extension View {
    /// No auto-capitalisation or autocorrection (keys and e-mail addresses).
    func plainInput(email: Bool = false) -> some View {
        #if os(iOS)
        return self
            .keyboardType(email ? .emailAddress : .default)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        #else
        return autocorrectionDisabled()
        #endif
    }
}
