import SwiftUI

struct AppSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @Environment(\.appColors) private var colors

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(colors.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .foregroundStyle(colors.primary)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview("AppSectionHeader") {
    VStack(spacing: 24) {
        AppSectionHeader(title: "Categories")
        AppSectionHeader(title: "Featured", actionTitle: "See All", action: {})
    }
    .padding()
    .applyAppColors()
}

#Preview("AppSectionHeader – Dark") {
    VStack(spacing: 24) {
        AppSectionHeader(title: "Categories")
        AppSectionHeader(title: "Featured", actionTitle: "See All", action: {})
    }
    .padding()
    .preferredColorScheme(.dark)
    .applyAppColors()
}
