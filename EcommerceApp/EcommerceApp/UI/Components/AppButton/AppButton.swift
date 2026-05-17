import SwiftUI

enum AppButtonVariant {
    case solid, outline, ghost
}

struct AppButton: View {
    let title: String
    var icon: AppIcon? = nil
    var isLoading: Bool = false
    var isDestructive: Bool = false
    var variant: AppButtonVariant = .solid
    let action: () -> Void

    @Environment(\.appColors) private var colors

    private var resolvedColor: Color {
        isDestructive ? colors.error : colors.primary
    }

    private var iconTint: Color {
        switch variant {
        case .solid: return colors.textInverse
        case .outline, .ghost: return resolvedColor
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: progressTint))
                        .scaleEffect(0.8)
                } else if let icon {
                    iconView(icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .modifier(AppButtonVariantModifier(variant: variant, color: resolvedColor))
        .disabled(isLoading)
        .accessibilityLabel(isLoading ? "\(title), loading" : title)
    }

    @ViewBuilder
    private func iconView(_ icon: AppIcon) -> some View {
        switch icon {
        case .system(let name):
            Image(systemName: name)
        case .svg(let name):
            SVGFileIcon(name, size: 20, tintColor: iconTint)
        }
    }

    private var progressTint: Color {
        switch variant {
        case .solid: return colors.textInverse
        case .outline, .ghost: return resolvedColor
        }
    }
}

private struct OutlineButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(color)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 1.5)
                    .background(Color.clear)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

private struct AppButtonVariantModifier: ViewModifier {
    let variant: AppButtonVariant
    let color: Color

    func body(content: Content) -> some View {
        switch variant {
        case .solid:
            content
                .buttonStyle(.borderedProminent)
                .tint(color)
        case .outline:
            content
                .buttonStyle(OutlineButtonStyle(color: color))
        case .ghost:
            content
                .buttonStyle(.borderless)
                .tint(color)
        }
    }
}

// MARK: - Previews

#Preview("Light") {
    VStack(spacing: 16) {
        AppButton(title: "Solid", icon: .system("arrow.right.circle.fill")) {}
        AppButton(title: "Outline", variant: .outline) {}
        AppButton(title: "Ghost", variant: .ghost) {}
        AppButton(title: "Loading…", isLoading: true) {}
        AppButton(title: "Delete", icon: .system("trash"), isDestructive: true) {}
        AppButton(title: "Cart (SVG)", icon: .svg("tab-cart")) {}
    }
    .padding()
    .applyAppColors()
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    VStack(spacing: 16) {
        AppButton(title: "Solid", icon: .system("arrow.right.circle.fill")) {}
        AppButton(title: "Outline", variant: .outline) {}
        AppButton(title: "Ghost", variant: .ghost) {}
        AppButton(title: "Loading…", isLoading: true) {}
        AppButton(title: "Delete", icon: .system("trash"), isDestructive: true) {}
        AppButton(title: "Cart (SVG)", icon: .svg("tab-cart")) {}
    }
    .padding()
    .applyAppColors()
    .preferredColorScheme(.dark)
}
