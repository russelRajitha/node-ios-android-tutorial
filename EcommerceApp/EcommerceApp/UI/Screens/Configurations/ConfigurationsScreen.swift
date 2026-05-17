import SwiftUI

struct ConfigurationsScreen: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        List {
            appearanceSection
            generalSection
        }
        .navigationTitle("Configurations")
        .navigationBarTitleDisplayMode(.large)
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            ForEach(AppTheme.allCases) { theme in
                themeRow(theme)
            }
        }
    }

    private var generalSection: some View {
        Section("General") {
            LabeledContent("App Version", value: appVersion)
        }
    }

    private func themeRow(_ theme: AppTheme) -> some View {
        Button {
            themeManager.currentTheme = theme
        } label: {
            HStack {
                Label(theme.displayName, systemImage: theme.icon)
                Spacer()
                if themeManager.currentTheme == theme {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .foregroundStyle(.primary)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
}