import SwiftUI

struct ProfileScreen: View {
    @State private var viewModel = AppContainer.shared.container.resolve(ProfileViewModel.self)!

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                AppSpinner()
            case .success(let profile):
                profileContent(profile)
            case .error(let message):
                errorView(message)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.fetchProfile() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    Task { await viewModel.logout() }
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
    }

    // MARK: - Profile Content

    private func profileContent(_ profile: UserProfile) -> some View {
        List {
            Section {
                ProfileRow(label: "First Name", value: profile.firstName)
                ProfileRow(label: "Last Name", value: profile.lastName)
                ProfileRow(label: "Email", value: profile.email)
                ProfileRow(label: "Member Since", value: profile.createdAt)
                ProfileRow(label: "User ID", value: profile.id)
            }
            Section("Activity") {
                NavigationLink(value: AppRoute.orders) {
                    Label("My Orders", systemImage: "bag")
                }
            }
        }
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            AppButton(title: "Retry", icon: .system("arrow.clockwise")) {
                Task { await viewModel.fetchProfile() }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

private struct ProfileRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Preview

#Preview("ProfileScreen") {
    NavigationStack {
        ProfileScreen()
    }
    .applyAppColors()
}

#Preview("ProfileScreen – Dark") {
    NavigationStack {
        ProfileScreen()
    }
    .applyAppColors()
    .preferredColorScheme(.dark)
}
