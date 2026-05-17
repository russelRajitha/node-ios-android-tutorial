import SwiftUI

struct AppTabBar: View {
    @Binding var selectedTab: AppTab
    @Environment(\.appColors) private var colors

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    colors: colors
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background {
            Rectangle()
                .fill(.regularMaterial)
                .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(colors.divider)
                .frame(height: 0.5)
        }
    }
}

private struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let colors: AppColorTokens
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                SVGIcon(
                    tab.icon,
                    size: 24,
                    tintColor: isSelected ? colors.primary : colors.textSecondary
                )
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? colors.primary : colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
