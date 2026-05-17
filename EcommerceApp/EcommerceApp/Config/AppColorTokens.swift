import SwiftUI

// MARK: - Token Struct
struct AppColorTokens {

    // MARK: Core Colors
    let primary: Color
    let secondary: Color
    let tertiary: Color

    // MARK: Semantic Colors
    let success: Color
    let warning: Color
    let error: Color
    let info: Color

    // MARK: Neutral Colors
    let backgroundDefault: Color
    let backgroundElevated: Color
    let backgroundInverse: Color
    let surface: Color
    let border: Color
    let divider: Color

    // MARK: Text Colors
    let textPrimary: Color
    let textSecondary: Color
    let textDisabled: Color
    let textInverse: Color

    // MARK: State Colors
    let stateHover: Color
    let statePressed: Color
    let stateFocused: Color
    let stateDisabled: Color
}

// MARK: - Light Palette
extension AppColorTokens {
    static let light = AppColorTokens(
        // Core
        primary:            Color(rgb: 0x007AFF),
        secondary:          Color(rgb: 0x5856D6),
        tertiary:           Color(rgb: 0x34C759),
        // Semantic
        success:            Color(rgb: 0x34C759),
        warning:            Color(rgb: 0xFF9500),
        error:              Color(rgb: 0xFF3B30),
        info:               Color(rgb: 0x5AC8FA),
        // Neutral
        backgroundDefault:  Color(rgb: 0xFFFFFF),
        backgroundElevated: Color(rgb: 0xF2F2F7),
        backgroundInverse:  Color(rgb: 0x1C1C1E),
        surface:            Color(rgb: 0xFFFFFF),
        border:             Color(rgb: 0xC6C6C8),
        divider:            Color(rgb: 0xE5E5EA),
        // Text
        textPrimary:        Color(rgb: 0x000000),
        textSecondary:      Color(rgb: 0x6E6E73),
        textDisabled:       Color(rgb: 0xAEAEB2),
        textInverse:        Color(rgb: 0xFFFFFF),
        // States
        stateHover:         Color(rgb: 0x000000).opacity(0.04),
        statePressed:       Color(rgb: 0x000000).opacity(0.12),
        stateFocused:       Color(rgb: 0x007AFF).opacity(0.20),
        stateDisabled:      Color(rgb: 0x000000).opacity(0.12)
    )
}

// MARK: - Dark Palette
extension AppColorTokens {
    static let dark = AppColorTokens(
        // Core
        primary:            Color(rgb: 0x0A84FF),
        secondary:          Color(rgb: 0x5E5CE6),
        tertiary:           Color(rgb: 0x30D158),
        // Semantic
        success:            Color(rgb: 0x30D158),
        warning:            Color(rgb: 0xFF9F0A),
        error:              Color(rgb: 0xFF453A),
        info:               Color(rgb: 0x64D2FF),
        // Neutral
        backgroundDefault:  Color(rgb: 0x000000),
        backgroundElevated: Color(rgb: 0x1C1C1E),
        backgroundInverse:  Color(rgb: 0xF2F2F7),
        surface:            Color(rgb: 0x1C1C1E),
        border:             Color(rgb: 0x38383A),
        divider:            Color(rgb: 0x2C2C2E),
        // Text
        textPrimary:        Color(rgb: 0xFFFFFF),
        textSecondary:      Color(rgb: 0xAEAEB2),
        textDisabled:       Color(rgb: 0x636366),
        textInverse:        Color(rgb: 0x000000),
        // States
        stateHover:         Color(rgb: 0xFFFFFF).opacity(0.04),
        statePressed:       Color(rgb: 0xFFFFFF).opacity(0.12),
        stateFocused:       Color(rgb: 0x0A84FF).opacity(0.20),
        stateDisabled:      Color(rgb: 0xFFFFFF).opacity(0.12)
    )
}

// MARK: - Environment Integration
private struct AppColorsKey: EnvironmentKey {
    static let defaultValue = AppColorTokens.light
}

extension EnvironmentValues {
    var appColors: AppColorTokens {
        get { self[AppColorsKey.self] }
        set { self[AppColorsKey.self] = newValue }
    }
}

// MARK: - Root View Modifier
extension View {
    func applyAppColors() -> some View {
        modifier(AppColorSchemeModifier())
    }
}

private struct AppColorSchemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.environment(
            \.appColors,
            colorScheme == .dark ? .dark : .light
        )
    }
}

// MARK: - Hex Init (palette-internal)

private extension Color {
    init(rgb: UInt32) {
        self.init(
            .sRGB,
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >>  8) & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }
}