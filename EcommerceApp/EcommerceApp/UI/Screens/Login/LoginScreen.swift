import SwiftUI

struct LoginSheet: View {
    @Binding var isPresented: Bool
    var onSuccess: (() -> Void)? = nil
    var canDismiss: Bool = true

    @State private var viewModel = AppContainer.shared.container.resolve(LoginViewModel.self)!
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                header
                fields
                errorMessage
                loginButton
                Spacer()
            }
            .padding()
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if canDismiss {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { isPresented = false }
                    }
                }
            }
            .interactiveDismissDisabled(!canDismiss)
            .onChange(of: viewModel.state) { _, newState in
                if case .error(let msg, _) = newState {
                    print("[LoginScreen] Error: \(msg)")
                }
                if case .success = newState {
                    onSuccess?()
                    isPresented = false
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.accentColor)
            Text("Welcome Back")
                .font(.title2.bold())
            Text("Sign in to your account")
                .foregroundStyle(.secondary)
        }
        .padding(.top)
    }

    // MARK: - Fields
    private var fields: some View {
        VStack(spacing: 12) {
            AppTextField(
                placeholder: "Email",
                text: $email,
                icon: .system("envelope"),
                errorMessages: fieldErrors(for: "email"),
                keyboardType: .emailAddress,
                autocapitalization: .never,
                isAutocorrectionDisabled: true
            )
            AppTextField(
                placeholder: "Password",
                text: $password,
                icon: .system("lock"),
                isSecure: true,
                errorMessages: fieldErrors(for: "password")
            )
        }
    }

    private func fieldErrors(for field: String) -> [String] {
        if case .error(_, let errors) = viewModel.state,
           let messages = errors?[field] {
            return messages
        }
        return []
    }

    // MARK: - Error
    @ViewBuilder
    private var errorMessage: some View {
        if case .error(let msg, _) = viewModel.state {
            Text(msg)
                .font(.caption)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Login Button
    private var loginButton: some View {
        AppButton(
            title: "Sign In",
            icon: .system("arrow.right.circle.fill"),
            isLoading: {
                if case .loading = viewModel.state { return true }
                return false
            }()
        ) {
            viewModel.clearError()
            Task { await viewModel.login(email: email, password: password) }
        }
    }
}
