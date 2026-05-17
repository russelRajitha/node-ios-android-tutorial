import SwiftUI
import UIKit

enum AppTextFieldVariant {
    case outlined, filled, underlined
}

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var label: String? = nil
    var icon: AppIcon? = nil
    var isSecure: Bool = false
    var variant: AppTextFieldVariant = .outlined
    var errorMessages: [String] = []
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isAutocorrectionDisabled: Bool = false
    var lineLimit: Int? = nil

    @Environment(\.appColors) private var colors
    @FocusState private var isFocused: Bool

    private var resolvedColor: Color {
        errorMessages.isEmpty ? colors.primary : colors.error
    }

    private var activeBorderColor: Color {
        isFocused || !errorMessages.isEmpty ? resolvedColor : resolvedColor.opacity(0.3)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isFocused || !errorMessages.isEmpty ? resolvedColor : resolvedColor.opacity(0.6))
            }
            inputContent
                .modifier(AppTextFieldVariantModifier(
                    variant: variant,
                    resolvedColor: resolvedColor,
                    borderColor: activeBorderColor
                ))
            ForEach(errorMessages, id: \.self) { msg in
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(colors.error)
            }
        }
    }

    @ViewBuilder
    private var inputContent: some View {
        HStack(alignment: lineLimit != nil ? .top : .center, spacing: 8) {
            if let icon {
                icon.view(size: 16, tintColor: isFocused ? resolvedColor : resolvedColor.opacity(0.45))
                    .frame(width: 16)
            }
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                } else if let lineLimit {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .autocorrectionDisabled(isAutocorrectionDisabled)
                        .focused($isFocused)
                        .lineLimit(1...lineLimit)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .autocorrectionDisabled(isAutocorrectionDisabled)
                        .focused($isFocused)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }
}

private struct AppTextFieldVariantModifier: ViewModifier {
    let variant: AppTextFieldVariant
    let resolvedColor: Color
    let borderColor: Color

    func body(content: Content) -> some View {
        switch variant {
        case .outlined:
            content
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 1.5)
                        .background(Color.clear)
                )
        case .filled:
            content
                .background(resolvedColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 1.5)
                )
        case .underlined:
            content
                .overlay(
                    Rectangle()
                        .frame(height: 1.5)
                        .foregroundStyle(borderColor),
                    alignment: .bottom
                )
        }
    }
}

// MARK: - Previews
#Preview("Light") {
    VStack(spacing: 16) {
        AppTextField(placeholder: "Email address", text: .constant(""), label: "Email", icon: .system("envelope"))
        AppTextField(placeholder: "Password", text: .constant("secret"), label: "Password", icon: .system("lock"), isSecure: true)
        AppTextField(placeholder: "Email address", text: .constant("bad"), label: "With error", icon: .system("envelope"), errorMessages: ["Enter a valid email address"])
        AppTextField(placeholder: "Username", text: .constant(""), label: "Filled", icon: .system("person"), variant: .filled)
        AppTextField(placeholder: "Search", text: .constant(""), label: "Underlined", icon: .system("magnifyingglass"), variant: .underlined)
        AppTextField(placeholder: "Write a description…", text: .constant("This spans\nmultiple lines"), label: "Multiline (4 lines max)", icon: .system("text.alignleft"), lineLimit: 4)
        AppTextField(placeholder: "Search", text: .constant(""), label: "SVG icon", icon: .svg("tab-shop"))
    }
    .padding()
    .applyAppColors()
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    VStack(spacing: 16) {
        AppTextField(placeholder: "Email address", text: .constant(""), label: "Email", icon: .system("envelope"))
        AppTextField(placeholder: "Password", text: .constant("secret"), label: "Password", icon: .system("lock"), isSecure: true)
        AppTextField(placeholder: "Email address", text: .constant("bad"), label: "With error", icon: .system("envelope"), errorMessages: ["Enter a valid email address"])
        AppTextField(placeholder: "Username", text: .constant(""), label: "Filled", icon: .system("person"), variant: .filled)
        AppTextField(placeholder: "Search", text: .constant(""), label: "Underlined", icon: .system("magnifyingglass"), variant: .underlined)
        AppTextField(placeholder: "Write a description…", text: .constant("This spans\nmultiple lines"), label: "Multiline (4 lines max)", icon: .system("text.alignleft"), lineLimit: 4)
        AppTextField(placeholder: "Search", text: .constant(""), label: "SVG icon", icon: .svg("tab-shop"))
    }
    .padding()
    .applyAppColors()
    .preferredColorScheme(.dark)
}