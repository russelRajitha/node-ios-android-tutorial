import SwiftUI

final class ThemeManager: ObservableObject {

    @Published var currentTheme: AppTheme {
        didSet { defaults.set(currentTheme.rawValue, forKey: storageKey) }
    }

    var colorScheme: ColorScheme? { currentTheme.colorScheme }

    private let defaults = UserDefaults.standard
    private let storageKey = "app_theme"

    init() {
        let stored = defaults.string(forKey: "app_theme")
            .flatMap(AppTheme.init(rawValue:)) ?? .system
        self.currentTheme = stored
    }
}